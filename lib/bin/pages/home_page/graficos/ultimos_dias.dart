import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../main.dart';
import '../../../model/color_schema_app.dart';
import '../../../model/setor_model.dart';
import '../../../model/sla_model.dart';
import '../../../model/ticket_model.dart';
import '../../../services/utils_func.dart';

class GrfQntPorDia extends StatefulWidget {
  final List<Ticket> tickets;
  final int qntDias;

  const GrfQntPorDia({
    super.key,
    required this.tickets,
    this.qntDias = 7,
  });

  @override
  State<GrfQntPorDia> createState() => _GrfQntPorSetorState();
}

class _GrfQntPorSetorState extends State<GrfQntPorDia> {
  double radiusColumn = 3;
  double widthColumn = .6;
  double spacingColumn = .3;

  SetorController setorController = SetorController();
  ValueNotifier<List<QntPorChave>> qntPorChave = ValueNotifier([]);

  Future<List<QntPorChave>> getChartData(List<Ticket> tickets) async {
    DateTime dataFinal = DateTime.now().add(const Duration(days: 1));
    DateTime dataInicial =
        dataFinal.subtract(Duration(days: widget.qntDias + 1));

    List<Ticket> tmpTicket = tickets
        .where((ticket) =>
            ticket.abertura.isAfter(dataInicial) &&
            ticket.abertura.isBefore(dataFinal))
        .toList();

    qntTickets = tmpTicket.length;
    tmpTicket.sort((a, b) => a.abertura.compareTo(b.abertura));

    Map<String, int> data = {};
    for (var ticket in tmpTicket) {
      if (!data.containsKey(Utils.formatDatedmy(ticket.abertura))) {
        data[Utils.formatDatedmy(ticket.abertura)] = 1;
      } else {
        data[Utils.formatDatedmy(ticket.abertura)] =
            data[Utils.formatDatedmy(ticket.abertura)]! + 1;
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

  int qntTickets = 0;

  @override
  void initState() {
    super.initState();

    startData();
  }

  startData() async {
    qntPorChave.value = await getChartData(widget.tickets);

    // Timer.periodic(const Duration(seconds: 5), (timer) async {
    //   qntPorChave.value = await getChartData(widget.tickets);
    // });
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
          title: ChartTitle(text: 'Chamados Por Dia (${widget.qntDias} dias)'),
          series: <ChartSeries<QntPorChave, String>>[
            BarSeries(
              dataSource: qntPorChave.value,
              xValueMapper: (QntPorChave item, _) => item.chave,
              yValueMapper: (QntPorChave item, _) => item.quantidade,
              name: 'Chamados',
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
              dataSource: [QntPorChave(quantidade: qntTickets, chave: 'Total')],
              xValueMapper: (QntPorChave item, _) => item.chave,
              yValueMapper: (QntPorChave item, _) => item.quantidade,
              name: 'Total',
              borderRadius: BorderRadius.all(
                Radius.circular(radiusColumn),
              ),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                showZeroValue: true,
              ),
              color: getIt<CorPadraoTema>().terciaria,
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
