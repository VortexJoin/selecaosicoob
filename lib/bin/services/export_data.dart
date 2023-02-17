import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/html.dart';

import '../model/ticket_model.dart';
import '../model/usuario_model.dart';

class ExportData {
  downloadExcel(List<Ticket> tickets) async {
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
                satisfacao: e.avaliacao!.nota.toString(),
              ))
          .toList();
    });

    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1:E1').merge();
    sheet.getRangeByName('A1:E1').cellStyle.backColor = '#2ECC71';
    sheet.getRangeByName('A1:E1').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1:E1').cellStyle.fontColor = '#FFFFFF';
    sheet.getRangeByName('A1:E1').cellStyle.fontSize = 14;
    sheet.getRangeByName('A1:E1').cellStyle.bold = true;
    sheet.getRangeByName('A1:E1').rowHeight = 30;
    sheet.getRangeByName('A1:E1').cellStyle.vAlign = VAlignType.center;

    sheet.getRangeByName('A1:E1').setText('Relatorio SLA');

    sheet.getRangeByName('A2').setText('Usuário de Atendimento');
    sheet.getRangeByName('B2').setText('Abertura (Data-Hora)');
    sheet.getRangeByName('C2').setText('Inicio Atendimento (Data-Hora)');
    sheet.getRangeByName('D2').setText('Encerrado (Data-Hora)');
    sheet.getRangeByName('E2').setText('Satisfação');

    sheet.getRangeByName('A2:E2').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A2:E2').columnWidth = 30;
    sheet.getRangeByName('A2:E2').rowHeight = 25;
    sheet.getRangeByName('A2:E2').cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('A2:E2').cellStyle.backColor = '#f2f2f2';

    for (int i = 0; i < chamados.length; i++) {
      Chamado chamado = chamados[i];
      int row = i + 3;
      sheet.getRangeByIndex(row, 1).setText(chamado.usuarioAtendimento);

      sheet.getRangeByIndex(row, 2).numberFormat = 'dd/mm/yyyy HH:mm:ss';
      sheet.getRangeByIndex(row, 2).setDateTime(chamado.abertura);

      sheet.getRangeByIndex(row, 3).numberFormat = 'dd/mm/yyyy HH:mm:ss';
      sheet.getRangeByIndex(row, 3).setDateTime(chamado.tempoAtendimento);

      sheet.getRangeByIndex(row, 4).numberFormat = 'dd/mm/yyyy HH:mm:ss';
      sheet.getRangeByIndex(row, 4).setDateTime(chamado.encerrado);

      sheet.getRangeByIndex(row, 5).setText(chamado.satisfacao);

      for (int i = 1; i < 6; i++) {
        Style stylebody = sheet.getRangeByIndex(row, i).cellStyle;
        stylebody.hAlign = HAlignType.center;
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
  String satisfacao;

  Chamado({
    required this.usuarioAtendimento,
    required this.abertura,
    required this.encerrado,
    required this.tempoAtendimento,
    required this.satisfacao,
  });
}
