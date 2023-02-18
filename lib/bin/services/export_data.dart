import 'package:selecaosicoob/bin/services/utils_func.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/html.dart';

import '../model/ticket_model.dart';
import '../model/usuario_model.dart';

class ExportData {
  downloadExcel(List<Ticket> tickets, {bool comtitulo = true}) async {
    UsuarioController usuarioController = UsuarioController();
    List<Chamado> chamados = [];

    await usuarioController.getData().then((value) {
      chamados = tickets
          .where((x) => x.responsavelatual != null)
          .where((x) => x.inicioAtendimento != null)
          .where((x) => x.encerrado != null)
          .where((x) => x.avaliacao != null)
          .map((e) => Chamado(
              usuarioAtendimento: usuarioController.dados
                  .where((x) => e.responsavelatual! == x.codigo)
                  .first
                  .nome,
              abertura: e.abertura,
              tempoAtendimento: e.inicioAtendimento!,
              encerrado: e.encerrado!,
              nota: e.avaliacao!.nota,
              observacao: e.avaliacao!.comentario))
          .toList();
    });

    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // MONTAGEM DE CABEÇALHO
    if (comtitulo) {
      sheet.getRangeByName('A1:I1').merge();
      sheet.getRangeByName('A1:I1').cellStyle.backColor = '#00AE9d';
      sheet.getRangeByName('A1:I1').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('A1:I1').cellStyle.fontColor = '#FFFFFF';
      sheet.getRangeByName('A1:I1').cellStyle.fontSize = 14;
      sheet.getRangeByName('A1:I1').cellStyle.bold = true;
      sheet.getRangeByName('A1:I1').rowHeight = 30;
      sheet.getRangeByName('A1:I1').cellStyle.vAlign = VAlignType.center;

      sheet.getRangeByName('A1:I1').setText('Relatório SLA');

      sheet.getRangeByName('A2').setText('Usuário de Atendimento');
      sheet.getRangeByName('B2').setText('Abertura (Data-Hora)');
      sheet.getRangeByName('C2').setText('Inicio Atendimento (Data-Hora)');
      sheet.getRangeByName('D2').setText('Encerrado (Data-Hora)');
      sheet.getRangeByName('E2').setText('Tempo de Atendimento (8-17hrs)');
      sheet.getRangeByName('F2').setText('Tempo Corrido');
      sheet.getRangeByName('G2').setText('Tempo para Iniciar');
      sheet.getRangeByName('H2').setText('Nota');
      sheet.getRangeByName('I2').setText('Comentário');

      sheet.getRangeByName('A2:I2').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('A2:I2').columnWidth = 30;
      sheet.getRangeByName('A2:I2').rowHeight = 25;
      sheet.getRangeByName('A2:I2').cellStyle.vAlign = VAlignType.center;
      sheet.getRangeByName('A2:I2').cellStyle.backColor = '#f2f2f2';

      sheet.getRangeByName('h2').columnWidth = 18;
    } else {
      sheet.getRangeByName('A1').setText('Usuário de Atendimento');
      sheet.getRangeByName('B1').setText('Abertura (Data-Hora)');
      sheet.getRangeByName('C1').setText('Inicio Atendimento (Data-Hora)');
      sheet.getRangeByName('D1').setText('Encerrado (Data-Hora)');
      sheet.getRangeByName('E1').setText('Tempo de Atendimento (8-17hrs)');
      sheet.getRangeByName('F1').setText('Tempo Corrido');
      sheet.getRangeByName('G1').setText('Tempo para Iniciar');
      sheet.getRangeByName('H1').setText('Nota');
      sheet.getRangeByName('I1').setText('Comentário');

      sheet.getRangeByName('A1:I1').cellStyle.hAlign = HAlignType.center;
      sheet.getRangeByName('A1:I1').columnWidth = 30;
      sheet.getRangeByName('A1:I1').rowHeight = 25;
      sheet.getRangeByName('A1:I1').cellStyle.vAlign = VAlignType.center;
      sheet.getRangeByName('A1:I1').cellStyle.backColor = '#f2f2f2';
      sheet.getRangeByName('H1').columnWidth = 18;
    }

    for (int i = 0; i < chamados.length; i++) {
      Chamado chamado = chamados[i];
      int row = (comtitulo) ? i + 3 : i + 2;

      // var diferencaTempoTotal = Utils.diferencaEntreDatas(
      //   chamado.abertura,
      //   chamado.encerrado,
      // );

      var diferencaTempoTotal = DiffDate().calcularDiferenca(
        chamado.abertura,
        chamado.encerrado,
        [],
      );

      print(diferencaTempoTotal);

      var diferencaTempoAtendimento =
          chamado.tempoAtendimento.difference(chamado.abertura);

      // TESTEEE
      diferencaTempoAtendimento = Utils.diferencaEntreDatas(
        chamado.abertura,
        chamado.encerrado,
      );
      sheet.getRangeByIndex(row, 1).setText(chamado.usuarioAtendimento);
      sheet.getRangeByIndex(row, 2).numberFormat = 'dd/mm/yyyy HH:mm:ss';
      sheet.getRangeByIndex(row, 2).setDateTime(chamado.abertura);
      sheet.getRangeByIndex(row, 3).numberFormat = 'dd/mm/yyyy HH:mm:ss';
      sheet.getRangeByIndex(row, 3).setDateTime(chamado.tempoAtendimento);
      sheet.getRangeByIndex(row, 4).numberFormat = 'dd/mm/yyyy HH:mm:ss';
      sheet.getRangeByIndex(row, 4).setDateTime(chamado.encerrado);

      sheet.getRangeByIndex(row, 5).setDateTime(DateTime(
            chamado.abertura.year,
            chamado.abertura.month,
            chamado.abertura.day,
            0,
            0,
            0,
          ).add(diferencaTempoTotal));
      sheet.getRangeByIndex(row, 5).numberFormat = 'HH:mm:ss';

      sheet.getRangeByIndex(row, 6).setFormula('=(D$row-B$row)');
      sheet.getRangeByIndex(row, 6).numberFormat = 'HH:mm:ss';

      sheet.getRangeByIndex(row, 7).setDateTime(DateTime(
            chamado.abertura.year,
            chamado.abertura.month,
            chamado.abertura.day,
            0,
            0,
            0,
          ).add(diferencaTempoAtendimento));
      sheet.getRangeByIndex(row, 7).numberFormat = 'HH:mm:ss';

      sheet.getRangeByIndex(row, 8).setValue(chamado.nota);
      sheet.getRangeByIndex(row, 9).setValue(chamado.observacao);

      for (int i = 1; i < 10; i++) {
        sheet.getRangeByIndex(row, i).cellStyle.hAlign = HAlignType.center;
      }
    }

    // Salvar o workbook em um blob
    final List<int> bytes = workbook.saveAsStream();
    final Blob blob = Blob([bytes], 'application/vnd.ms-excel');

    // Criar uma URL temporária para download do blob
    final url = Url.createObjectUrlFromBlob(blob);
    final anchor = AnchorElement(href: url);
    anchor.download =
        'SLA_${DateTime.now().microsecondsSinceEpoch.toString()}.xlsx';
    anchor.click();

    // Limpar a URL temporária
    Url.revokeObjectUrl(url);
  }
}

class Chamado {
  String usuarioAtendimento;
  DateTime abertura;
  DateTime tempoAtendimento;
  DateTime encerrado;
  int nota;
  String observacao;

  Chamado({
    required this.usuarioAtendimento,
    required this.abertura,
    required this.encerrado,
    required this.tempoAtendimento,
    required this.nota,
    required this.observacao,
  });
}
