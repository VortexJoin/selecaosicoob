import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../main.dart';
import '../../../model/color_schema_app.dart';
import '../../../model/setor_model.dart';
import '../../../model/sla_model.dart';
import '../../../model/ticket_model.dart';
import '../../../services/utils_func.dart';

class GrfQntPorAssunto extends StatefulWidget {
  final List<Ticket> tickets;

  const GrfQntPorAssunto({
    super.key,
    required this.tickets,
  });

  @override
  State<GrfQntPorAssunto> createState() => _GrfQntPorSetorState();
}

class _GrfQntPorSetorState extends State<GrfQntPorAssunto> {
  double radiusColumn = 3;
  double widthColumn = .6;
  double spacingColumn = .3;
  SetorController setorController = SetorController();
  ValueNotifier<List<QntPorChave>> qntPorChave = ValueNotifier([]);

  Future<List<QntPorChave>> getChartData(List<Ticket> tickets) async {
    Map<String, int> data = {};
    for (var ticket in tickets) {
      if (!data.containsKey(ticket.assunto.toLowerCase())) {
        data[ticket.assunto.toLowerCase()] = 1;
      } else {
        data[ticket.assunto.toLowerCase()] =
            data[ticket.assunto.toLowerCase()]! + 1;
      }
    }

    List<QntPorChave> res = data.entries
        .map((entry) => QntPorChave(
            chave: Utils.capitalize(entry.key), quantidade: entry.value))
        .toList();

    // for (var re in res) {
    //   await setorController.getByCodigo(re.chave).then((value) {
    //     if (value != null) {
    //       re.chave = value.descricao;
    //     }
    //   });
    // }

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
          title: ChartTitle(text: 'Chamados Por Assunto'),
          series: <ChartSeries<QntPorChave, String>>[
            BarSeries(
              dataSource: qntPorChave.value,
              xValueMapper: (QntPorChave item, _) => item.chave,
              yValueMapper: (QntPorChave item, _) => item.quantidade,
              name: 'Assunto',
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
          ],
        );
      },
    );
  }
}
