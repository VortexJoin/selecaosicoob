import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:selecaosicoob/bin/model/ticket_model.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';

import '../../model/project_info_model.dart';
import '../../services/utils_func.dart';
import 'agente_controller.dart';

class PesquisaChamado extends StatefulWidget {
  final Usuario? usuario;
  const PesquisaChamado({
    super.key,
    this.usuario,
  });

  @override
  State<PesquisaChamado> createState() => _PesquisaChamadoState();
}

class _PesquisaChamadoState extends State<PesquisaChamado> {
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

  ValueNotifier<String> vnFiltro = ValueNotifier('codigo');

  FocusNode focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${GetIt.instance<ProjectInfo>().nome} - Pesquisa'),
      ),
      body: Column(
        children: [
          const SizedBox(width: 10, height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 80,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: vnFiltro,
                    builder: (context, value, child) {
                      return SizedBox(
                        width: 80,
                        height: 80,
                        child: PopupMenuButton<String>(
                          position: PopupMenuPosition.under,
                          onSelected: (value) {
                            vnFiltro.value = value;
                            textEditingController.clear();
                          },
                          child: Center(
                            child: Text(
                              'Filtro: \r\n${Utils.capitalize(vnFiltro.value)}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'codigo',
                              child: Text('Codigo'),
                            ),
                            const PopupMenuItem(
                              value: 'conteudo',
                              child: Text('Conteudo'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        label: Text('Pesquisar'),
                      ),
                      focusNode: focusNode,
                      maxLines: 1,
                      onFieldSubmitted: (value) {
                        ticketController.getByCodigo(value, setOnData: true);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: ticketController,
            builder: (context, child) {
              if (ticketController.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (!ticketController.hasData) {
                return const Center(
                  child: Text('Não Localizado'),
                );
              } else if (ticketController.hasError) {
                return Center(
                  child: Text('Erro na Solicitação ${ticketController.error}'),
                );
              } else if (ticketController.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: ticketController.dados.length,
                    itemBuilder: (context, index) {
                      Ticket data = ticketController.dados[index];
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
                        trailing: AgenteController(
                          usuario: Usuario(
                            nome: '',
                            email: '',
                            senha: '',
                          ),
                          onlyRead: true,
                        ).ticketOption(data: data, context: context),
                      );
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
