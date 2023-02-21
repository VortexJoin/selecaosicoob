import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../model/sla_params.dart';

class Utils {
  static String capitalize(String subject, [bool lowerRest = false]) {
    if (subject.isEmpty) {
      return '';
    }

    if (lowerRest) {
      return subject[0].toUpperCase() + subject.substring(1).toLowerCase();
    } else {
      return subject[0].toUpperCase() + subject.substring(1);
    }
  }

  static showOkAlert(
    BuildContext context, {
    required String msg,
    required String title,
  }) =>
      showOkAlertDialog(
        context: context,
        message: msg,
        title: title,
      );

  static String formatDateymd(DateTime data) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    return dateFormat.format(data);
  }

  static String formatDatedmy(DateTime data) {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return dateFormat.format(data);
  }

  static Duration diferencaEntreDatas(DateTime data1, DateTime data2) {
    // Restringir a diferença apenas para dias úteis (segunda a sexta)
    if (data1.weekday == 6 || data1.weekday == 7) {
      data1 = data1.add(Duration(days: (8 - data1.weekday)));
      data1 = DateTime(
        data1.year,
        data1.month,
        data1.day,
        8,
      );
    } else if (data1.hour < 8) {
      data1 = DateTime(
        data1.year,
        data1.month,
        data1.day,
        8,
      );
    }

    if (data2.weekday == 6 || data2.weekday == 7) {
      data2 = data2.subtract(Duration(days: (data2.weekday - 5)));
      data2 = DateTime(data2.year, data2.month, data2.day,
          getIt<SlaParams>().atendimentoFim);
    } else if (data2.hour >= 17) {
      data2 = DateTime(data2.year, data2.month, data2.day,
          getIt<SlaParams>().atendimentoFim);
    }

    // Calcular a diferença entre as datas
    var diferenca = data2.difference(data1);

    // Restringir a diferença apenas para o horário comercial (8h às 17h)
    if (diferenca.isNegative) {
      diferenca = Duration.zero;
    } else {
      diferenca = Duration(
          hours: diferenca.inHours % 9,
          minutes: diferenca.inMinutes % 60,
          seconds: diferenca.inSeconds % 60);
    }

    return diferenca;
  }
}

class DiffDate {
// Função que verifica se uma data é feriado, baseado em uma lista de datas de feriados
  bool isFeriado(DateTime data, List<DateTime> feriados) {
    return feriados.any((feriado) =>
        data.year == feriado.year &&
        data.month == feriado.month &&
        data.day == feriado.day);
  }

// Função que calcula a diferença entre duas datas, em horas, minutos e segundos
  Duration calcularDiferenca(
      DateTime dataInicial, DateTime dataFinal, List<DateTime> feriados) {
    // Verifica se dataInicial é antes de dataFinal
    if (dataInicial.isAfter(dataFinal)) {
      throw ArgumentError("Data inicial deve ser anterior à data final.");
    }

    Duration diferencaTotal = Duration.zero;
    DateTime dataAtual = dataInicial;

    // Enquanto a data atual for anterior à data final, incrementa a diferença total de acordo com o tempo trabalhado no dia
    while (dataAtual.isBefore(dataFinal)) {
      // Verifica se a data atual é dia útil e não é feriado
      if (dataAtual.weekday >= 1 &&
          dataAtual.weekday <= 5 &&
          !isFeriado(dataAtual, feriados)) {
        DateTime inicioTrabalho = DateTime(dataAtual.year, dataAtual.month,
            dataAtual.day, getIt<SlaParams>().atendimentoInicio);
        DateTime fimTrabalho = DateTime(dataAtual.year, dataAtual.month,
            dataAtual.day, getIt<SlaParams>().atendimentoFim);

        // Verifica se o horário de início do trabalho é depois do horário inicial
        if (dataInicial.isAfter(fimTrabalho)) {
          inicioTrabalho = dataInicial;
        } else if (dataInicial.isAfter(inicioTrabalho)) {
          inicioTrabalho = dataInicial;
        }

        // Verifica se o horário de término do trabalho é antes do horário final
        if (dataFinal.isBefore(inicioTrabalho)) {
          fimTrabalho = dataFinal;
        } else if (dataFinal.isBefore(fimTrabalho)) {
          fimTrabalho = dataFinal;
        }

        // Calcula a diferença diária, levando em conta as horas de trabalho efetivo
        Duration diferencaDiaria = fimTrabalho.difference(inicioTrabalho);

        // Verifica se a diferença passou para o próximo dia
        if (fimTrabalho.day != inicioTrabalho.day) {
          if (kDebugMode) {
            print('diminui as horas');
          }
          // Adiciona a diferença de tempo trabalhado antes do fim do expediente
          diferencaDiaria = diferencaDiaria - const Duration(hours: 2);
        }

        // Adiciona a diferença diária à diferença total
        diferencaTotal += diferencaDiaria;
      }

      // Incrementa a data atual em um dia
      dataAtual = dataAtual.add(const Duration(days: 1));
    }

    return diferencaTotal;
  }
}
