import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../model/ticket_model.dart';

class GrfMovimentados extends StatefulWidget {
  final List<Ticket> tickets;
  const GrfMovimentados({super.key, required this.tickets});

  @override
  State<GrfMovimentados> createState() => _GrfMovimentadosState();
}

class _GrfMovimentadosState extends State<GrfMovimentados> {
  double radiusColumn = 5;
  double widthColumn = .6;
  double spacingColumn = .3;

  @override
  Widget build(BuildContext context) {
    int contaMovimentados = 0;
    int naoMovimentados = 0;
    for (var tk in widget.tickets) {
      if (tk.mensagem.isNotEmpty) {
        if (tk.mensagem
            .where((ee) => ee.movimentacaoSetor)
            .toList()
            .isNotEmpty) {
          contaMovimentados++;
        } else {
          naoMovimentados++;
        }
      }
    }

    return SfCircularChart(
      tooltipBehavior: TooltipBehavior(
        enable: true,
        tooltipPosition: TooltipPosition.pointer,
      ),
      legend: Legend(
        isVisible: true,
        alignment: ChartAlignment.center,
        position: LegendPosition.top,
        toggleSeriesVisibility: true,
      ),
      title: ChartTitle(text: 'Atendimentos movimentados entre setores'),
      series: <CircularSeries>[
        PieSeries<_ChartData, String>(
          dataSource: [
            _ChartData(
              'Movimentados',
              contaMovimentados,
            ),
            _ChartData(
              'Não Movimentados',
              naoMovimentados,
            ),
          ],
          xValueMapper: (_ChartData data, _) => data.label,
          yValueMapper: (_ChartData data, _) => data.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}
//movimentacaoSetor

class _ChartData {
  final String label;
  final int value;

  _ChartData(this.label, this.value);
}
