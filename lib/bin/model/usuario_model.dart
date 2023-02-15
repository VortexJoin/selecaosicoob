// To parse this JSON data, do
//
//     final Usuario = UsuarioFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../services/firestore_service.dart';

List<Usuario> usuarioFromJson(String str) => List<Usuario>.from(
      json.decode(str).map((x) => Usuario.fromJson(x)),
    );

String usuarioToJson(List<Usuario> data) => json.encode(
      List<dynamic>.from(data.map((x) => x.toJson())),
    );

class Usuario {
  Usuario({
    this.codigo = '',
    this.uid = '',
    required this.nome,
    required this.email,
    required this.senha,
    this.tipo = '',
    this.setores = const [],
  });

  String codigo;
  String uid;
  String nome;
  String email;
  String senha;
  String tipo;
  List<String> setores;

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        codigo: json["codigo"],
        uid: json["uid"],
        nome: json["nome"],
        email: json["email"],
        senha: json["senha"],
        tipo: json["tipo"],
        setores: List<String>.from(json["setores"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "uid": uid,
        "nome": nome,
        "email": email,
        "senha": senha,
        "tipo": tipo,
        "setores": List<dynamic>.from(setores.map((x) => x)),
      };
}

class UsuarioController extends ChangeNotifier {
  bool _isLoading = false;
  String _hasError = '';
  String _orderField = 'nome';
  final Uuid _uuid = const Uuid();
  List<Usuario> _dados = [];

  FirestoreService firestoreService = FirestoreService('usuario');

  UsuarioController({bool initialLoad = false}) {
    if (initialLoad) {
      getData();
    }
  }

  bool get isLoading => _isLoading;
  bool get hasError => _hasError.isNotEmpty;
  bool get hasData => _dados.isNotEmpty;
  String get error => _hasError;
  List<Usuario> get dados => _dados;

  setOrderField(String orderField) {
    _orderField = orderField;
    getData();
    notifyListeners();
  }

  _setLoading() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  _setError(String error) {
    _hasError = error;
    if (kDebugMode) {
      print(error);
    }
    notifyListeners();
  }

  Future<void> getData({String filtroDescricao = ''}) async {
    _setLoading();
    try {
      _dados = [];
      if (filtroDescricao.isNotEmpty) {
        await firestoreService
            .getCollection()
            // TODO - aguardando index
            //.where('nome', isEqualTo: filtroDescricao)
            .orderBy(_orderField)
            .get()
            .then((snapshot) {
          _dados = snapshot.docs
              .map((e) => Usuario.fromJson(e.data() as Map<String, dynamic>))
              .toList()
              .where((a) =>
                  a.nome.toLowerCase().contains(filtroDescricao.toLowerCase()))
              .toList();
        });
      } else {
        await firestoreService
            .getCollection()
            .orderBy(_orderField)
            .get()
            .then((snapshot) {
          _dados = snapshot.docs
              .map((e) => Usuario.fromJson(e.data() as Map<String, dynamic>))
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

  Future<bool> setdata(Usuario usuario) async {
    // ESSE METODO SERVE TANTO PARA INSERIR QUANTO PARA EDITAR
    _setLoading();

    if (usuario.uid.isEmpty) {
      usuario.uid = _uuid.v4();
    }

    if (usuario.codigo.isEmpty) {
      usuario.codigo = usuario.uid.split('-').first;
    }
    try {
      await firestoreService.setdata(
        item: usuario.toJson(),
        id: usuario.codigo,
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

  Future<Usuario?> getByCodigo(String codigo) async {
    final docSnapshot = await firestoreService
        .getCollection()
        .where("codigo", isEqualTo: codigo)
        .orderBy("codigo")
        .orderBy(_orderField)
        .get();
    if (docSnapshot.docs.isNotEmpty) {
      return Usuario.fromJson(
          docSnapshot.docs.first.data as Map<String, dynamic>);
    }
    return null;
  }

  Future<Usuario?> getByNome(String nome) async {
    final docSnapshot = await firestoreService
        .getCollection()
        .where("nome", isEqualTo: nome)
        .orderBy("nome")
        .orderBy(_orderField)
        .get();
    if (docSnapshot.docs.isNotEmpty) {
      return Usuario.fromJson(
          docSnapshot.docs.first.data as Map<String, dynamic>);
    }
    return null;
  }
}
