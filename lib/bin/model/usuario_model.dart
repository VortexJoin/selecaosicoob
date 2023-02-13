// To parse this JSON data, do
//
//     final atendimento = atendimentoFromJson(jsonString);

import 'dart:convert';

List<Atendimento> atendimentoFromJson(String str) => List<Atendimento>.from(
    json.decode(str).map((x) => Atendimento.fromJson(x)));

String atendimentoToJson(List<Atendimento> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Atendimento {
  Atendimento({
    this.codigo = '',
    required this.uid,
    required this.nome,
    required this.email,
    required this.senha,
    required this.setores,
    required this.tipo,
  });

  String codigo;
  String uid;
  String nome;
  String email;
  String senha;
  String setores;
  String tipo;

  factory Atendimento.fromJson(Map<String, dynamic> json) => Atendimento(
        codigo: json["codigo"],
        uid: json["uid"],
        nome: json["nome"],
        email: json["email"],
        senha: json["senha"],
        setores: json["setores"],
        tipo: json["tipo"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "uid": uid,
        "nome": nome,
        "email": email,
        "senha": senha,
        "setores": setores,
        "tipo": tipo,
      };
}
