import 'package:flutter/material.dart';

import '../../model/setor_model.dart';

class SetorPageController extends ChangeNotifier {
  final SetorController setorController;
  SetorPageController(this.setorController);

  TextEditingController searchQueryController = TextEditingController();
  bool isSearching = false;
  String searchQuery = "";

  Future<void> novoSetor(
    BuildContext context, {
    Setor? setor,
  }) async {
    bool hasSetor = setor == null ? false : true;

    TextEditingController setorDescricaoController = TextEditingController(
      text: hasSetor ? setor.descricao : '',
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(hasSetor ? 'Editar Setor' : 'Novo Setor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: setorDescricaoController,
              )
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
              child: const Text('Salvar'),
              onPressed: () async {
                if (hasSetor) {
                  setor.descricao = setorDescricaoController.text;
                  await setorController
                      .setdata(setor)
                      .then((value) => Navigator.of(context).pop());
                } else {
                  await setorController
                      .setdata(Setor(descricao: setorDescricaoController.text))
                      .then((value) => Navigator.of(context).pop());
                }
              },
            ),
          ],
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 500))
        .then((value) => initialData());
  }

  void initialData() {
    setorController.getData();
    notifyListeners();
  }

  void search() {
    setorController.getData(filtroDescricao: searchQuery);
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
