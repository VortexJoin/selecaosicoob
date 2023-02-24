// To parse this JSON data, do
//
//     final ticket = ticketFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../services/firestore_service.dart';

List<Ticket> ticketFromJson(String str) =>
    List<Ticket>.from(json.decode(str).map((x) => Ticket.fromJson(x)));

String ticketToJson(List<Ticket> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Ticket {
  Ticket({
    this.codigo = '',
    this.uid = '',
    required this.assunto,
    required this.conteudo,
    required this.usuarioabertura,
    this.responsavel,
    this.responsavelatual,
    required this.abertura,
    this.encerrado,
    this.inicioAtendimento,
    required this.ultimamovimentacao,
    required this.setorinicial,
    required this.setoratual,
    this.tipo = 'Chamado',
    required this.urgencia,
    this.status = "Aberto",
    this.mensagem = const [],
    this.movimentacao = const [],
    this.avaliacao,
  });

  String codigo;
  String uid;
  String assunto;
  String conteudo;
  String usuarioabertura;
  String? responsavel;
  String? responsavelatual;
  DateTime abertura;
  DateTime? inicioAtendimento;
  DateTime? encerrado;
  DateTime ultimamovimentacao;
  String setorinicial;
  String setoratual;
  String tipo;
  String urgencia;
  String status;
  List<Mensagem> mensagem;
  List<Movimentacao> movimentacao;
  Avaliacao? avaliacao;

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        codigo: json["codigo"].toString(),
        uid: json["uid"].toString(),
        assunto: json["assunto"].toString(),
        conteudo: json["conteudo"].toString(),
        usuarioabertura: json["usuarioabertura"].toString(),
        responsavel: json["responsavel"],
        responsavelatual: json["responsavelatual"],
        abertura: DateTime.parse(json["abertura"]),
        encerrado: DateTime.tryParse(json["encerrado"]),
        ultimamovimentacao: DateTime.parse(json["ultimamovimentacao"]),
        setorinicial: json["setorinicial"].toString(),
        setoratual: json["setoratual"].toString(),
        tipo: json["tipo"].toString(),
        urgencia: json["urgencia"].toString(),
        status: json["status"].toString(),
        inicioAtendimento: DateTime.tryParse(json["inicioAtendimento"]),
        mensagem: List<Mensagem>.from(
            json["mensagem"].map((x) => Mensagem.fromJson(x))),
        movimentacao: List<Movimentacao>.from(
            json["movimentacao"].map((x) => Movimentacao.fromJson(x))),
        avaliacao: (json["avaliacao"]).toString().isEmpty
            ? null
            : Avaliacao.fromJson(json["avaliacao"]),
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "uid": uid,
        "assunto": assunto,
        "conteudo": conteudo,
        "usuarioabertura": usuarioabertura,
        "responsavel": responsavel,
        "responsavelatual": responsavelatual,
        "abertura": abertura.toIso8601String(),
        "encerrado": (encerrado == null) ? '' : encerrado!.toIso8601String(),
        "inicioAtendimento": (inicioAtendimento == null)
            ? ''
            : inicioAtendimento!.toIso8601String(),
        "ultimamovimentacao": ultimamovimentacao.toIso8601String(),
        "setorinicial": setorinicial,
        "setoratual": setoratual,
        "tipo": tipo,
        "urgencia": urgencia,
        "status": status,
        "mensagem": List<dynamic>.from(mensagem.map((x) => x.toJson())),
        "movimentacao": List<dynamic>.from(movimentacao.map((x) => x.toJson())),
        "avaliacao": (avaliacao == null) ? '' : avaliacao!.toJson(),
      };

  String toStringCAC() {
    return '$codigo $assunto $conteudo';
  }
}

class Avaliacao {
  Avaliacao({
    required this.nota,
    required this.comentario,
  });

  int nota;
  String comentario;

  factory Avaliacao.fromJson(Map<String, dynamic> json) => Avaliacao(
        nota: json["nota"],
        comentario: json["comentario"],
      );

  Map<String, dynamic> toJson() => {
        "nota": nota,
        "comentario": comentario,
      };
}

class Mensagem {
  Mensagem(
      {required this.datamensagem,
      required this.usuario,
      required this.uid,
      required this.conteudo,
      this.movimentacaoSetor = false});

  DateTime datamensagem;
  String usuario;
  String uid;
  String conteudo;
  bool movimentacaoSetor;

  factory Mensagem.fromJson(Map<String, dynamic> json) => Mensagem(
        datamensagem: DateTime.parse(json["datamensagem"]),
        usuario: json["usuario"],
        uid: json["uid"],
        conteudo: json["conteudo"],
        movimentacaoSetor: (json["movimentacaoSetor"] == null)
            ? false
            : json["movimentacaoSetor"],
      );

  Map<String, dynamic> toJson() => {
        "datamensagem": datamensagem.toIso8601String(),
        "usuario": usuario,
        "uid": uid,
        "conteudo": conteudo,
        "movimentacaoSetor": movimentacaoSetor,
      };
}

class Movimentacao {
  Movimentacao({
    required this.uid,
    required this.usuarioenvio,
    required this.usuariodefinido,
    required this.datamovimento,
  });

  String uid;
  String usuarioenvio;
  String usuariodefinido;
  DateTime datamovimento;

  factory Movimentacao.fromJson(Map<String, dynamic> json) => Movimentacao(
        uid: json["uid"],
        usuarioenvio: json["usuarioenvio"],
        usuariodefinido: json["usuariodefinido"],
        datamovimento: DateTime.parse(json["datamovimento"]),
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "usuarioenvio": usuarioenvio,
        "usuariodefinido": usuariodefinido,
        "datamovimento": datamovimento.toIso8601String(),
      };
}

class TicketController extends ChangeNotifier {
  bool _isLoading = false;
  bool _showLoading = true;
  String _hasError = '';
  String _orderField = 'abertura';
  final Uuid _uuid = const Uuid();
  List<Ticket> _dados = [];

  FirestoreService firestoreService = FirestoreService('atendimento');

  TicketController({bool initialLoad = false, showLoading = true}) {
    _showLoading = showLoading;
    if (initialLoad) {
      _setLoading(true);
      getData();
    }
  }

  bool get isLoading => _isLoading;
  bool get hasError => _hasError.isNotEmpty;
  bool get hasData => _dados.isNotEmpty;
  String get error => _hasError;
  List<Ticket> get dados => _dados;

  setOrderField(String orderField) {
    _orderField = orderField;
    getData();
    notifyListeners();
  }

  _setLoading(bool isLoading) {
    if (_showLoading) {
      _isLoading = isLoading;
      notifyListeners();
    }
  }

  _setError(String error) {
    _hasError = error;
    if (kDebugMode) {
      print(error);
    }
    notifyListeners();
  }

  Future<void> getData({String filtroDescricao = ''}) async {
    _setLoading(true);
    try {
      _dados = [];
      if (filtroDescricao.isNotEmpty) {
        await firestoreService
            .getCollection()
            .where("nome", arrayContains: filtroDescricao.toLowerCase())
            .orderBy(_orderField)
            .get()
            .then((snapshot) {
          _dados = snapshot.docs
              .map((e) => Ticket.fromJson(e.data() as Map<String, dynamic>))
              .toList();
        });
      } else {
        await firestoreService
            .getCollection()
            .orderBy(_orderField)
            .get()
            .then((snapshot) {
          _dados = snapshot.docs
              .map((e) => Ticket.fromJson(e.data() as Map<String, dynamic>))
              .toList();
        });
      }

      _setError('');
    } catch (e) {
      _setError(e.toString());
    }

    notifyListeners();
    _setLoading(false);
  }

  CollectionReference getCollection() {
    return firestoreService.getCollection();
  }

  Stream<List<Ticket>> streamProcessosAll() =>
      getCollection().snapshots().map((x) => x.docs
          .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Future<List<Ticket>> futureProcessosAll() async {
    return await getCollection().get().then((snapshot) {
      return _dados = snapshot.docs
          .map((e) => Ticket.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    }).then((value) {
      return [];
    });
  }

  Future<bool> setdata(Ticket ticket, {bool refreshData = false}) async {
    // ESSE METODO SERVE TANTO PARA INSERIR QUANTO PARA EDITAR
    _setLoading(true);

    if (ticket.uid.isEmpty) {
      ticket.uid = _uuid.v4();
    }

    if (ticket.codigo.isEmpty) {
      ticket.codigo = ticket.uid.split('-').first;
    }
    try {
      await firestoreService.setdata(
        item: ticket.toJson(),
        id: ticket.codigo,
      );
      _setError('');
      _setLoading(false);

      if (refreshData) {
        getData();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  filterGeral(String filter) {
    _dados = dados
        .where(
          (x) => x.toStringCAC().toLowerCase().contains(
                filter.toLowerCase(),
              ),
        )
        .toList();
  }

  Future<Ticket?> getByCodigo(String codigo, {bool setOnData = false}) async {
    try {
      final docSnapshot = await firestoreService
          .getCollection()
          .where("codigo", isEqualTo: codigo)
          .orderBy("codigo")
          .orderBy(_orderField)
          .get();

      if (setOnData) {
        setdata(
          Ticket.fromJson(
              docSnapshot.docs.first.data() as Map<String, dynamic>),
        );
      }
      if (docSnapshot.docs.isNotEmpty) {
        return Ticket.fromJson(
            docSnapshot.docs.first.data() as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    return null;
  }

  Future<List<Ticket>> getBySetores(List<String> setores) async {
    _setLoading(true);
    final docSnapshot = await firestoreService
        .getCollection()
        .where("setoratual", arrayContainsAny: setores)
        .get();
    _setLoading(false);
    return docSnapshot.docs
        .map((e) => Ticket.fromJson(e.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Ticket?> getByResponsavelAtual(String responsavelatual) async {
    final docSnapshot = await firestoreService
        .getCollection()
        .where("responsavelatual", isEqualTo: responsavelatual)
        .get();

    if (docSnapshot.docs.isNotEmpty) {
      return Ticket.fromJson(
          docSnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<Ticket?> getByUsuarioAbertura(String usuarioabertura) async {
    final docSnapshot = await firestoreService
        .getCollection()
        .where("usuarioabertura", isEqualTo: usuarioabertura)
        .get();
    if (docSnapshot.docs.isNotEmpty) {
      return Ticket.fromJson(
          docSnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<Ticket?> getConcluido() async {
    final docSnapshot = await firestoreService
        .getCollection()
        .where("status", isEqualTo: 'Concluido')
        .get();
    if (docSnapshot.docs.isNotEmpty) {
      return Ticket.fromJson(
          docSnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<Ticket?> streamByCod(String codigo) {
    return getCollection().where("codigo", isEqualTo: codigo).snapshots().map(
        (x) => x.docs
            .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
            .toList()
            .first);
  }
}


/*

[
    {
        "codigo" : "",
        "uid" : "",
        "assunto" : "",
        "conteudo" : "",
        "usuarioabertura" :"",
        "responsavel" :"",
        "responsavelatual" :"",
        "abertura" : "2022-01-01 10:30:00",
        "encerrado" :"2022-01-01 18:30:00",
        "ultimamovimentacao" :"2022-01-01 18:30:00",
        "setorinicial" : "",
        "setoratual" : "",
        "tipo" : "",
        "urgencia" : "",
        "status" : "",
        "mensagem" : 
        [
           {
               "datamensagem" : "2022-01-01 10:30:00",
               "usuario" : "",
               "uid" : "",
               "conteudo" : ""
            }
        ],
        "movimentacao" : 
        [
            {
                "uid" : "" ,
                "usuarioenvio" : "",
                "usuariodefinido" : "",
                "datamovimento" : "2022-01-01 10:30:00"
            }
        ]
    }
]
*/