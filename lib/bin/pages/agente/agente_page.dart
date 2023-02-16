import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:selecaosicoob/bin/pages/agente/agente_controller.dart';

import '../../model/project_info_model.dart';

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
        title: Text(
            '${GetIt.instance<ProjectInfo>().nome} - Painel Administrativo'),
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: agenteController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                height: 80,
                width: size.width,
                child: Wrap(
                  spacing: 10,
                  children: [
                    FilterChip(
                      avatar: const Icon(Icons.schedule),
                      showCheckmark: false,
                      label: StreamBuilder(
                        stream: agenteController
                            .streamAtendimentosPendentesNoSetor(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Text(
                            'a Receber (${snapshot.data!.length})',
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      onSelected: (value) {
                        agenteController.setFilter('aberto');
                      },
                      selected: (agenteController.selectedFilter == 'aberto'),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.history),
                      showCheckmark: false,
                      label: StreamBuilder(
                        stream:
                            agenteController.streamGetMeusAtendimentosAbertos(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 30,
                              child: LinearProgressIndicator(),
                            );
                          }
                          return Text(
                            'em Atendimento (${snapshot.data!.length})',
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      onSelected: (value) {
                        agenteController.setFilter('atendimento');
                      },
                      selected:
                          (agenteController.selectedFilter == 'atendimento'),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.task_alt),
                      showCheckmark: false,
                      label: StreamBuilder(
                        stream: agenteController
                            .streamGetMeusAtendimentosConcluidos(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 30,
                              child: LinearProgressIndicator(),
                            );
                          }
                          return Text(
                            'Concluidos (${snapshot.data!.length})',
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      onSelected: (value) {
                        agenteController.setFilter('concluido');
                      },
                      selected:
                          (agenteController.selectedFilter == 'concluido'),
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              height: 200,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {},
                    splashColor: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                    child: baseContainer(
                      child: StreamBuilder(
                        stream: agenteController
                            .streamAtendimentosPendentesNoSetor(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 30,
                              child: LinearProgressIndicator(),
                            );
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Atendimentos em Aberto',
                                textAlign: TextAlign.center,
                                // style: theme.textTheme.titleLarge!.copyWith(
                                //    decoration: TextDecoration.underline),
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '${snapshot.data!.length}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge,
                                // style: theme.textTheme.titleMedium!.copyWith(
                                //     decoration: TextDecoration.underline),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const SizedBox(
                                width: 30,
                                child: LinearProgressIndicator(
                                    backgroundColor: Colors.transparent),
                              ),
                            ],
                          );
                        },
                      ),
                      cor: Colors.orange,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                    width: 15,
                  ),
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: baseContainer(
                      child: StreamBuilder(
                        stream:
                            agenteController.streamGetMeusAtendimentosAbertos(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Meus Atendimentos',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge,
                                // style: theme.textTheme.titleLarge!.copyWith(
                                //    decoration: TextDecoration.underline),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '${snapshot.data!.length}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge,
                                //  style: theme.textTheme.titleMedium!.copyWith(
                                //       decoration: TextDecoration.underline),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const SizedBox(
                                width: 30,
                                child: LinearProgressIndicator(
                                    backgroundColor: Colors.transparent),
                              ),
                            ],
                          );
                        },
                      ),
                      cor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          )
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
