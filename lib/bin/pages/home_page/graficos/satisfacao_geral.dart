import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../model/ticket_model.dart';

class GrfSatisfacaoGeral extends StatefulWidget {
  final List<Ticket> tickets;
  const GrfSatisfacaoGeral({super.key, required this.tickets});

  @override
  State<GrfSatisfacaoGeral> createState() => _GrfSatisfacaoGeralState();
}

class _GrfSatisfacaoGeralState extends State<GrfSatisfacaoGeral> {
  double radiusColumn = 5;
  double widthColumn = .6;
  double spacingColumn = .3;

  @override
  Widget build(BuildContext context) {
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
      title: ChartTitle(text: 'Avaliações dos Atendimentos'),
      series: <CircularSeries>[
        PieSeries<_ChartData, String>(
          dataSource: [
            _ChartData(
                'Nota 1',
                widget.tickets
                    .where((x) => x.avaliacao != null)
                    .where((y) => y.avaliacao!.nota == 1)
                    .length),
            _ChartData(
                'Nota 2',
                widget.tickets
                    .where((x) => x.avaliacao != null)
                    .where((y) => y.avaliacao!.nota == 2)
                    .length),
            _ChartData(
                'Nota 3',
                widget.tickets
                    .where((x) => x.avaliacao != null)
                    .where((y) => y.avaliacao!.nota == 3)
                    .length),
            _ChartData(
                'Nota 4',
                widget.tickets
                    .where((x) => x.avaliacao != null)
                    .where((y) => y.avaliacao!.nota == 4)
                    .length),
            _ChartData(
                'Nota 5',
                widget.tickets
                    .where((x) => x.avaliacao != null)
                    .where((y) => y.avaliacao!.nota == 5)
                    .length),
          ],
          xValueMapper: (_ChartData data, _) => data.label,
          yValueMapper: (_ChartData data, _) => data.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}

class _ChartData {
  final String label;
  final int value;

  _ChartData(this.label, this.value);
}
