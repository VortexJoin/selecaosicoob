import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:selecaosicoob/bin/pages/agente/agente_controller.dart';

import '../../model/ticket_model.dart';

class VisualizaTicket extends StatefulWidget {
  final String codTicket;
  final bool showappBar;
  final Usuario? usuario;
  const VisualizaTicket({
    super.key,
    this.showappBar = true,
    required this.codTicket,
    this.usuario,
  });

  @override
  State<VisualizaTicket> createState() => _VisualizaTicketState();
}

class _VisualizaTicketState extends State<VisualizaTicket> {
  late AgenteController agenteController;
  TicketController ticketController = TicketController();

  @override
  void initState() {
    agenteController = AgenteController(
      usuario: (widget.usuario == null)
          ? Usuario(nome: '', email: '', senha: '')
          : widget.usuario!,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var size = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    return Scaffold(
      appBar: (widget.showappBar)
          ? AppBar(
              title: Text('Atendimento - ${widget.codTicket}'),
            )
          : null,
      body: StreamBuilder<Ticket?>(
        stream: ticketController.streamByCod(widget.codTicket),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 50,
              child: LinearProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return SizedBox(
              width: size.width / 2,
              child: SelectableText('Erro ao buscar!\r\n${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText('Assunto : ${snapshot.data!.assunto}'),
                    Text(
                      'Data: ${DateFormat("dd/MM/yyy hh:mm:ss").format(snapshot.data!.abertura)}'
                      ' ${(snapshot.data!.encerrado == null) ? '' : 'até ${DateFormat("dd/MM/yyy hh:mm:ss").format(snapshot.data!.encerrado!)}'}',
                    ),
                    SelectableText('Conteudo: ${snapshot.data!.conteudo}'),
                    FutureBuilder<String>(
                      future: agenteController.getUserCod(
                          snapshot.data!.responsavel ?? '',
                          showNaoEncontrado: false),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('Responsavel: ');
                        } else {
                          return Text('Responsavel: ${snapshot.data}');
                        }
                      },
                    ),
                    FutureBuilder<String>(
                      future: agenteController.getUserCod(
                          snapshot.data!.responsavelatual ?? '',
                          showNaoEncontrado: false),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('Responsavel Atual: ');
                        } else {
                          return Text('Responsavel Atual: ${snapshot.data}');
                        }
                      },
                    ),
                    FutureBuilder<String>(
                      future: agenteController.getUserCod(
                          snapshot.data!.usuarioabertura,
                          showNaoEncontrado: false),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('Solicitante: ');
                        } else {
                          return Text('Solicitante: ${snapshot.data}');
                        }
                      },
                    ),
                    SelectableText('Status : ${snapshot.data!.status}'),
                    SelectableText('Urgencia : ${snapshot.data!.urgencia}'),
                    FutureBuilder<String>(
                      future: agenteController
                          .getSetorName(snapshot.data!.setorinicial),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('Setor Inicial : ');
                        } else {
                          return Text('Setor Inicial : ${snapshot.data}');
                        }
                      },
                    ),
                    FutureBuilder<String>(
                      future: agenteController
                          .getSetorName(snapshot.data!.setoratual),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('Setor Atual : ');
                        } else {
                          return Text('Setor Atual : ${snapshot.data}');
                        }
                      },
                    ),
                    (snapshot.data!.avaliacao == null)
                        ? const SelectableText('Avaliação : Não há')
                        : SelectableText(
                            'Avaliação : ${snapshot.data!.avaliacao!.nota} | ${snapshot.data!.avaliacao!.comentario}',
                          ),
                    const SelectableText(''),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SelectableText('Mensagens :'),
                        ElevatedButton(
                          onPressed: () {
                            agenteController.novaMensagemTicket(
                              data: snapshot.data!,
                              context: context,
                            );
                          },
                          child: const Text('Nova Mensagem'),
                        )
                      ],
                    ),
                    const SelectableText(''),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                        minHeight: 100,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(.6),
                            width: 1,
                          ),
                          color: Colors.grey.shade100,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.mensagem.length,
                          itemBuilder: (context, index) {
                            Mensagem msg = snapshot.data!.mensagem[index];
                            return ListTile(
                              title: SelectableText(msg.conteudo),
                              subtitle: FutureBuilder<String>(
                                future: agenteController.getUserCod(
                                    snapshot.data!.responsavelatual ?? '',
                                    showNaoEncontrado: false),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return SelectableText(
                                      'Usuario: \r\n'
                                      '${DateFormat("dd/MM/yyy hh:mm:ss").format(msg.datamensagem)}',
                                    );
                                  } else {
                                    return SelectableText(
                                        'Usuario: ${snapshot.data}\r\n'
                                        '${DateFormat("dd/MM/yyy hh:mm:ss").format(msg.datamensagem)}');
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SelectableText(''),
                    const SelectableText('Movimento :'),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                        minHeight: 100,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(.6),
                            width: 1,
                          ),
                          color: Colors.grey.shade100,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100.withOpacity(0.5),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.movimentacao.length,
                          itemBuilder: (context, index) {
                            Movimentacao mov =
                                snapshot.data!.movimentacao[index];
                            return ListTile(
                              title: FutureBuilder<String>(
                                future: agenteController
                                    .getUserCod(mov.usuarioenvio),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SelectableText(
                                      'Usuario:',
                                    );
                                  } else {
                                    return SelectableText(
                                        'Usuario: ${snapshot.data}');
                                  }
                                },
                              ),
                              subtitle: SelectableText(
                                  DateFormat("dd/MM/yyy hh:mm:ss")
                                      .format(mov.datamovimento)),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SizedBox(
              width: size.width / 2,
              child: const SelectableText('Não Localizado'),
            );
          }
        },
      ),
    );
  }
}
