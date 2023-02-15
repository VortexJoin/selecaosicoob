import 'package:flutter/material.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';

class HomePageController extends ChangeNotifier {
  UsuarioController usuarioController = UsuarioController();

  Future<Usuario?> getUsuarioByEmail(String email) {
    return usuarioController.getUsuarioByEmail(email);
  }
}
