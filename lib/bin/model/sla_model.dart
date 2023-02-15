// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SLAChart extends StatelessWidget {
  final List<SLA> slaList;

  const SLAChart({super.key, required this.slaList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SLA Chart'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            series: <ChartSeries>[
              ColumnSeries<SLA, String>(
                dataSource: slaList,
                xValueMapper: (SLA sla, _) =>
                    '${sla.data.day}/${sla.data.month}/${sla.data.year}',
                yValueMapper: (SLA sla, _) => sla.percentualCumprido,
                name: 'SLA',
                enableTooltip: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// A classe SLA (Service Level Agreement) é usada para calcular o tempo de resposta,
/// tempo de solução e tempo de atendimento de um ticket de suporte com base no acordo
/// de nível de serviço (SLA) estabelecido entre o cliente e o provedor de suporte.
///
/// A classe requer as seguintes informações:
///
/// - data: a data em que o ticket de suporte foi criado.
/// - horaInicio: a hora em que o ticket de suporte foi criado.
/// - horaTermino: a hora em que o ticket de suporte foi resolvido.
/// - horaPrimeiraResposta: a hora em que o primeiro agente de suporte respondeu ao ticket.
/// - tempoMaximoResposta: a duração máxima permitida para a primeira resposta ao ticket (padrão: 2 horas).
/// - tempoMaximoSolucao: a duração máxima permitida para a solução do ticket (padrão: 8 horas).
/// - horaInicioExpediente: a hora de início do expediente de trabalho (padrão: 8:00).
/// - horaFimExpediente: a hora de término do expediente de trabalho (padrão: 18:00).
///
/// Os tempos de resposta, solução e atendimento são calculados automaticamente após a criação
/// de uma instância da classe. Os métodos percentualDeResposta, percentualDeSolucao e
/// percentualCumprido são usados para calcular o percentual cumprido do SLA em relação ao ticket
/// de suporte.
class SLA {
  DateTime data;
  DateTime horaInicio;
  DateTime horaTermino;
  DateTime horaPrimeiraResposta;
  Duration? tempoDeResposta;
  Duration? tempoDeSolucao;
  Duration? tempoDeAtendimento;
  final Duration tempoMaximoResposta;
  final Duration tempoMaximoSolucao;
  final DateTime horaInicioExpediente;
  final DateTime horaFimExpediente;
  SLA({
    this.tempoMaximoResposta = const Duration(hours: 2),
    this.tempoMaximoSolucao = const Duration(hours: 8),
    required this.data,
    required this.horaInicio,
    required this.horaTermino,
    required this.horaPrimeiraResposta,
    DateTime? horaInicioExpediente,
    DateTime? horaFimExpediente,
  })  : horaInicioExpediente = horaInicioExpediente ?? DateTime(0, 0, 0, 8),
        horaFimExpediente = horaFimExpediente ?? DateTime(0, 0, 0, 8) {
    if (horaInicio.isAfter(horaTermino)) {
      throw ArgumentError("horaInicio não pode ser depois de horaTermino");
    }
    if (horaPrimeiraResposta.isBefore(horaInicio)) {
      throw ArgumentError(
          "horaPrimeiraResposta não pode ser antes de horaInicio");
    }
    if (horaInicioExpediente!.isAfter(horaFimExpediente!)) {
      throw ArgumentError(
          "horaInicioExpediente não pode ser depois de horaFimExpediente");
    }
    calcularTempos();
  }

  /// Calcula os tempos de resposta, solução e atendimento com base no SLA definido e nas informações do ticket.
  void calcularTempos() {
    // TODO DEPURAR O CODIGO
    print('calculando-SLA--${data.toIso8601String()}');

    final tempoTotal = horaTermino.difference(horaInicio);
    tempoDeAtendimento = horaFimExpediente.difference(horaInicio);

    if (tempoDeAtendimento! < Duration.zero) {
      tempoDeAtendimento = Duration.zero;
    }

    final horaInicioExp = DateTime(
      data.year,
      data.month,
      data.day,
      horaInicioExpediente.hour,
      horaInicioExpediente.minute,
    );

    final horaFimExp = DateTime(
      data.year,
      data.month,
      data.day,
      horaFimExpediente.hour,
      horaFimExpediente.minute,
    );

    if (horaInicio.isBefore(horaInicioExp) || horaInicio.isAfter(horaFimExp)) {
      tempoDeResposta = horaInicioExp.difference(horaInicio);
      if (tempoDeResposta! > tempoMaximoResposta) {
        tempoDeResposta = tempoMaximoResposta;
      }
    } else {
      tempoDeResposta = Duration.zero;
    }

    if (tempoTotal < tempoDeAtendimento!) {
      tempoDeSolucao = tempoTotal;
      if (tempoDeSolucao! > tempoMaximoResposta) {
        tempoDeSolucao = tempoMaximoSolucao;
      }
    } else {
      tempoDeSolucao = tempoDeAtendimento! - tempoDeResposta!;
      if (tempoTotal - tempoDeResposta! - tempoDeSolucao! >
          tempoMaximoSolucao) {
        tempoDeSolucao = tempoMaximoSolucao;
        tempoDeResposta = tempoDeAtendimento! - tempoDeSolucao!;
      }
    }
  }

  /// Formata a duração em um formato legível para humanos (horas:minutos).
  String formatarTempo(Duration duracao) {
    final minutos = duracao.inMinutes % 60;
    final horas = duracao.inHours;
    return '$horas:${minutos.toString().padLeft(2, '0')}';
  }

  /// Retorna o percentual cumprido do SLA em relação ao tempo de resposta do ticket de suporte.
  double get percentualDeResposta {
    if (tempoDeResposta == null) {
      return 0;
    }
    final tempoTotal = horaTermino.difference(horaInicio);
    return tempoDeResposta!.inSeconds / tempoTotal.inSeconds;
  }

  /// Retorna o percentual cumprido do SLA em relação ao tempo de solução do ticket de suporte.
  double get percentualDeSolucao {
    if (tempoDeSolucao == null) {
      return 0;
    }
    final tempoTotal = horaTermino.difference(horaInicio);
    return tempoDeSolucao!.inSeconds / tempoTotal.inSeconds;
  }

  /// Retorna o percentual cumprido do SLA em relação ao tempo de atendimento do ticket de suporte.
  double get percentualCumprido {
    if (tempoDeAtendimento == null || tempoDeAtendimento == Duration.zero) {
      return 0;
    }
    final tempoDeAtendimentoEmMinutos = tempoDeAtendimento!.inMinutes;
    final tempoDeRespostaEmMinutos =
        tempoDeResposta != null ? tempoDeResposta!.inMinutes : 0;
    final percentual =
        ((tempoDeAtendimentoEmMinutos - tempoDeRespostaEmMinutos) /
                tempoDeAtendimentoEmMinutos) *
            100;
    return percentual;
  }
}


/*
Validar os valores de data e hora passados no construtor: a classe não realiza nenhuma validação nos valores passados no construtor, o que pode levar a comportamentos inesperados se os valores estiverem incorretos. Por exemplo, se a data for posterior à data de término, ou se a hora de início for posterior à hora de término, os tempos calculados pela classe não farão sentido.

ok- Melhorar o tratamento de erros: atualmente, a classe não lida muito bem com erros ou exceções. Seria útil adicionar tratamento de erros mais robusto para lidar com situações em que valores inválidos são passados para a classe, por exemplo.

ok - Tornar a classe mais flexível para diferentes cenários de atendimento: atualmente, a classe assume que o expediente começa e termina no mesmo dia e que o atendimento começa e termina dentro do horário de expediente. No entanto, em algumas situações, isso pode não ser verdade. Por exemplo, se o atendimento começar no final do expediente e terminar no início do expediente seguinte, os cálculos não serão precisos. Uma solução possível seria adicionar mais opções no construtor para permitir diferentes cenários de atendimento.


ok - Adicionar documentação: a classe também pode se beneficiar de documentação adicional, como comentários no código e uma descrição mais detalhada da finalidade da classe e como ela deve ser usada. Isso tornaria mais fácil para outros desenvolvedores entenderem e usarem a classe corretamente.

*/