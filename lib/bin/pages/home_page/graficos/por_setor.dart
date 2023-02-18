import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../main.dart';
import '../../../model/color_schema_app.dart';
import '../../../model/setor_model.dart';
import '../../../model/sla_model.dart';
import '../../../model/ticket_model.dart';

class GrfQntPorSetor extends StatefulWidget {
  final List<Ticket> tickets;

  const GrfQntPorSetor({
    super.key,
    required this.tickets,
  });

  @override
  State<GrfQntPorSetor> createState() => _GrfQntPorSetorState();
}

class _GrfQntPorSetorState extends State<GrfQntPorSetor> {
  double radiusColumn = 3;
  double widthColumn = .6;
  double spacingColumn = .3;
  SetorController setorController = SetorController();
  ValueNotifier<List<QntPorChave>> qntPorChave = ValueNotifier([]);

  Future<List<QntPorChave>> getChartData(List<Ticket> tickets) async {
    Map<String, int> data = {};
    for (var ticket in tickets) {
      if (!data.containsKey(ticket.setoratual)) {
        data[ticket.setoratual] = 1;
      } else {
        data[ticket.setoratual] = data[ticket.setoratual]! + 1;
      }
    }

    List<QntPorChave> res = data.entries
        .map((entry) => QntPorChave(chave: entry.key, quantidade: entry.value))
        .toList();

    for (var re in res) {
      await setorController.getByCodigo(re.chave).then((value) {
        if (value != null) {
          re.chave = value.descricao;
        }
      });
    }

    return res;
  }

  @override
  void initState() {
    super.initState();

    startData();
  }

  startData() async {
    qntPorChave.value = await getChartData(widget.tickets);

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      qntPorChave.value = await getChartData(widget.tickets);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: qntPorChave,
      builder: (context, value, child) {
        return SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(),
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
          palette: getIt<CorPadraoTema>().allColors,
          title: ChartTitle(text: 'Chamados em Atendimento'),
          series: <ChartSeries<QntPorChave, String>>[
            BarSeries(
              dataSource: qntPorChave.value,
              xValueMapper: (QntPorChave item, _) => item.chave,
              yValueMapper: (QntPorChave item, _) => item.quantidade,
              name: 'Por Setor',
              borderRadius: BorderRadius.all(
                Radius.circular(radiusColumn),
              ),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                showZeroValue: true,
              ),
              // width: widthColumn,
              spacing: spacingColumn,
              animationDuration: 800,
            ),
            BarSeries(
              dataSource: [
                QntPorChave(quantidade: widget.tickets.length, chave: 'Total')
              ],
              xValueMapper: (QntPorChave item, _) => item.chave,
              yValueMapper: (QntPorChave item, _) => item.quantidade,
              name: 'Total',
              borderRadius: BorderRadius.all(
                Radius.circular(radiusColumn),
              ),
              color: getIt<CorPadraoTema>().terciaria,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                showZeroValue: true,
              ),
              //width: widthColumn,
              spacing: spacingColumn,
              animationDuration: 800,
            ),
          ],
        );
      },
    );
  }
}
