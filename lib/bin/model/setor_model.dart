// To parse this JSON data, do
//
//     final setor = setorFromJson(jsonString);
import 'dart:convert';

List<Setor> setorFromJson(String str) =>
    List<Setor>.from(json.decode(str).map((x) => Setor.fromJson(x)));

String setorToJson(List<Setor> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Setor {
  Setor({
    required this.codigoSetor,
    required this.uidSetor,
    required this.descricao,
  });

  String codigoSetor;
  String uidSetor;
  String descricao;

  factory Setor.fromJson(Map<String, dynamic> json) => Setor(
        codigoSetor: json["codigoSetor"],
        uidSetor: json["uidSetor"],
        descricao: json["descricao"],
      );

  Map<String, dynamic> toJson() => {
        "codigoSetor": codigoSetor,
        "uidSetor": uidSetor,
        "descricao": descricao,
      };
}
