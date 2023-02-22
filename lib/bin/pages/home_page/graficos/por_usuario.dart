import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../main.dart';
import '../../../model/color_schema_app.dart';
import '../../../model/sla_model.dart';
import '../../../model/ticket_model.dart';

class GrfPorUsuario extends StatefulWidget {
  final List<Ticket> tickets;
  final TipoFiltro tipofiltro;
  const GrfPorUsuario({
    super.key,
    required this.tickets,
    this.tipofiltro = TipoFiltro.todos,
  });

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
    for (var ticket in tickets) {
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

  int totalTickets() {
    int total = 0;

    for (var a in qntPorChave.value) {
      total = total + a.quantidade;
    }

    return total;
  }

  startData() async {
    switch (widget.tipofiltro) {
      case TipoFiltro.todos:
        qntPorChave.value = await getChartData(
            widget.tickets.where((x) => x.responsavelatual != null).toList());
        break;
      case TipoFiltro.somenteAbertos:
        qntPorChave.value = await getChartData(widget.tickets
            .where((x) =>
                x.responsavelatual != null &&
                    x.status.toLowerCase() != 'concluido' ||
                x.status.toLowerCase() != 'finalizado' ||
                x.status.toLowerCase() != 'cancelado')
            .toList());
        break;
      case TipoFiltro.somenteFinalizados:
        qntPorChave.value = await getChartData(widget.tickets
            .where((x) =>
                x.responsavelatual != null &&
                    x.status.toLowerCase() == 'concluido' ||
                x.status.toLowerCase() == 'finalizado' ||
                x.status.toLowerCase() == 'cancelado')
            .toList());
        break;
      case TipoFiltro.aguardando:
        break;
    }
  }

  String titulo() {
    switch (widget.tipofiltro) {
      case TipoFiltro.todos:
        return 'Chamados';
      case TipoFiltro.somenteAbertos:
        return 'Chamados em Atendimento';
      case TipoFiltro.somenteFinalizados:
        return 'Chamados Finalizados';
      case TipoFiltro.aguardando:
        return 'Chamados em Espera';
    }
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
          title: ChartTitle(text: titulo()),
          series: <ChartSeries<QntPorChave, String>>[
            BarSeries(
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
            BarSeries(
              dataSource: [
                QntPorChave(quantidade: totalTickets(), chave: 'Total')
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
