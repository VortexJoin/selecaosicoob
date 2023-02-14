// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:selecaosicoob/bin/pages/setor/view_list_setor_page.dart';
import 'package:selecaosicoob/bin/pages/usuario/usuario_list_page.dart';

import 'model/project_info_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var size = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(GetIt.instance<ProjectInfo>().nome),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              title: const Text('Setores'),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewListSetor(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Usuarios'),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewListUsuario(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'body',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
