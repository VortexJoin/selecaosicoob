// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:selecaosicoob/bin/model/setor_model.dart';
import 'package:selecaosicoob/bin/model/sla_model.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:uuid/uuid.dart';

import '../../model/ticket_model.dart';

class AgenteController extends ChangeNotifier {
  final Usuario usuario;

  AgenteController({required this.usuario});

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

  Future<String> getUserCod(String cod) async {
    String retorno = '';
    await usuarioController.getByCodigo(cod).then((value) {
      if (value == null) {
        retorno = 'Não encontrado ($cod)';
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

      case 'atentimento':
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
    } else {
      return streamMeusProcessosAll();
    }
  }

  Widget ticketOption(Ticket data) {
    return PopupMenuButton(
      onSelected: (value) {
        Ticket tmpTicket = data;
        if (value == 'visualizar') {}

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
        if (value == 'enviarsetor') {}
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 'visualizar',
            child: Text("Visualizar"),
          ),
          PopupMenuItem(
            value: 'receber',
            enabled: _selectedFilter == 'aberto',
            child: const Text("Receber"),
          ),
          PopupMenuItem(
            value: 'tramitar',
            enabled: _selectedFilter == 'atendimento',
            child: const Text("Tramitar"),
          ),
        ];
      },
    );
  }

  Stream<List<Ticket>> streamAtendimentosPendentesNoSetor() => ticketController
      .getCollection()
      .where("setoratual", whereIn: usuario.setores)
      .where("status", isEqualTo: 'Aberto')
      .where("responsavelatual", isNull: true)
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
            print((doc.data() as Map<String, dynamic>).toString());

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
