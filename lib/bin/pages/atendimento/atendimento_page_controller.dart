import 'package:flutter/material.dart';

import '../../model/ticket_model.dart';

class TicketPageController extends ChangeNotifier {
  final TicketController controller;
  TicketPageController(this.controller);

  TextEditingController searchQueryController = TextEditingController();
  bool isSearching = false;
  String searchQuery = "";

  Future<void> novo(
    BuildContext context, {
    Ticket? data,
  }) async {
    // bool hasData = data == null ? false : true;

    // TextEditingController nomeController = TextEditingController(
    //   text: hasData ? data.nome : '',
    // );
    // TextEditingController emailController = TextEditingController(
    //   text: hasData ? data.email : '',
    // );

    // ValueNotifier<String> tipoUser =
    //     ValueNotifier(hasData ? data.tipo : 'padrao');

    // await showDialog<void>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text(hasData ? 'Editar Usuario' : 'Novo Usuario'),
    //       content: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           TextFormField(
    //             controller: nomeController,
    //             decoration: const InputDecoration(
    //               label: Text('Nome'),
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           TextFormField(
    //             controller: emailController,
    //             decoration: const InputDecoration(
    //               label: Text('Email'),
    //             ),
    //           ),
    //           const SizedBox(
    //             height: 10,
    //           ),
    //           ValueListenableBuilder(
    //             valueListenable: tipoUser,
    //             builder: (context, value, child) {
    //               return DropdownButton<String>(
    //                 onChanged: (newValue) {
    //                   tipoUser.value = newValue!;
    //                 },
    //                 value: tipoUser.value,
    //                 items: const [
    //                   DropdownMenuItem<String>(
    //                     value: 'padrao',
    //                     child: Text('Padrão'),
    //                   ),
    //                   DropdownMenuItem<String>(
    //                     value: 'agente',
    //                     child: Text('Agente'),
    //                   ),
    //                 ],
    //               );
    //             },
    //           ),
    //         ],
    //       ),
    //       actions: <Widget>[
    //         TextButton(
    //           style: TextButton.styleFrom(
    //             textStyle: Theme.of(context).textTheme.labelLarge,
    //           ),
    //           child: const Text('Cancelar'),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //         TextButton(
    //           style: TextButton.styleFrom(
    //             textStyle: Theme.of(context).textTheme.labelLarge,
    //           ),
    //           child: const Text('Salvar'),
    //           onPressed: () async {
    //             if (hasData) {
    //               data.nome = nomeController.text;
    //               data.tipo = tipoUser.value;
    //               await controller
    //                   .setdata(data)
    //                   .then((value) => Navigator.of(context).pop());
    //             } else {
    //               await controller
    //                   .setdata(Usuario(
    //                     nome: nomeController.text,
    //                     email: emailController.text,
    //                     senha: '',
    //                     setores: [],
    //                     tipo: tipoUser.value,
    //                   ))
    //                   .then((value) => Navigator.of(context).pop());
    //             }
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );

    // Future.delayed(const Duration(milliseconds: 500))
    //     .then((value) => initialData());
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
