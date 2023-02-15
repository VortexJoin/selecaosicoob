import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../model/sla_model.dart';
import '../../model/project_info_model.dart';
import '../../model/ticket_model.dart';
import 'atendimento_page_controller.dart';

class ViewAtendimentoPage extends StatefulWidget {
  const ViewAtendimentoPage({super.key});

  @override
  State<ViewAtendimentoPage> createState() => _ViewAtendimentoPageState();
}

class _ViewAtendimentoPageState extends State<ViewAtendimentoPage> {
  TicketController controller = TicketController(initialLoad: true);
  late TicketPageController pageController;

  @override
  void initState() {
    pageController = TicketPageController(controller);
    super.initState();
  }

  _buildTitle() {
    return Text('${GetIt.instance<ProjectInfo>().nome} - Tickets');
  }

  Widget _buildSearchField() {
    return Container(
      color: Colors.white,
      child: TextField(
        controller: pageController.searchQueryController,
        autofocus: true,
        //style: Theme.of(context).textTheme.bodyMedium,
        decoration: const InputDecoration(
          hintText: "Pesquisar ...",
          //hintStyle: Theme.of(context).textTheme.bodyMedium,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        onChanged: (query) => pageController.updateSearchQuery(query),
        onSubmitted: (value) => pageController.search(),
      ),
    );
  }

  int generateRandomInt(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(size.width, 60),
        child: AnimatedBuilder(
          animation: pageController,
          builder: (context, child) {
            return AppBar(
              leading: !pageController.isSearching
                  ? const BackButton()
                  : Container(),
              title: pageController.isSearching
                  ? _buildSearchField()
                  : _buildTitle(),
              actions: [
                IconButton(
                  icon: pageController.isSearching
                      ? const Icon(Icons.clear)
                      : const Icon(Icons.search),
                  onPressed: () {
                    if (!pageController.isSearching) {
                      pageController.setSearching();
                    } else {
                      pageController.stopSearching();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    pageController.novo(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller.setdata(
                      Ticket(
                        assunto: 'Abertura de chamado',
                        conteudo: 'muita coisa aqui dentro',
                        usuarioabertura: '01ca319e',
                        abertura: DateTime.now(),
                        ultimamovimentacao: DateTime.now(),
                        setorinicial: '3579008c',
                        setoratual: '3579008c',
                        tipo: 'Chamado',
                        urgencia: 'Alta',
                      ),
                      refreshData: true,
                    );
                  },
                  child: const Text('Insert Chamado Aberto'),
                ),
                ElevatedButton(
                  onPressed: () {
                    int dia = 15;

                    DateTime inicioAtendimento = DateTime(
                      2023,
                      02,
                      dia,
                      generateRandomInt(08, 10),
                      generateRandomInt(10, 30),
                      00,
                    );
                    DateTime encerrado = DateTime(
                      2023,
                      02,
                      dia,
                      generateRandomInt(10, 17),
                      generateRandomInt(1, 59),
                      00,
                    );

                    controller.setdata(
                      Ticket(
                          assunto: 'Abertura de chamado',
                          conteudo: 'muita coisa aqui dentro',
                          usuarioabertura: 'a6054d3c',
                          abertura: DateTime(2023, 02, dia, 8, 10, 00),
                          ultimamovimentacao: DateTime.now(),
                          setorinicial: '3579008c',
                          setoratual: '3579008c',
                          responsavel: '01ca319e',
                          responsavelatual: '01ca319e',
                          tipo: 'Chamado',
                          urgencia: 'Alta',
                          avaliacao: Avaliacao(
                              nota: 3, comentario: 'gostei do atendimento'),
                          encerrado: encerrado,
                          inicioAtendimento: inicioAtendimento,
                          status: 'Concluido',
                          movimentacao: [
                            Movimentacao(
                              uid: '128973jf',
                              usuarioenvio: '01ca319e',
                              usuariodefinido: '01ca319e',
                              datamovimento: DateTime(2023, 02, dia, 8, 50, 00),
                            )
                          ],
                          mensagem: [
                            Mensagem(
                                datamensagem:
                                    DateTime(2023, 02, dia, 8, 23, 00),
                                usuario: '01ca319e',
                                uid: '01893jfk',
                                conteudo: 'Inicio do atendimento'),
                            Mensagem(
                                datamensagem:
                                    DateTime(2023, 02, dia, 8, 25, 00),
                                usuario: '01ca319e',
                                uid: 'k39d783j',
                                conteudo: 'Aguardando retorno do cliente'),
                            Mensagem(
                                datamensagem:
                                    DateTime(2023, 02, dia, 8, 29, 00),
                                usuario: 'a6054d3c',
                                uid: '1092ui4j',
                                conteudo: 'Resposta do cliente'),
                            Mensagem(
                                datamensagem:
                                    DateTime(2023, 02, dia, 8, 50, 00),
                                usuario: '01ca319e',
                                uid: '8674jkn3',
                                conteudo: 'Fim do Atendimento'),
                          ]),
                      refreshData: true,
                    );
                  },
                  child: const Text('Insert Chamado Finalizado'),
                ),
                TextButton(
                    onPressed: () {
                      List<SlaCalculator> calculators = [];

                      controller.dados
                          .where((el) => el.status.toLowerCase() == 'concluido')
                          .toList()
                          .forEach((ticket) {
                        if (kDebugMode) {
                          print(ticket.codigo);
                          print(ticket.abertura);
                          print(ticket.inicioAtendimento!);
                        }

                        SlaCalculator slaCalc = SlaCalculator(
                            inicioChamado: ticket.abertura,
                            primeiraMensagem: ticket.inicioAtendimento!,
                            terminoChamado: ticket.encerrado!);

                        calculators.add(slaCalc);
                      });

                      SlaStatistics slaStatistics = SlaStatistics(calculators);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SlaStatisticsScreen(slaStatistics: slaStatistics),
                        ),
                      );
                    },
                    child: const Text('Calculo SLA'))
              ],
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              if (controller.isLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (controller.hasError) {
                return Expanded(
                  child: Center(
                    child: Text(
                        'Ops, Não conseguimos carregar os dados.\r\n${controller.error}'),
                  ),
                );
              } else if (controller.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: controller.dados.length,
                    itemBuilder: (context, index) {
                      Ticket data = controller.dados[index];
                      return ListTile(
                        title: Text('${data.assunto} - ${data.codigo}'),
                        subtitle: Text(
                          '- ${DateFormat("dd/MM/yyy hh:mm:ss").format(data.abertura)}\r\n'
                          '- ${data.status}\r\n'
                          '- ${data.tipo}\r\n'
                          '- ${data.urgencia}\r\n',
                        ),
                        onTap: () {},
                        leading: const Icon(Icons.work_history),
                        trailing: IconButton(
                          onPressed: () {
                            pageController.novo(context, data: data);
                          },
                          icon: const Icon(Icons.edit),
                        ),
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
