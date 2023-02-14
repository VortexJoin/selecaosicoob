import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:selecaosicoob/bin/model/setor_model.dart';

import '../model/project_info_model.dart';

class ViewListSetor extends StatefulWidget {
  const ViewListSetor({super.key});

  @override
  State<ViewListSetor> createState() => _ViewListSetorState();
}

class _ViewListSetorState extends State<ViewListSetor> {
  @override
  void initState() {
    super.initState();
  }

  SetorController setorController = SetorController(loadSetores: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${GetIt.instance<ProjectInfo>().nome} - Setores'),
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: setorController,
            builder: (context, child) {
              if (setorController.isLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (setorController.hasError) {
                return Expanded(
                  child: Center(
                    child: Text(
                        'Ops, Não conseguimos carregar os dados.\r\n${setorController.error}'),
                  ),
                );
              } else if (setorController.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: setorController.listaSetor.length,
                    itemBuilder: (context, index) {
                      Setor setor = setorController.listaSetor[index];
                      return ListTile(
                        title: Text(setor.descricao),
                        subtitle: Text(setor.codigoSetor),
                        onTap: () {},
                        leading: const Icon(Icons.work_history),
                      );
                    },
                  ),
                );
              } else {
                return const Expanded(
                  child: Center(
                    child: Text('Não há dados'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
