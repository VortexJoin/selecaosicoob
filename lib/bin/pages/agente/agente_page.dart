// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:selecaosicoob/bin/pages/agente/agente_controller.dart';
import 'package:selecaosicoob/bin/services/utils_func.dart';

import '../../model/project_info_model.dart';
import '../../model/ticket_model.dart';

class AgenteView extends StatefulWidget {
  final Usuario usuario;
  const AgenteView({Key? key, required this.usuario}) : super(key: key);

  @override
  State<AgenteView> createState() => _AgenteViewState();
}

class _AgenteViewState extends State<AgenteView> {
  late AgenteController agenteController;

  @override
  void initState() {
    agenteController = AgenteController(usuario: widget.usuario);

    if (widget.usuario.tipo.toLowerCase() != 'agente') {
      agenteController.setFilter('meuschamados');
    }
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.usuario.setores.isEmpty && widget.usuario.tipo == 'agente' ||
          widget.usuario.tipo == 'tecnico' ||
          widget.usuario.tipo == 'supervisor') {
        Utils.showOkAlert(
          context,
          msg:
              'Não há setores definidos, portanto não há como receber novos atendimentos',
          title: 'Atenção',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var size = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${GetIt.instance<ProjectInfo>().nome} - Painel Administrativo'),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(.5),
            width: 1,
          ),
        )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilterChip(
                avatar: const Icon(Icons.search),
                showCheckmark: false,
                label: const Text(
                  'Pesquisa de Tickets',
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
                onSelected: (value) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilterChip(
                avatar: const Icon(Icons.add),
                showCheckmark: false,
                label: const Text(
                  'Novo Chamado',
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                ),
                onSelected: (value) {
                  agenteController.novoTicket(context: context);
                },
              ),
            ),
          ],
        ),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            //height: 60,
            width: size.width,
            child: AnimatedBuilder(
              animation: agenteController,
              builder: (context, child) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Visibility(
                      visible: (widget.usuario.tipo.toLowerCase() != 'agente'),
                      child: FilterChip(
                        avatar: const Icon(Icons.schedule),
                        showCheckmark: false,
                        label: StreamBuilder(
                          stream: agenteController.streamMeusChamadosAbertos(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                width: 50,
                                //  height: 10,
                                child: LinearProgressIndicator(),
                              );
                            }
                            return Text(
                              'Meus Chamados Abertos (${snapshot.data!.length})',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            );
                          },
                        ),
                        onSelected: (value) {
                          agenteController.setFilter('meuschamadosabertos');
                        },
                        selected: (agenteController.selectedFilter ==
                            'meuschamadosabertos'),
                      ),
                    ),
                    Visibility(
                      visible: (widget.usuario.tipo.toLowerCase() != 'agente'),
                      child: FilterChip(
                        avatar: const Icon(Icons.schedule),
                        showCheckmark: false,
                        label: StreamBuilder(
                          stream:
                              agenteController.streamMeusChamadosConcluidos(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                width: 50,
                                //  height: 10,
                                child: LinearProgressIndicator(),
                              );
                            }
                            return Text(
                              'Meus Chamados Concluidos (${snapshot.data!.length})',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            );
                          },
                        ),
                        onSelected: (value) {
                          agenteController.setFilter('meuschamadosconcluidos');
                        },
                        selected: (agenteController.selectedFilter ==
                            'meuschamadosconcluidos'),
                      ),
                    ),
                    Visibility(
                      visible: (widget.usuario.tipo.toLowerCase() == 'agente'),
                      child: FilterChip(
                        avatar: const Icon(Icons.schedule),
                        showCheckmark: false,
                        label: StreamBuilder(
                          stream: agenteController
                              .streamAtendimentosPendentesNoSetor(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                width: 50,
                                //  height: 10,
                                child: LinearProgressIndicator(),
                              );
                            }
                            return Text(
                              'a Receber (${snapshot.data!.length})',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            );
                          },
                        ),
                        onSelected: (value) {
                          agenteController.setFilter('aberto');
                        },
                        selected: (agenteController.selectedFilter == 'aberto'),
                      ),
                    ),
                    Visibility(
                      visible: (widget.usuario.tipo.toLowerCase() == 'agente'),
                      child: FilterChip(
                        avatar: const Icon(Icons.history),
                        showCheckmark: false,
                        label: StreamBuilder(
                          stream: agenteController
                              .streamGetMeusAtendimentosIniciados(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                width: 50,
                                // height: 10,
                                child: LinearProgressIndicator(),
                              );
                            }
                            return Text(
                              'em Atendimento (${snapshot.data!.length})',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            );
                          },
                        ),
                        onSelected: (value) {
                          agenteController.setFilter('atendimento');
                        },
                        selected:
                            (agenteController.selectedFilter == 'atendimento'),
                      ),
                    ),
                    Visibility(
                      visible: (widget.usuario.tipo.toLowerCase() == 'agente'),
                      child: FilterChip(
                        avatar: const Icon(Icons.task_alt),
                        showCheckmark: false,
                        label: StreamBuilder(
                          stream: agenteController
                              .streamGetMeusAtendimentosConcluidos(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(
                                width: 50,
                                //  height: 10,
                                child: LinearProgressIndicator(),
                              );
                            }
                            return Text(
                              'Concluidos (${snapshot.data!.length})',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            );
                          },
                        ),
                        onSelected: (value) {
                          agenteController.setFilter('concluido');
                        },
                        selected:
                            (agenteController.selectedFilter == 'concluido'),
                      ),
                    ),
                    Visibility(
                      visible: (widget.usuario.tipo.toLowerCase() == 'agente'),
                      child: FilterChip(
                        avatar: const Icon(Icons.auto_graph_outlined),
                        showCheckmark: false,
                        label: const Text(
                          'Relatorios SLA',
                          overflow: TextOverflow.visible,
                          textAlign: TextAlign.center,
                        ),
                        onSelected: (value) {
                          agenteController.setFilter('sla');
                        },
                        selected: (agenteController.selectedFilter == 'sla'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: agenteController,
              builder: (context, child) {
                return StreamBuilder(
                  stream: agenteController.streamWhereSelectedFilter(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return SizedBox(
                        width: size.width / 2,
                        child: Text('Erro ao buscar!\r\n${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      return (agenteController.selectedFilter == 'sla')
                          ? agenteController.pageRelatorio(snapshot.data!)
                          : ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                Ticket ticket = snapshot.data![index];
                                bool changeColor = index % 2 == 0;

                                return Container(
                                  color: changeColor
                                      ? Colors.grey.shade100
                                      : Colors.grey.shade300,
                                  child: ListTile(
                                    title: Text(
                                        '${ticket.assunto} - ${ticket.codigo}'),
                                    subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FutureBuilder<String>(
                                          future: agenteController.getUserCod(
                                              ticket.usuarioabertura),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Text('- ');
                                            } else {
                                              return Text('- ${snapshot.data}');
                                            }
                                          },
                                        ),
                                        Text(
                                          '- ${DateFormat("dd/MM/yyy HH:mm:ss").format(ticket.abertura)}'
                                          ' ${(ticket.encerrado == null) ? '' : 'até ${DateFormat("dd/MM/yyy HH:mm:ss").format(ticket.encerrado!)}'}',
                                        ),
                                        Text(
                                          '- ${ticket.status}',
                                        ),
                                        FutureBuilder<String>(
                                          future: agenteController
                                              .getSetorName(ticket.setoratual),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Text('- ');
                                            } else {
                                              return Text('- ${snapshot.data}');
                                            }
                                          },
                                        ),
                                        Text(
                                          '- ${ticket.urgencia}',
                                        ),
                                      ],
                                    ),
                                    onTap: () {},
                                    leading: agenteController.getIconbyStatus(
                                      context,
                                      ticket.status,
                                    ),
                                    trailing: agenteController.ticketOption(
                                      data: ticket,
                                      context: context,
                                    ),
                                  ),
                                );
                              },
                            );
                    } else {
                      return const SizedBox(
                        child: Text('Sem Dados'),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget baseContainer({required Widget child, required Color cor}) {
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }
}
