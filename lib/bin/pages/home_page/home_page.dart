// ignore_for_file: avoid_print
import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:selecaosicoob/bin/model/sla_model.dart';
import 'package:selecaosicoob/bin/model/ticket_model.dart';
import 'package:selecaosicoob/bin/pages/home_page/home_page_controller.dart';
import 'package:selecaosicoob/bin/pages/setor/setor_list_page.dart';
import 'package:selecaosicoob/bin/pages/usuario/usuario_list_page.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../main.dart';
import '../../model/color_schema_app.dart';
import '../../model/project_info_model.dart';
import '../../services/export_data.dart';
import '../agente/agente_page.dart';
import '../agente/pesquisa_chamado_page.dart';
import 'graficos/cumprir_sla.dart';
import 'graficos/movimentados.dart';
import 'graficos/por_assunto.dart';
import 'graficos/por_setor.dart';
import 'graficos/por_usuario.dart';
import 'graficos/satisfacao_geral.dart';
import 'graficos/ultimos_dias.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TicketController ticketController = TicketController(
    initialLoad: true,
    showLoading: false,
  );

  //  final StreamController<List<Ticket>> readingStreamController =
  //   StreamController<List<Ticket>>();

  // Stream<List<Ticket>> get onStreamChange =>
  //     ticketController.streamProcessosAll();

  late Stream<List<Ticket>> _myStream;

  @override
  void initState() {
    super.initState();
    _myStream = ticketController.streamProcessosAll();

    getDataTimer();
  }

  getDataTimer() {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      //print('timer--${DateTime.now().toIso8601String()}');
      getData();
    });
  }

  getData() async {
    await ticketController.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(GetIt.instance<ProjectInfo>().nome),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PesquisaChamado(),
                ),
              );
            },
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () => login(),
            icon: const Icon(
              Icons.person,
            ),
          ),
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
            // ListTile(
            //   title: const Text('Atendimentos'),
            //   onTap: () async {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => const ViewAtendimentoPage(),
            //       ),
            //     );
            //   },
            // ),
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
            //height: 620,
            width: MediaQuery.of(context).size.width,
            child: AnimatedBuilder(
              animation: ticketController,
              builder: (context, child) {
                if (ticketController.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (ticketController.hasError) {
                  return Expanded(
                    child: Center(
                      child: Text(
                          'Ops, Não conseguimos carregar os dados.\r\n${ticketController.error}'),
                    ),
                  );
                } else if (ticketController.hasData) {
                  return Column(
                    children: [
                      TextoAnaliseStatistica(
                        tickets: ticketController.dados,
                      ),
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 400,
                            height: 400,
                            child: CumprirSLA(
                              tickets: ticketController.dados,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 400,
                            child: GrfCumprirSLAColumn(
                              tickets: ticketController.dados,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                            width: 30,
                          ),
                          TextInfoSLAParam(
                            ticketsParaDownload: ticketController.dados,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Wrap(
                          alignment: WrapAlignment.spaceAround,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            SizedBox(
                              width: 250,
                              height: 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: getIt<CorPadraoTema>().secundaria,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Total de Chamados',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      ticketController.dados.length.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 250,
                              height: 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: getIt<CorPadraoTema>().secundaria,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Total de Chamados Atendidos',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      ticketController.dados
                                          .where((x) => x.responsavel != null)
                                          .length
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 250,
                              height: 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: getIt<CorPadraoTema>().secundaria,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Total de Chamados em Espera',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Text(
                                      ticketController.dados
                                          .where((x) => x.responsavel == null)
                                          .length
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]),
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfQntPorSetor(
                              tickets: ticketController.dados,
                              tipofiltro: TipoFiltro.todos,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfQntPorSetor(
                              tickets: ticketController.dados,
                              tipofiltro: TipoFiltro.somenteFinalizados,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfQntPorSetor(
                              tickets: ticketController.dados,
                              tipofiltro: TipoFiltro.somenteAbertos,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfPorUsuario(
                              tickets: ticketController.dados,
                              tipofiltro: TipoFiltro.todos,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfPorUsuario(
                              tickets: ticketController.dados,
                              tipofiltro: TipoFiltro.somenteAbertos,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfPorUsuario(
                              tickets: ticketController.dados,
                              tipofiltro: TipoFiltro.somenteFinalizados,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfQntPorAssunto(
                              tickets: ticketController.dados,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfQntPorDia(
                              tickets: ticketController.dados,
                              qntDias: 7,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfQntPorDia(
                              tickets: ticketController.dados,
                              qntDias: 15,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfSatisfacaoGeral(
                              tickets: ticketController.dados,
                            ),
                          ),
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: GrfMovimentados(
                              tickets: ticketController.dados,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AnimatedBuilder(
                        animation: ticketController,
                        builder: (context, child) {
                          if (ticketController.hasData) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: OutlinedButton(
                                onPressed: () => ExportData()
                                    .downloadExcel(ticketController.dados),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    FaIcon(
                                      FontAwesomeIcons.fileExcel,
                                      color: Colors.green,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      child: Text('Download Excel'),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: SelectableText('Não há dados.'),
                  );
                }
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
            // height: 200,
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                  child: Text('Informações do Projeto'),
                ),
                GestureDetector(
                  onTap: () async {
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget graficosStream() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withOpacity(.5),
          width: 1,
        ),
      ),
      //height: 620,
      width: MediaQuery.of(context).size.width,
      child: LayoutBuilder(
        builder: (p0, p1) {
          return StreamBuilder(
            stream: _myStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: GestureDetector(
                    onDoubleTap: () {
                      _myStream = ticketController.streamProcessosAll();
                      setState(() {});
                      print('Reseting stream');
                    },
                    child: const CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: SelectableText(snapshot.error.toString()),
                );
              } else if (snapshot.hasData) {
                return Column(
                  children: [
                    TextoAnaliseStatistica(
                      tickets: snapshot.data!,
                    ),
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 400,
                          height: 400,
                          child: CumprirSLA(
                            tickets: snapshot.data!,
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          height: 400,
                          child: GrfCumprirSLAColumn(
                            tickets: snapshot.data!,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                          width: 30,
                        ),
                        TextInfoSLAParam(
                          ticketsParaDownload: snapshot.data!,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 400,
                          height: 300,
                          child: GrfQntPorSetor(
                            tickets: snapshot.data!,
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          height: 300,
                          child: GrfPorUsuario(
                            tickets: snapshot.data!,
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          height: 300,
                          child: GrfQntPorAssunto(
                            tickets: snapshot.data!,
                          ),
                        ),
                        SizedBox(
                          width: 400,
                          height: 300,
                          child: GrfQntPorDia(
                            tickets: snapshot.data!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: GrfSatisfacaoGeral(
                            tickets: snapshot.data!,
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: GrfMovimentados(
                            tickets: snapshot.data!,
                          ),
                        ),
                      ],
                    ),
                  ],
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
    );
  }

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
