import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bebe_service.dart';

class PdfService {
  // Cores do PDF (Design Médico Moderno)
  static const PdfColor _corPrimaria = PdfColor.fromInt(0xFF2E7D32); // Verde Médico Profundo
  static const PdfColor _corSecundaria = PdfColor.fromInt(0xFF81C784); // Verde Suave
  static const PdfColor _corFundoCabecalho = PdfColor.fromInt(0xFFF1F8E9); // Verde Muito Claro
  static const PdfColor _corTexto = PdfColor.fromInt(0xFF374151);
  static const PdfColor _corCinzaClaro = PdfColor.fromInt(0xFFF3F4F6);

  static Future<void> gerarRelatorioMedico() async {
    final doc = pw.Document();
    
    // 1. CARREGAR FONTES
    final fontRegular = await PdfGoogleFonts.latoRegular();
    final fontBold = await PdfGoogleFonts.latoBold();
    final fontTitulo = await PdfGoogleFonts.montserratBold();

    // 2. BUSCAR DADOS
    final dadosBebe = await BebeService.lerBebeAtivo();
    if (dadosBebe == null) return; 

    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;

    // Buscas paralelas para performance
    final results = await Future.wait([
      bebeRef.collection('vacinas').get(),
      bebeRef.collection('sintomas').orderBy('data', descending: true).limit(15).get(),
      bebeRef.collection('medidas').orderBy('data', descending: true).limit(15).get(),
      bebeRef.collection('consultas').orderBy('data', descending: true).limit(10).get(),
      bebeRef.collection('medicamentos').where('ativo', isEqualTo: true).get(),
    ]);

    final vacinasSnap = results[0];
    final sintomasSnap = results[1];
    final medidasSnap = results[2];
    final consultasSnap = results[3];
    final remediosSnap = results[4];

    // Preparar Resumo
    String ultimoPeso = "-";
    String ultimaAltura = "-";
    if (medidasSnap.docs.isNotEmpty) {
      final ultimaMedida = medidasSnap.docs.first.data();
      ultimoPeso = "${ultimaMedida['peso']} kg";
      ultimaAltura = "${ultimaMedida['altura']} cm";
    }

    // 3. MONTAR O DOCUMENTO
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            _buildCabecalho(dadosBebe, fontTitulo),
            pw.SizedBox(height: 20),
            
            _buildResumo(ultimoPeso, ultimaAltura, vacinasSnap.docs.length),
            pw.SizedBox(height: 30),

            if (remediosSnap.docs.isNotEmpty) ...[
              _buildSecaoTitulo("MEDICAMENTOS EM USO"),
              _buildTabelaRemedios(remediosSnap.docs),
              pw.SizedBox(height: 25),
            ],
            
            _buildSecaoTitulo("HISTÓRICO DE CRESCIMENTO"),
            _buildTabelaCrescimento(medidasSnap.docs),
            pw.SizedBox(height: 25),

            _buildSecaoTitulo("REGISTRO DE SINTOMAS"),
            _buildListaSintomas(sintomasSnap.docs),
            pw.SizedBox(height: 25),
            
            _buildSecaoTitulo("CARTEIRA DE VACINAÇÃO"),
            _buildListaVacinas(vacinasSnap.docs),
            pw.SizedBox(height: 25),

            _buildSecaoTitulo("CONSULTAS MÉDICAS"),
            _buildListaConsultas(consultasSnap.docs),
            
            pw.SizedBox(height: 40),
            _buildRodape(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Relatorio_Saude_${dadosBebe['nome']}.pdf',
    );
  }

  // --- COMPONENTES VISUAIS ---

  static pw.Widget _buildCabecalho(Map<String, dynamic> bebe, pw.Font fontTitulo) {
    DateTime dpp;
    if (bebe['data_parto'] is Timestamp) {
      dpp = (bebe['data_parto'] as Timestamp).toDate();
    } else {
      dpp = DateTime.parse(bebe['data_parto']);
    }
    
    final idadeMeses = DateTime.now().difference(dpp).inDays ~/ 30;

    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _corPrimaria, width: 2)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(bebe['nome'].toString().toUpperCase(), style: pw.TextStyle(font: fontTitulo, fontSize: 22, color: _corPrimaria)),
              pw.SizedBox(height: 4),
              pw.Text("Nascimento: ${DateFormat('dd/MM/yyyy').format(dpp)}", style: const pw.TextStyle(fontSize: 12)),
              pw.Text("Idade: $idadeMeses meses", style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text("RELATÓRIO DE SAÚDE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.grey700)),
              pw.Text("Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildResumo(String peso, String altura, int vacinas) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildCardResumo("Último Peso", peso),
        _buildCardResumo("Última Altura", altura),
        _buildCardResumo("Vacinas", "$vacinas doses"),
      ],
    );
  }

  static pw.Widget _buildCardResumo(String label, String valor) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: pw.BoxDecoration(
          color: _corFundoCabecalho,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label.toUpperCase(), style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _corPrimaria)),
            pw.SizedBox(height: 4),
            pw.Text(valor, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _corTexto)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSecaoTitulo(String titulo) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: _corPrimaria,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      width: double.infinity,
      child: pw.Text(titulo, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
    );
  }

  static pw.Widget _buildTabelaRemedios(List<QueryDocumentSnapshot> docs) {
    return pw.TableHelper.fromTextArray(
      headers: ['MEDICAMENTO', 'DOSAGEM', 'POSOLOGIA'],
      data: docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return [
          d['nome'],
          d['dosagem'],
          "${d['intervalo']} em ${d['intervalo']}h (${d['dias']} dias)"
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: _corSecundaria),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.all(6),
      border: null,
      oddRowDecoration: const pw.BoxDecoration(color: _corCinzaClaro),
    );
  }

  static pw.Widget _buildTabelaCrescimento(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return pw.Text("Sem registros.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey));

    return pw.TableHelper.fromTextArray(
      headers: ['DATA', 'PESO', 'ALTURA', 'PERÍMETRO'],
      data: docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return [
          DateFormat('dd/MM/yyyy').format(DateTime.parse(d['data'])),
          "${d['peso']} kg",
          "${d['altura']} cm",
          d['perimetro'] != null ? "${d['perimetro']} cm" : '-'
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: _corSecundaria),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.all(6),
      cellAlignment: pw.Alignment.center,
      border: null,
      oddRowDecoration: const pw.BoxDecoration(color: _corCinzaClaro),
    );
  }

  static pw.Widget _buildListaSintomas(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return pw.Text("Sem sintomas recentes.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey));

    return pw.Column(
      children: docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 6),
          padding: const pw.EdgeInsets.all(8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(left: pw.BorderSide(color: _corSecundaria, width: 3)),
            color: _corCinzaClaro,
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(width: 60, child: pw.Text(DateFormat('dd/MM').format(DateTime.parse(d['data'])), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Container(width: 100, child: pw.Text(d['tipo'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _corPrimaria))),
              pw.Expanded(child: pw.Text("${d['intensidade']} - ${d['detalhes']}", style: const pw.TextStyle(fontSize: 10))),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildListaVacinas(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return pw.Text("Nenhuma vacina registrada.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey));

    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: docs.map((doc) {
        String nome = doc.id.replaceAll('vac_', '').replaceAll('_', ' ').toUpperCase(); 
        if (nome.length > 25) nome = nome.substring(0, 25);
        
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: _corSecundaria),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(width: 6, height: 6, decoration: const pw.BoxDecoration(color: _corPrimaria, shape: pw.BoxShape.circle)),
              pw.SizedBox(width: 6),
              pw.Text(nome, style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  static pw.Widget _buildListaConsultas(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return pw.Text("Sem consultas recentes.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey));

    return pw.Column(
      children: docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Row(
            children: [
              pw.Container(width: 70, child: pw.Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(d['data'])), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Expanded(child: pw.Text("${d['especialidade']} - ${d['medico']}", style: const pw.TextStyle(fontSize: 10))),
            ],
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildRodape() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("Zelo - Saúde e Rotina Inteligente", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
            pw.Text("Documento gerado automaticamente", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          ]
        )
      ],
    );
  }
}