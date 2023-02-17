import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../model/sla_model.dart';
import '../../../model/ticket_model.dart';

class GrfPorUsuario extends StatefulWidget {
  final List<Ticket> tickets;
  const GrfPorUsuario({super.key, required this.tickets});

  @override
  State<GrfPorUsuario> createState() => _GrfPorUsuarioState();
}

class _GrfPorUsuarioState extends State<GrfPorUsuario> {
  double radiusColumn = 5;
  double widthColumn = .6;
  double spacingColumn = .3;
  UsuarioController usuarioController = UsuarioController();
  ValueNotifier<List<QntPorChave>> qntPorChave = ValueNotifier([]);

  Future<List<QntPorChave>> getChartData(List<Ticket> tickets) async {
    Map<String, int> data = {};
    for (var ticket in tickets.where((x) => x.responsavelatual != null)) {
      if (!data.containsKey(ticket.responsavelatual!)) {
        data[ticket.responsavelatual!] = 1;
      } else {
        data[ticket.responsavelatual!] = data[ticket.responsavelatual!]! + 1;
      }
    }

    List<QntPorChave> res = data.entries
        .map((entry) => QntPorChave(chave: entry.key, quantidade: entry.value))
        .toList();

    for (var re in res) {
      await usuarioController.getByCodigo(re.chave).then((value) {
        if (value != null) {
          re.chave = value.nome;
        } else {
          if (kDebugMode) {
            print('${re.chave} == USUARIO NÃO ENCONTRADO');
          }
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
          title: ChartTitle(text: 'Chamados em Atendimento'),
          series: <ChartSeries<QntPorChave, String>>[
            ColumnSeries(
              dataSource: qntPorChave.value,
              xValueMapper: (QntPorChave item, _) => item.chave,
              yValueMapper: (QntPorChave item, _) => item.quantidade,
              name: 'Por Usuario',
              borderRadius: BorderRadius.all(
                Radius.circular(radiusColumn),
              ),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                showZeroValue: true,
              ),
              width: widthColumn,
              spacing: spacingColumn,
              animationDuration: 800,
            ),
            ColumnSeries(
              dataSource: [
                QntPorChave(
                    quantidade: widget.tickets
                        .where((x) => x.responsavelatual != null)
                        .length,
                    chave: 'Total')
              ],
              xValueMapper: (QntPorChave item, _) => item.chave,
              yValueMapper: (QntPorChave item, _) => item.quantidade,
              name: 'Total',
              borderRadius: BorderRadius.all(
                Radius.circular(radiusColumn),
              ),
              color: Colors.green,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                showZeroValue: true,
              ),
              width: widthColumn,
              spacing: spacingColumn,
              animationDuration: 800,
            ),
          ],
        );
      },
    );
  }
}
