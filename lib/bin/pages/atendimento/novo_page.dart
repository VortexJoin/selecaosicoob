import 'package:flutter/material.dart';

class NovoAtendimento extends StatefulWidget {
  const NovoAtendimento({Key? key}) : super(key: key);

  @override
  State<NovoAtendimento> createState() => _NovoAtendimentoState();
}

class _NovoAtendimentoState extends State<NovoAtendimento> {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var size = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Novo Ticket'),
      content: SizedBox(
        height: size.height - 100,
        width: size.width - 100,
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
