import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/setor_model.dart';
import '../../model/usuario_model.dart';

class UsuarioPageController extends ChangeNotifier {
  final UsuarioController controller;
  UsuarioPageController(this.controller);

  TextEditingController searchQueryController = TextEditingController();
  bool isSearching = false;
  String searchQuery = "";

  Future<void> setSetores(
    BuildContext context,
    Usuario data,
    List<Setor> setorParam,
  ) async {
    ValueNotifier<List<Setor>> setores = ValueNotifier([]);
    setores.value = setorParam;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DialogSelecionaSetoresUsuario(
          data: data,
          controller: controller,
        );
      },
    );
  }

  Future<void> novo(
    BuildContext context, {
    Usuario? data,
  }) async {
    bool hasData = data == null ? false : true;

    TextEditingController nomeController = TextEditingController(
      text: hasData ? data.nome : '',
    );
    TextEditingController emailController = TextEditingController(
      text: hasData ? data.email : '',
    );

    ValueNotifier<String> tipoUser =
        ValueNotifier(hasData ? data.tipo : 'padrao');

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(hasData ? 'Editar Usuario' : 'Novo Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  label: Text('Nome'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  label: Text('Email'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ValueListenableBuilder(
                valueListenable: tipoUser,
                builder: (context, value, child) {
                  return DropdownButton<String>(
                    onChanged: (newValue) {
                      tipoUser.value = newValue!;
                    },
                    value: tipoUser.value,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'padrao',
                        child: Text('Padrão'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'agente',
                        child: Text('Agente'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: () async {
                var valida = validaCampos(
                    email: emailController.text, nome: nomeController.text);
                if (valida.isNotEmpty) {
                  showOkAlertDialog(
                    context: context,
                    message: 'Verifique : $valida',
                    title: 'Atenção',
                  );
                } else {
                  if (hasData) {
                    data.nome = nomeController.text;
                    data.tipo = tipoUser.value;
                    data.email = emailController.text;
                    await controller
                        .setdata(data)
                        .then((value) => Navigator.of(context).pop());
                  } else {
                    await controller
                        .setdata(Usuario(
                          nome: nomeController.text,
                          email: emailController.text,
                          senha: '',
                          setores: [],
                          tipo: tipoUser.value,
                        ))
                        .then((value) => Navigator.of(context).pop());
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => initialData());
  }

  String validaCampos({required String email, required String nome}) {
    String retorno = '';
    if (EmailValidator.validate(email) == false) {
      return 'Email';
    }

    if (nome.length < 3) {
      return 'Nome';
    }

    return retorno;
  }

  void initialData() {
    controller.getData();
    notifyListeners();
  }

  void search() {
    controller.getData(filtroDescricao: searchQuery);
    isSearching = true;
    notifyListeners();
  }

  setSearching() {
    isSearching = true;
    notifyListeners();
  }

  void updateSearchQuery(String newQuery) {
    searchQuery = newQuery;

    if (newQuery.isEmpty) {
      search();
    }
    //notifyListeners();
  }

  void stopSearching() {
    _clearSearchQuery();

    isSearching = false;
    notifyListeners();
  }

  void _clearSearchQuery() {
    searchQueryController.clear();
    updateSearchQuery("");
    notifyListeners();
  }
}

class DialogSelecionaSetoresUsuario extends StatefulWidget {
  final Usuario data;
  final UsuarioController controller;

  const DialogSelecionaSetoresUsuario(
      {super.key, required this.data, required this.controller});

  @override
  State<DialogSelecionaSetoresUsuario> createState() =>
      _DialogSelecionaSetoresUsuarioState();
}

class _DialogSelecionaSetoresUsuarioState
    extends State<DialogSelecionaSetoresUsuario> {
  SetorController setorController = SetorController();
  ValueNotifier<List<Setor>> setores = ValueNotifier([]);
  @override
  void initState() {
    super.initState();
    setorController.getData().then((value) {
      setores.value = setorController.listaSetor
          .map(
            (e) => Setor(
              descricao: e.descricao,
              codigo: e.codigo,
              uid: e.uid,
              checkBox: (widget.data.setores
                  .where((st) => st == e.codigo)
                  .isNotEmpty),
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: setores,
      builder: (context, listaSetoresLocal, child) {
        return AlertDialog(
          title: const Text(
            'Editar Setores do Usuario',
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            height: 500,
            width: 500,
            child: ValueListenableBuilder(
                valueListenable: setores,
                builder: (context, listaSetoresLocal, child) {
                  return ListView.builder(
                    itemCount: setores.value.length,
                    itemBuilder: (context, index) {
                      Setor setor = setores.value[index];
                      return CheckboxListTile(
                        title: Text(setor.descricao),
                        subtitle: Text(setor.codigo),
                        onChanged: (value) {
                          if (value!) {
                            // usuario.setores.removeWhere((st) => st == setor.codigo);
                          } else {
                            // usuario.setores.add(setor.codigo);
                          }

                          setores.value[index].checkBox = value;

                          if (kDebugMode) {
                            print(
                              '${setor.descricao}||$value||${setor.checkBox}',
                            );
                          }
                          setState(() {});
                        },
                        value: setores
                            .value[index].checkBox, //checkSetor(setor.codigo),
                      );
                    },
                  );
                }),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Salvar'),
              onPressed: () async {
                Usuario usuario = widget.data;
                usuario.setores = setores.value
                    .where((setor) => setor.checkBox)
                    .map((e) => e.codigo)
                    .toList();
                await widget.controller
                    .setdata(usuario)
                    .then((value) => Navigator.of(context).pop());
              },
            ),
          ],
        );
      },
    );
  }
}
