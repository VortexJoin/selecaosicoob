// To parse this JSON data, do
//
//     final ticket = ticketFromJson(jsonString);

import 'dart:convert';

List<Ticket> ticketFromJson(String str) =>
    List<Ticket>.from(json.decode(str).map((x) => Ticket.fromJson(x)));

String ticketToJson(List<Ticket> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Ticket {
  Ticket({
    this.codigo = '',
    required this.uid,
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
    required this.tipo,
    required this.urgencia,
    this.status = "Abertura",
    this.mensagem = const [],
    this.movimentacao = const [],
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

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        codigo: json["codigo"],
        uid: json["uid"],
        assunto: json["assunto"],
        conteudo: json["conteudo"],
        usuarioabertura: json["usuarioabertura"],
        responsavel: json["responsavel"] ?? '',
        responsavelatual: json["responsavelatual"] ?? '',
        abertura: DateTime.parse(json["abertura"]),
        encerrado: DateTime.parse(json["encerrado"]),
        ultimamovimentacao: DateTime.parse(json["ultimamovimentacao"]),
        setorinicial: json["setorinicial"],
        setoratual: json["setoratual"],
        tipo: json["tipo"],
        urgencia: json["urgencia"],
        status: json["status"],
        inicioAtendimento: json["inicioAtendimento"],
        mensagem: List<Mensagem>.from(
            json["mensagem"].map((x) => Mensagem.fromJson(x))),
        movimentacao: List<Movimentacao>.from(
            json["movimentacao"].map((x) => Movimentacao.fromJson(x))),
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
      };
}

class Mensagem {
  Mensagem({
    required this.datamensagem,
    required this.usuario,
    required this.uid,
    required this.conteudo,
  });

  DateTime datamensagem;
  String usuario;
  String uid;
  String conteudo;

  factory Mensagem.fromJson(Map<String, dynamic> json) => Mensagem(
        datamensagem: DateTime.parse(json["datamensagem"]),
        usuario: json["usuario"],
        uid: json["uid"],
        conteudo: json["conteudo"],
      );

  Map<String, dynamic> toJson() => {
        "datamensagem": datamensagem.toIso8601String(),
        "usuario": usuario,
        "uid": uid,
        "conteudo": conteudo,
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