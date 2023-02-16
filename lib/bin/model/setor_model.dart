// To parse this JSON data, do
//
//     final setor = setorFromJson(jsonString);
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:selecaosicoob/bin/services/firestore_service.dart';
import 'package:uuid/uuid.dart';

List<Setor> setorFromJson(String str) =>
    List<Setor>.from(json.decode(str).map((x) => Setor.fromJson(x)));

String setorToJson(List<Setor> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Setor {
  Setor({
    this.codigo = '',
    this.uid = '',
    required this.descricao,
    this.checkBox = false,
  });

  String codigo;
  String uid;
  String descricao;
  bool checkBox;

  factory Setor.fromJson(Map<String, dynamic> json) => Setor(
        codigo: json["codigoSetor"],
        uid: json["uidSetor"],
        descricao: json["descricao"],
      );

  Map<String, dynamic> toJson() => {
        "codigoSetor": codigo,
        "uidSetor": uid,
        "descricao": descricao,
      };
}

class SetorController extends ChangeNotifier {
  bool _isLoading = false;
  String _hasError = '';
  String _orderField = 'descricao';
  final Uuid _uuid = const Uuid();
  List<Setor> _listaSetor = [];

  FirestoreService firestoreService = FirestoreService('setor');

  SetorController({bool loadSetores = false}) {
    if (loadSetores) {
      getData();
    }
  }

  setOrderField(String orderField) {
    _orderField = orderField;
    getData();
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  bool get hasError => _hasError.isNotEmpty;
  bool get hasData => _listaSetor.isNotEmpty;
  String get error => _hasError;
  List<Setor> get listaSetor => _listaSetor;

  _setLoading() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  _setError(String error) {
    if (kDebugMode) {
      print(error);
    }
    _hasError = error;
    notifyListeners();
  }

  Future<void> getData({String filtroDescricao = ''}) async {
    _setLoading();
    try {
      _listaSetor = [];
      if (filtroDescricao.isNotEmpty) {
        await firestoreService
            .getCollection()

            //.where("descricao", arrayContains: filtroDescricao.toLowerCase())
            .orderBy(_orderField)
            .get()
            .then((snapshot) {
          _listaSetor = snapshot.docs
              .map((e) => Setor.fromJson(e.data() as Map<String, dynamic>))
              .toList()
              .toList()
              .where((a) => a.descricao
                  .toLowerCase()
                  .contains(filtroDescricao.toLowerCase()))
              .toList();
        });
      } else {
        await firestoreService
            .getCollection()
            .orderBy(_orderField)
            .get()
            .then((snapshot) {
          _listaSetor = snapshot.docs
              .map((e) => Setor.fromJson(e.data() as Map<String, dynamic>))
              .toList();
        });
      }

      _setError('');
    } catch (e) {
      _setError(e.toString());
    }

    notifyListeners();
    _setLoading();
  }

  Future<bool> setdata(Setor setor) async {
    // ESSE METODO SERVE TANTO PARA INSERIR QUANTO PARA EDITAR
    _setLoading();

    if (setor.uid.isEmpty) {
      setor.uid = _uuid.v4();
    }

    if (setor.codigo.isEmpty) {
      setor.codigo = setor.uid.split('-').first;
    }
    try {
      await firestoreService.setdata(
        item: setor.toJson(),
        id: setor.codigo,
      );
      _setError('');
      _setLoading();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading();
      return false;
    }
  }

  Future<Setor?> getByCodigo(String codigo) async {
    final docSnapshot = await firestoreService
        .getCollection()
        .where("codigoSetor", isEqualTo: codigo)
        .get();
    if (docSnapshot.docs.isNotEmpty) {
      return Setor.fromJson(
          docSnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }
}
