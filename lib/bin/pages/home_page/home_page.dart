// ignore_for_file: avoid_print
import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:selecaosicoob/bin/model/sla_model.dart';
import 'package:selecaosicoob/bin/model/ticket_model.dart';
import 'package:selecaosicoob/bin/pages/atendimento/atendimento_list_page.dart';
import 'package:selecaosicoob/bin/pages/home_page/home_page_controller.dart';
import 'package:selecaosicoob/bin/pages/setor/setor_list_page.dart';
import 'package:selecaosicoob/bin/pages/usuario/usuario_list_page.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/project_info_model.dart';
import '../agente/agente_page.dart';
import 'graficos/movimentados.dart';
import 'graficos/por_setor.dart';
import 'graficos/por_usuario.dart';
import 'graficos/satisfacao_geral.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

  TicketController ticketController = TicketController();

  //  final StreamController<List<Ticket>> readingStreamController =
  //   StreamController<List<Ticket>>();

  // Stream<List<Ticket>> get onStreamChange =>
  //     ticketController.streamProcessosAll();

  late Stream<List<Ticket>> _myStream;

  @override
  void initState() {
    super.initState();

    _myStream = ticketController.streamProcessosAll();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(GetIt.instance<ProjectInfo>().nome),
        actions: [
          IconButton(
              onPressed: () => login(),
              icon: const Icon(
                Icons.person,
              ))
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              title: const Text('Login'),
              onTap: () => login(),
            ),
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
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(.5),
                width: 1,
              ),
            ),
            height: 620,
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(
              builder: (p0, p1) {
                return StreamBuilder(
                  stream: _myStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: SelectableText(snapshot.error.toString()),
                      );
                    } else if (snapshot.hasData) {
                      return montaSLA(snapshot.data!, showAppBar: false
                          //  showAppBar: false,
                          );
                    } else {
                      return const Center(
                        child: SelectableText('Não há dados.'),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(.5),
                width: 1,
              ),
            ),
            height: 600,
            width: MediaQuery.of(context).size.width,
            child: LayoutBuilder(
              builder: (ctx, contraints) {
                return StreamBuilder(
                  stream: _myStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: SelectableText(snapshot.error.toString()),
                      );
                    } else if (snapshot.hasData) {
                      return SingleChildScrollView(
                        child: Wrap(
                          children: [
                            SizedBox(
                              width: 600,
                              child: GrfQntPorSetor(
                                tickets: snapshot.data!,
                              ),
                            ),
                            SizedBox(
                              width: 600,
                              child: GrfPorUsuario(
                                tickets: snapshot.data!,
                              ),
                            ),
                            SizedBox(
                              width: 400,
                              child: GrfSatisfacaoGeral(
                                tickets: snapshot.data!,
                              ),
                            ),
                            SizedBox(
                              width: 400,
                              child: GrfMovimentados(
                                tickets: snapshot.data!,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(
                        child: SelectableText('Não há dados.'),
                      );
                    }
                  },
                );
              },
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(10),
          //   margin: const EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     border: Border.all(
          //       color: Colors.grey.withOpacity(.5),
          //       width: 1,
          //     ),
          //   ),
          //   height: 300,
          //   width: MediaQuery.of(context).size.width,
          //   child: StreamBuilder(
          //     stream: ticketController.streamProcessosAll(),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       } else if (snapshot.hasError) {
          //         return Center(
          //           child: SelectableText(snapshot.error.toString()),
          //         );
          //       } else if (snapshot.hasData) {
          //         return Wrap(
          //           children: [
          //             SizedBox(
          //               child: GrfPorUsuario(
          //                 tickets: snapshot.data!,
          //               ),
          //             ),
          //           ],
          //         );
          //       } else {
          //         return const Center(
          //           child: SelectableText('Não há dados.'),
          //         );
          //       }
          //     },
          //   ),
          // )

          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(.5),
                width: 1,
              ),
            ),
            height: 200,
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text('Informações do Projeto'),
                ),
                GestureDetector(
                  onDoubleTap: () async {
                    const url =
                        'https://github.com/ronaldojr1804/selecaosicoob';
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(url);
                    } else {
                      throw 'Não foi possível abrir o link $url';
                    }
                  },
                  child: const SelectableText(
                      'GitHub: https://github.com/ronaldojr1804/selecaosicoob'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

//
  void login() {
    showDialog(
      context: context,
      builder: (context) {
        return const LoginDialog();
      },
    );
  }
}

class LoginDialog extends StatefulWidget {
  const LoginDialog({Key? key}) : super(key: key);

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  TextEditingController txtEmailController = TextEditingController(
    text: 'ronaldo@gmail.com',
  );

  HomePageController controller = HomePageController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 200,
        width: 400,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
                width: 10,
              ),
              SizedBox(
                width: 400,
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
                height: 20,
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
          // showOkAlertDialog(
          //   context: context,
          //   message: 'Bem-Vindo ${usr.nome}',
          //   title: ':)',
          // );
          txtEmailController.clear();
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
