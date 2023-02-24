import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:selecaosicoob/bin/model/ticket_model.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';

import '../../model/project_info_model.dart';
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

  TicketController ticketController = TicketController(initialLoad: true);

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
              child: TextFormField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  label: Text('Pesquisar'),
                ),
                focusNode: focusNode,
                maxLines: 1,
                onChanged: (x) {
                  if (x.isEmpty) {
                    ticketController.getData();
                  }
                },
                onEditingComplete: () {
                  ticketController.getData().then((x) {
                    ticketController.filterGeral(
                      textEditingController.text,
                    );
                  });
                },
              ),
            ),
          ),
          AnimatedBuilder(
            animation: ticketController,
            builder: (context, child) {
              if (ticketController.isLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (!ticketController.hasData) {
                return const Expanded(
                  child: Center(
                    child: Text('Não Localizado'),
                  ),
                );
              } else if (ticketController.hasError) {
                return Expanded(
                  child: Center(
                    child:
                        Text('Erro na Solicitação ${ticketController.error}'),
                  ),
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
                return Expanded(child: Container());
              }
            },
          ),
          AnimatedBuilder(
            animation: ticketController,
            builder: (context, child) {
              return Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(.5),
                    width: 1,
                  ),
                )),
                child: Row(
                  children: [
                    Text('Encontrados : ${ticketController.dados.length}')
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
