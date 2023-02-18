import 'package:flutter/material.dart';

class CorPadraoTema {
  Color primaria;
  Color secundaria;
  Color terciaria;

  Color roxo;
  Color verdeClaro;

  CorPadraoTema({
    this.primaria = const Color.fromRGBO(0, 160, 145, 1),
    this.secundaria = const Color.fromRGBO(0, 54, 65, 1),
    this.terciaria = const Color.fromRGBO(125, 182, 28, 1),
    this.roxo = const Color.fromRGBO(73, 70, 157, 1),
    this.verdeClaro = const Color.fromRGBO(191, 214, 48, 1),
  });

  List<Color> get allColors =>
      <Color>[primaria, secundaria, terciaria, roxo, verdeClaro];
}


/*
Cores SICOOB

Verde Turquesa = #00AE9d (0,160,145)
Verde Escuro   = #003641 (0,54,65)

secundarias
verde medio = #7DB61C (125,182,28)

*/
