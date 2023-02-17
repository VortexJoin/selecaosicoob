import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:selecaosicoob/bin/pages/agente/agente_controller.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../model/setor_model.dart';
import '../../model/ticket_model.dart';

class NovoAtendimento extends StatefulWidget {
  final Usuario usuarioAbertura;
  const NovoAtendimento({
    Key? key,
    required this.usuarioAbertura,
  }) : super(key: key);

  @override
  State<NovoAtendimento> createState() => _NovoAtendimentoState();
}

class _NovoAtendimentoState extends State<NovoAtendimento> {
  late AgenteController agenteController;
  TextEditingController txtAssunto = TextEditingController();
  TextEditingController txtConteudo = TextEditingController();
  Setor? setorSelecionado;
  String urgencia = 'Baixa';

  @override
  void initState() {
    agenteController = AgenteController(usuario: widget.usuarioAbertura);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var size = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text(
        'Novo Ticket',
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        height: size.height - 100,
        width: size.width - 100,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: txtAssunto,
                decoration: const InputDecoration(
                  labelText: 'Assunto',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: txtConteudo,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Conteudo',
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownSearch<Setor>(
                asyncItems: (String filter) async {
                  await agenteController.setorController.getData();

                  return agenteController.setorController.listaSetor;
                },
                itemAsString: (Setor u) => u.descricao,
                onChanged: (Setor? data) {
                  setorSelecionado = data;
                },
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(labelText: "Setor"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownSearch<String>(
                items: const ["Baixa", "Media", 'Alta'],
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Urgência",
                    hintText: "Selecione a urgência",
                  ),
                ),
                onChanged: (sl) {
                  urgencia = sl ?? 'Baixa';
                },
                selectedItem: urgencia,
              )
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const SizedBox(
            width: 60,
            child: Center(
              child: Text(
                'Cancelar',
              ),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (validaCampos().isEmpty) {
              ProgressDialog pd = ProgressDialog(context: context);
              pd.show(msg: 'Carregando...');

              try {
                Ticket tmpTicket = Ticket(
                  assunto: txtAssunto.text,
                  conteudo: txtConteudo.text,
                  usuarioabertura: widget.usuarioAbertura.codigo,
                  abertura: DateTime.now(),
                  ultimamovimentacao: DateTime.now(),
                  setorinicial: setorSelecionado!.codigo,
                  setoratual: setorSelecionado!.codigo,
                  urgencia: urgencia,
                );
                agenteController.ticketController.setdata(tmpTicket);
                Navigator.pop(context);
                pd.close();
              } catch (e) {
                pd.close();
                showOkAlertDialog(
                  context: context,
                  message: 'Erro na solicitação\r\n$e',
                  title: 'Atenção',
                );
              }
            } else {
              showOkAlertDialog(
                context: context,
                message: validaCampos(),
                title: 'Atenção',
              );
            }
          },
          child: const SizedBox(
            width: 100,
            child: Center(
              child: Text(
                'Salvar',
              ),
            ),
          ),
        ),
      ],
    );
  }

  String validaCampos() {
    String retorno = '';

    if (txtConteudo.text.isEmpty) {
      retorno = 'Informe o conteudo';
    }

    if (txtAssunto.text.isEmpty) {
      retorno = 'Informe o Assunto';
    }

    if (setorSelecionado == null) {
      retorno = 'Selecione o Setor';
    }

    if (urgencia.isEmpty) {
      retorno = 'Informe a Urgencia';
    }

    return retorno;
  }
}
