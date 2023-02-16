import 'package:flutter/foundation.dart';
import 'package:selecaosicoob/bin/model/setor_model.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';

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

  Stream<List<Ticket>> streamAtendimentosPendentesNoSetor() => ticketController
      .getCollection()
      .where("setoratual", arrayContainsAny: usuario.setores)
      .snapshots()
      .map((x) => x.docs
          .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Stream<List<Ticket>> streamGetMeusAtendimentosAbertos() => ticketController
      .getCollection()
      .where("responsavelatual", isEqualTo: usuario.codigo)
      .where("encerrado", isNull: true)
      .snapshots()
      .map((x) => x.docs
          .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

  Stream<List<Ticket>> streamGetMeusAtendimentosConcluidos() => ticketController
      .getCollection()
      .where("responsavelatual", isEqualTo: usuario.codigo)
      .where("status", isEqualTo: 'Concluido')
      .snapshots()
      .map((x) => x.docs
          .map((doc) => Ticket.fromJson(doc.data() as Map<String, dynamic>))
          .toList());
}
