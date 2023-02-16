// ignore_for_file: avoid_print
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:selecaosicoob/bin/pages/atendimento/atendimento_list_page.dart';
import 'package:selecaosicoob/bin/pages/home_page/home_page_controller.dart';
import 'package:selecaosicoob/bin/pages/setor/setor_list_page.dart';
import 'package:selecaosicoob/bin/pages/usuario/usuario_list_page.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../model/project_info_model.dart';
import '../agente/agente_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  HomePageController controller = HomePageController();
  @override
  void initState() {
    super.initState();
  }

  TextEditingController txtEmailController = TextEditingController();

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
            ListTile(
              title: const Text('Atendimentos'),
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewAtendimentoPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 80,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 450,
                      child: TextFormField(
                        controller: txtEmailController,
                        decoration: const InputDecoration(
                          label: Text('E-mail'),
                        ),
                        maxLines: 1,
                        onFieldSubmitted: (value) => loginAtendimento(),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () => loginAtendimento(),
                      child: const Text('Acessar Area de Atendimento'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loginAtendimento() async {
    if (txtEmailController.text.isEmpty ||
        !EmailValidator.validate(txtEmailController.text)) {
      showOkAlertDialog(
        context: context,
        message: 'Verifique o E-mail',
        title: 'Atenção',
      );
    } else {
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(msg: 'Carregando...');
      controller.getUsuarioByEmail(txtEmailController.text).then((usr) {
        pd.close();
        if (usr == null) {
          showOkAlertDialog(
            context: context,
            message: 'Usuario não localizado!!',
            title: 'Atenção',
          );
        } else {
          showOkAlertDialog(
            context: context,
            message: 'Bem-Vindo ${usr.nome}',
            title: ':)',
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgenteView(usuario: usr),
            ),
          );
        }
      }).onError((error, stackTrace) {
        pd.close();
        showOkAlertDialog(
          context: context,
          message: 'Erro na solicitação $error',
          title: 'Atenção',
        );
      });
    }
  }
}



/*
TODO ANOTAÇÕES

Métricas
  Tempo médio de primeira resposta a um chamado
  Tempo médio entre cada contato com o cliente depois de iniciar o atendimento via chat ou mídia social
  Número médio de contatos necessários para resolver um problema
  Índice de problemas solucionados
  índice de satisfação do cliente;

Nivel de Serviço ( SLA )
  Tempo médio de primeira resposta a um chamado: 3 minutos
  Índice de problemas solucionados: 98%


*/