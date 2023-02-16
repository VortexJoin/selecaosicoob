// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:selecaosicoob/bin/model/ticket_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

Widget montaSLA(List<Ticket> data, {bool showAppBar = true}) {
  List<SlaCalculator> slaCalc = data
      .where((tk) => tk.encerrado != null && tk.inicioAtendimento != null)
      .map(
        (e) => SlaCalculator(
          inicioChamado: e.abertura,
          terminoChamado: e.encerrado!,
          primeiraMensagem: e.inicioAtendimento!,
        ),
      )
      .toList();
  SlaStatistics slaStatistics = SlaStatistics(slaCalc);

  return SlaStatisticsScreen(
    slaStatistics: slaStatistics,
    showSLA: showAppBar,
  );
}

class SlaParams {
  final int atendimentoInicio; // hora de início do atendimento
  final int atendimentoFim; // hora de término do atendimento
  final int tempoMinimoResposta; // tempo mínimo de resposta em horas
  final int tempoMaximoResolucao; // tempo máximo de resolução em horas

  SlaParams({
    this.atendimentoInicio = 8,
    this.atendimentoFim = 17,
    this.tempoMinimoResposta = 2,
    this.tempoMaximoResolucao = 8,
  });
}

class SlaCalculator {
  bool cumpriuSla =
      false; // propriedade para indicar se o chamado cumpriu o SLA
  final DateTime inicioChamado;
  final DateTime terminoChamado;
  final DateTime primeiraMensagem;
  SlaParams? slaParams;
  SlaCalculator({
    this.slaParams,
    required this.inicioChamado,
    required this.terminoChamado,
    required this.primeiraMensagem,
  }) {
    slaParams ??= SlaParams();
    calcularSla();
  }

  // Método para calcular o SLA de um atendimento
  void calcularSla() {
    // Verifica se o horário de início do chamado está dentro do horário de atendimento
    if (inicioChamado.hour < slaParams!.atendimentoInicio ||
        inicioChamado.hour >= slaParams!.atendimentoFim) {
      print('O chamado foi iniciado fora do horário de atendimento.');
      return;
    }

    // Calcula a duração do chamado em horas
    var duracaoChamado = terminoChamado.difference(inicioChamado).inHours;

    // Verifica se o chamado ultrapassa o horário de atendimento
    if (terminoChamado.hour >= slaParams!.atendimentoFim) {
      // Adiciona o número de horas do próximo dia até o final do horário de atendimento
      duracaoChamado += (slaParams!.atendimentoFim - terminoChamado.hour) +
          (terminoChamado.day - inicioChamado.day - 1) * 24;
    }

    // Calcula a diferença de tempo entre o início do chamado e a primeira mensagem em horas
    final tempoResposta = primeiraMensagem.difference(inicioChamado).inHours;

    // Verifica se a duração do chamado está dentro do tempo máximo de resolução
    if (duracaoChamado > slaParams!.tempoMaximoResolucao) {
      print('O chamado excedeu o tempo máximo de resolução.');
      return;
    }

    // Verifica se o tempo de resposta está dentro do tempo mínimo de resposta
    if (tempoResposta < slaParams!.tempoMinimoResposta) {
      // Se a duração do chamado está dentro do tempo máximo de resolução, o SLA é considerado cumprido
      if (duracaoChamado <= slaParams!.tempoMaximoResolucao) {
        print('O SLA foi cumprido com sucesso.');
        cumpriuSla = true;
      } else {
        print(
            'O tempo de resposta foi inferior ao tempo mínimo esperado e o chamado excedeu o tempo máximo de resolução.');
      }
    } else {
      print('O SLA foi cumprido com sucesso.');
      cumpriuSla = true;
    }
  }
}

class SlaStatistics {
  final List<SlaCalculator> calculators;

  double porcentagemTempoResposta = 0;
  double porcentagemTempoAtendimento = 0;

  SlaStatistics(this.calculators) {
    _calcularPorcentagens();
  }

  void _calcularPorcentagens() {
    final cumpriramSla = calculators.where((c) => c.cumpriuSla).length;

    final totalChamados = calculators.length;

    porcentagemTempoResposta = (cumpriramSla / totalChamados) * 100;
    porcentagemTempoAtendimento = (1 - (porcentagemTempoResposta / 100)) * 100;

    print(
        'Porcentagem de sucesso do tempo de resposta: $porcentagemTempoResposta%');
    print(
        'Porcentagem de sucesso do tempo de atendimento: $porcentagemTempoAtendimento%');
  }
}

class _ChartData {
  final String label;
  final int value;

  _ChartData(this.label, this.value);
}

class SlaStatisticsScreen extends StatefulWidget {
  final SlaStatistics slaStatistics;
  final bool showSLA;
  final SlaParams? slaParams;

  const SlaStatisticsScreen(
      {Key? key,
      required this.slaStatistics,
      this.showSLA = true,
      this.slaParams})
      : super(key: key);

  @override
  SlaStatisticsScreenState createState() => SlaStatisticsScreenState();
}

class SlaStatisticsScreenState extends State<SlaStatisticsScreen> {
  late SlaParams slaParams;
  @override
  void initState() {
    if (widget.slaParams != null) {
      slaParams = widget.slaParams!;
    } else {
      slaParams = SlaParams();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.showSLA)
          ? AppBar(
              title: const Text('SLA Statistics'),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Porcentagem de sucesso do tempo de resposta: ${widget.slaStatistics.porcentagemTempoResposta.toStringAsFixed(2)}%',
            ),
            Text(
              'Porcentagem de sucesso do tempo de atendimento: ${widget.slaStatistics.porcentagemTempoAtendimento.toStringAsFixed(2)}%',
            ),
            SfCircularChart(
              series: <CircularSeries>[
                PieSeries<_ChartData, String>(
                  dataSource: [
                    _ChartData(
                        'Cumpriram SLA',
                        widget.slaStatistics.calculators
                            .where((c) => c.cumpriuSla)
                            .length),
                    _ChartData(
                        'Não cumpriram SLA',
                        widget.slaStatistics.calculators
                            .where((c) => !c.cumpriuSla)
                            .length),
                  ],
                  xValueMapper: (_ChartData data, _) => data.label,
                  yValueMapper: (_ChartData data, _) => data.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
            ),
            SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <ChartSeries>[
                ColumnSeries<_ChartData, String>(
                  dataSource: [
                    _ChartData(
                        'Cumpriram SLA',
                        widget.slaStatistics.calculators
                            .where((c) => c.cumpriuSla)
                            .length),
                    _ChartData(
                        'Não cumpriram SLA',
                        widget.slaStatistics.calculators
                            .where((c) => !c.cumpriuSla)
                            .length),
                  ],
                  xValueMapper: (_ChartData data, _) => data.label,
                  yValueMapper: (_ChartData data, _) => data.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Regras do SLA :\r\n'
                  '-Inicio do Atendimento : ${slaParams.atendimentoInicio}\r\n'
                  '-Fim do Atendimento : ${slaParams.atendimentoFim}\r\n'
                  '-Tempo Maximo de Solução : ${slaParams.tempoMaximoResolucao} \r\n'
                  '-Tempo Maximo de Resposta ${slaParams.tempoMinimoResposta} \r\n',
                  textAlign: TextAlign.start,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
