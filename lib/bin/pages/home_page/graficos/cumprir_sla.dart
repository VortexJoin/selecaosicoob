import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../model/sla_model.dart';
import '../../../model/ticket_model.dart';
import '../../../services/export_data.dart';

class CumprirSLA extends StatefulWidget {
  final List<Ticket> tickets;
  const CumprirSLA({super.key, required this.tickets});

  @override
  State<CumprirSLA> createState() => _CumprirSLAState();
}

class _CumprirSLAState extends State<CumprirSLA> {
  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      tooltipBehavior: TooltipBehavior(
        enable: true,
        tooltipPosition: TooltipPosition.pointer,
      ),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: [
            ChartData(
                'Cumpriram SLA',
                processData(widget.tickets)
                    .calculators
                    .where((c) => c.cumpriuSla)
                    .length),
            ChartData(
                'Não cumpriram SLA',
                processData(widget.tickets)
                    .calculators
                    .where((c) => !c.cumpriuSla)
                    .length),
          ],
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}

SlaStatistics processData(List<Ticket> data) {
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

  return slaStatistics;
}

class GrfCumprirSLAColumn extends StatefulWidget {
  final List<Ticket> tickets;
  const GrfCumprirSLAColumn({super.key, required this.tickets});

  @override
  State<GrfCumprirSLAColumn> createState() => _GrfCumprirSLAColumnState();
}

class _GrfCumprirSLAColumnState extends State<GrfCumprirSLAColumn> {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        tooltipPosition: TooltipPosition.pointer,
      ),
      series: <ChartSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: [
            ChartData(
                'Cumpriram SLA',
                processData(widget.tickets)
                    .calculators
                    .where((c) => c.cumpriuSla)
                    .length),
            ChartData(
                'Não cumpriram SLA',
                processData(widget.tickets)
                    .calculators
                    .where((c) => !c.cumpriuSla)
                    .length),
          ],
          name: 'SLA',
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}

class TextoAnaliseStatistica extends StatefulWidget {
  final List<Ticket> tickets;
  const TextoAnaliseStatistica({
    super.key,
    required this.tickets,
  });

  @override
  State<TextoAnaliseStatistica> createState() => _TextoAnaliseStatisticaState();
}

class _TextoAnaliseStatisticaState extends State<TextoAnaliseStatistica> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
          width: 10,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 30,
          child: Text(
            'Porcentagem de sucesso do tempo de resposta: ${processData(widget.tickets).porcentagemTempoResposta.toStringAsFixed(2)}%',
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 30,
          child: Text(
            'Porcentagem de sucesso do tempo de atendimento: ${processData(widget.tickets).porcentagemTempoAtendimento.toStringAsFixed(2)}%',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 30,
          width: 30,
        ),
      ],
    );
  }
}

class TextInfoSLAParam extends StatefulWidget {
  final SlaParams slaParams;
  final List<Ticket> ticketsParaDownload;
  const TextInfoSLAParam(
      {super.key, required this.slaParams, required this.ticketsParaDownload});

  @override
  State<TextInfoSLAParam> createState() => _TextInfoSLAParamState();
}

class _TextInfoSLAParamState extends State<TextInfoSLAParam> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Regras do SLA :\r\n'
            '-Inicio do Atendimento : ${widget.slaParams.atendimentoInicio} hrs\r\n'
            '-Fim do Atendimento : ${widget.slaParams.atendimentoFim} hrs\r\n'
            '-Tempo Maximo de Solução : ${widget.slaParams.tempoMaximoResolucao} hrs\r\n'
            '-Tempo Maximo de Resposta ${widget.slaParams.tempoMinimoResposta} hrs\r\n',
            textAlign: TextAlign.start,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton(
              onPressed: () =>
                  ExportData().downloadExcel(widget.ticketsParaDownload),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  FaIcon(
                    FontAwesomeIcons.fileExcel,
                    color: Colors.green,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text('Download Excel'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
