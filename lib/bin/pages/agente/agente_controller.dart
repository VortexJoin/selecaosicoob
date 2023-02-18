// ignore_for_file: avoid_print

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:selecaosicoob/bin/model/setor_model.dart';
import 'package:selecaosicoob/bin/model/sla_model.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:selecaosicoob/bin/pages/atendimento/novo_page.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:uuid/uuid.dart';

import '../../model/ticket_model.dart';
import '../atendimento/visualiza_page.dart';

class AgenteController extends ChangeNotifier {
  final Usuario usuario;

  final bool onlyRead;
  AgenteController({required this.usuario, this.onlyRead = false});

  UsuarioController usuarioController = UsuarioController();
  TicketController ticketController = TicketController();
  SetorController setorController = SetorController();

  List<Ticket> _ticketsEspera = [];
  List<Ticket> _ticketsAtendimento = [];

  String _hasErrorEspera = '';
  String _hasErrorAtendimento = '';
  bool _isLoading = false;

  bool get hasErrorEspera => _hasErrorEspera.isNotEmpty;
  bool get hasErrorAtendimento => _hasErrorAtendimento.isNotEmpty;
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;

  List<Ticket> get dataEspera => _ticketsEspera;
  List<Ticket> get dataAtendimento => _ticketsAtendimento;

  String _selectedFilter = 'aberto';

  Future<String> getSetorName(String cod) async {
    String retorno = '';
    await setorController.getByCodigo(cod).then((value) {
      if (value == null) {
        retorno = 'Não encontrado ($cod)';
      } else {
        retorno = value.descricao;
      }
    }).onError((error, stackTrace) {
      print(error);
      retorno = 'Erro: $error';
    });

    return retorno;
  }

  Future<String> getUserCod(String cod, {bool showNaoEncontrado = true}) async {
    String retorno = '';
    await usuarioController.getByCodigo(cod).then((value) {
      if (value == null) {
        if (showNaoEncontrado) {
          retorno = 'Não encontrado ($cod)';
        } else {
          retorno = '';
        }
      } else {
        retorno = value.nome;
      }
    }).onError((error, stackTrace) {
      print(error);
      retorno = 'Erro: $error';
    });

    return retorno;
  }

  Widget pageRelatorio(List<Ticket> data) {
    return montaSLA(data, showAppBar: false);
  }

  Widget getIconbyStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'concluido':
        return Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
        );

      case 'atendimento':
        return Icon(
          Icons.work_history,
          color: Theme.of(context).colorScheme.onSurface,
        );

      default:
        return Icon(
          Icons.hourglass_empty,
          color: Theme.of(context).colorScheme.secondary,
        );
    }
  }

  setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  setErrorEspera(String error) {
    _hasErrorEspera = error;
    notifyListeners();
  }

  setNotLoad() {
    _isLoading = false;
    notifyListeners();
  }

  setisLoad() {
    _isLoading = true;
    notifyListeners();
  }

  setErrorAtendimento(String error) {
    _hasErrorAtendimento = error;
    notifyListeners();
  }

  getDataGeral() async {
    setisLoad();
    await ticketController.getBySetores(usuario.setores).then((value) {
      _ticketsEspera = value.where((e) => e.responsavel == null).toList();

      _ticketsAtendimento = value
          .where((e) =>
              e.responsavel != null &&
              e.responsavelatual!.toLowerCase() == usuario.codigo)
          .toList();

      notifyListeners();
      setNotLoad();
    }).onError((error, stackTrace) {
      setErrorEspera(error.toString());
      setErrorAtendimento(error.toString());
      if (kDebugMode) {
        print(error.toString());
      }
      setNotLoad();
    });
    setNotLoad();
  }

  Stream<List<Ticket>> streamWhereSelectedFilter() {
    if (_selectedFilter == 'aberto') {
      return streamAtendimentosPendentesNoSetor();
    } else if (_selectedFilter == 'concluido') {
      return streamGetMeusAtendimentosConcluidos();
    } else if (_selectedFilter == 'atendimento') {
      return streamGetMeusAtendimentosIniciados();
    } else if (_selectedFilter == 'meuschamadosabertos') {
      return streamMeusChamadosAbertos();
    } else if (_selectedFilter == 'meuschamadosconcluidos') {
      return streamMeusChamadosConcluidos();
    } else {
      return streamMeusProcessosAll();
    }
  }

  /// cliente@gmail.com

  Widget ticketOption({
    required Ticket data,
    required BuildContext context,
  }) {
    return PopupMenuButton(
      onSelected: (value) async {
        Ticket tmpTicket = data;
        if (value == 'visualizar') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisualizaTicket(
                codTicket: data.codigo,
                usuario: usuario,
              ),
            ),
          );
        }

        if (value == 'receber') {
          tmpTicket.inicioAtendimento ??= DateTime.now();

          if (tmpTicket.responsavel == null || tmpTicket.responsavel!.isEmpty) {
            tmpTicket.responsavel = usuario.codigo;
          }

          tmpTicket.responsavelatual = usuario.codigo;

          Mensagem? msg;

          if (tmpTicket.mensagem.isEmpty) {
            msg = Mensagem(
              datamensagem: DateTime.now(),
              usuario: usuario.codigo,
              uid: const Uuid().v4(),
              conteudo: 'Inicio do Atendimento',
            );
          } else {
            msg = Mensagem(
              datamensagem: DateTime.now(),
              usuario: usuario.codigo,
              uid: const Uuid().v4().split('-').first,
              conteudo: 'Usuario Assumiu Atendimento',
            );
          }

          tmpTicket.mensagem.add(
            msg,
          );
          tmpTicket.ultimamovimentacao = DateTime.now();

          tmpTicket.movimentacao.add(
            Movimentacao(
              uid: const Uuid().v4().split('-').first,
              usuarioenvio: usuario.codigo,
              usuariodefinido: usuario.codigo,
              datamovimento: DateTime.now(),
            ),
          );

          tmpTicket.status = "Atendimento";

          ticketController.setdata(tmpTicket);
        }
        if (value == 'tramitar') {
          _tramitarTicket(data: data, context: context);
        }

        if (value == 'finalizar') {
          _finalizarTicket(data: data, context: context);
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 'visualizar',
            child: Text("Visualizar"),
          ),
          PopupMenuItem(
            value: 'receber',
            enabled: (onlyRead) ? false : _selectedFilter == 'aberto',
            child: const Text("Receber"),
          ),
          PopupMenuItem(
            value: 'tramitar',
            enabled: (onlyRead) ? false : _selectedFilter == 'atendimento',
            child: const Text("Tramitar"),
          ),
          PopupMenuItem(
            value: 'finalizar',
            enabled: (onlyRead) ? false : _selectedFilter == 'atendimento',
            child: const Text("Finalizar"),
          ),
        ];
      },
    );
  }

  _finalizarTicket({
    required Ticket data,
    required BuildContext context,
  }) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController txtEdtAvaliacao = TextEditingController();
        ValueNotifier<int> nota = ValueNotifier(3);
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: SizedBox(
                height: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          'Deseja Realmente Finalizar ?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        'Avaliação',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: nota,
                      builder: (context, value, child) {
                        return RatingBar(
                          filledIcon: Icons.star,
                          emptyIcon: Icons.star_border,
                          onRatingChanged: (rate) {
                            value = rate.toInt();
                          },
                          initialRating: 3,
                          maxRating: 5,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: txtEdtAvaliacao,
                      decoration: const InputDecoration(
                        labelText: 'Avaliação do atendimento',
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const SizedBox(
                                width: 60,
                                child: Center(
                                  child: Text(
                                    'Não',
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ProgressDialog pd =
                                    ProgressDialog(context: context);
                                pd.show(msg: 'Carregando...');
                                Ticket tmpTicket = data;
                                tmpTicket.encerrado = DateTime.now();

                                tmpTicket.ultimamovimentacao = DateTime.now();

                                tmpTicket.mensagem.add(
                                  Mensagem(
                                    datamensagem: DateTime.now(),
                                    usuario: usuario.codigo,
                                    uid: const Uuid().v4().split('-').first,
                                    conteudo: 'Chamado Finalizado',
                                  ),
                                );

                                tmpTicket.movimentacao.add(
                                  Movimentacao(
                                    uid: const Uuid().v4().split('-').first,
                                    usuarioenvio: usuario.codigo,
                                    usuariodefinido: usuario.codigo,
                                    datamovimento: DateTime.now(),
                                  ),
                                );
                                tmpTicket.status = 'Concluido';
                                tmpTicket.avaliacao = Avaliacao(
                                  nota: nota.value,
                                  comentario: txtEdtAvaliacao.text,
                                );

                                ticketController.setdata(tmpTicket);

                                pd.close();
                                Navigator.pop(context);
                              },
                              child: const SizedBox(
                                width: 100,
                                child: Center(
                                  child: Text(
                                    'Sim',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  novoTicket({
    required BuildContext context,
  }) async {
    if (usuario.codigo.isEmpty) {
      showOkAlertDialog(
        context: context,
        message: 'Usuario não está logado no sistema!',
        title: 'Atenção',
      );
    } else {
      DateTime dtNow = DateTime.now();

      if (dtNow.hour >= 8 && dtNow.hour <= 17) {
        showDialog(
          context: context,
          builder: (context) {
            return NovoAtendimento(
              usuarioAbertura: usuario,
            );
          },
        );
      } else {
        showOkAlertDialog(
          context: context,
          message: 'Fora do horario de Atendimento',
          title: 'Atenção',
        );
      }
    }
  }

  novaMensagemTicket({
    required Ticket data,
    required BuildContext context,
  }) async {
    if (usuario.codigo.isEmpty) {
      showOkAlertDialog(
        context: context,
        message: 'Usuario não está logado no sistema!',
        title: 'Atenção',
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          TextEditingController txtEdtAvaliacao = TextEditingController();
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 250,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            'Nova Mensagem',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: txtEdtAvaliacao,
                        decoration: const InputDecoration(
                          labelText: 'Conteudo',
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      SizedBox(
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                                  ProgressDialog pd =
                                      ProgressDialog(context: context);
                                  pd.show(msg: 'Carregando...');
                                  Ticket tmpTicket = data;
                                  tmpTicket.ultimamovimentacao = DateTime.now();
                                  tmpTicket.mensagem.add(
                                    Mensagem(
                                      datamensagem: DateTime.now(),
                                      usuario: usuario.codigo,
                                      uid: const Uuid().v4().split('-').first,
                                      conteudo: txtEdtAvaliacao.text,
                                    ),
                                  );
                                  ticketController.setdata(tmpTicket);

                                  pd.close();
                                  Navigator.pop(context);
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  _tramitarTicket({
    required Ticket data,
    required BuildContext context,
  }) async {
    ProgressDialog pd = ProgressDialog(context: context);
    pd.show(msg: 'Carregando...');

    setorController.getData().then((value) async {
      setorController.listaSetor.removeWhere(
        (element) => element.codigo == data.setoratual,
      );

      await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            children: [
              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    'Selecione um Setor',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Wrap(
                children: setorController.listaSetor
                    .map(
                      (e) => ListTile(
                        title: Text(e.descricao),
                        subtitle: Text(e.codigo),
                        onTap: () {
                          Ticket tmpTicket = data;
                          tmpTicket.movimentacao.add(
                            Movimentacao(
                              uid: const Uuid().v4().split('-').first,
                              usuarioenvio: usuario.codigo,
                              usuariodefinido: usuario.codigo,
                              datamovimento: DateTime.now(),
                            ),
                          );
                          tmpTicket.mensagem.add(
                            Mensagem(
                              datamensagem: DateTime.now(),
                              usuario: usuario.codigo,
                              uid: const Uuid().v4().split('-').first,
                              conteudo: 'Movimentação de Setor',
                              movimentacaoSetor: true,
                            ),
                          );
                          tmpTicket.responsavel = null;
                          tmpTicket.status = "Aberto";
                          tmpTicket.setoratual = e.codigo;
                          ticketController.setdata(tmpTicket);
                          Navigator.pop(context);
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      );
    });

    pd.close();
  }

  Stream<List<Ticket>> streamAtendimentosPendentesNoSetor() => ticketController
      .getCollection()
      .where("setoratual",
          whereIn: (usuario.setores.isNotEmpty) ? usuario.setores : [''])
      .where("status", isEqualTo: 'Aberto')
      .where("responsavelatual", isNull: true)
      .snapshots()
      .map((x) => x.docs
          .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Stream<List<Ticket>> streamMeusChamadosAbertos() => ticketController
      .getCollection()
      .where("usuarioabertura", isEqualTo: usuario.codigo)
      .where("status", isNotEqualTo: 'Concluido')
      .snapshots()
      .map((x) => x.docs
          .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Stream<List<Ticket>> streamMeusChamadosConcluidos() => ticketController
      .getCollection()
      .where("usuarioabertura", isEqualTo: usuario.codigo)
      .where("status", isEqualTo: 'Concluido')
      .snapshots()
      .map((x) => x.docs
          .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Stream<List<Ticket>> streamGetMeusAtendimentosIniciados() => ticketController
      .getCollection()
      .where("responsavelatual", isEqualTo: usuario.codigo)
      .where("status", isEqualTo: 'Atendimento')
      .snapshots()
      .map((x) => x.docs.map((doc) {
            //print((doc.data() as Map<String, dynamic>).toString());

            return Ticket.fromJson(doc.data() as Map<String, dynamic>);
          }).toList());

  Stream<List<Ticket>> streamGetMeusAtendimentosConcluidos() => ticketController
      .getCollection()
      .where("responsavelatual", isEqualTo: usuario.codigo)
      .where("status", isEqualTo: 'Concluido')
      .snapshots()
      .map((x) => x.docs
          .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Stream<List<Ticket>> streamMeusProcessosAll() => ticketController
      .getCollection()
      .where("responsavelatual", isEqualTo: usuario.codigo)
      .snapshots()
      .map((x) => x.docs
          .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
          .toList());
}
