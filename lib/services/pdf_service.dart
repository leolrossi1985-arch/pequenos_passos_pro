import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bebe_service.dart';

class PdfService {
  // Cores do PDF (Sage Green)
  static const PdfColor _corPrimaria = PdfColor.fromInt(0xFF6A9C89);
  static const PdfColor _corTexto = PdfColor.fromInt(0xFF374151);

  static Future<void> gerarRelatorioMedico() async {
    final doc = pw.Document();
    
    // 1. CARREGAR FONTES (Para acentos)
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    // 2. BUSCAR DADOS DO BEBÊ ATIVO
    final dadosBebe = await BebeService.lerBebeAtivo();
    if (dadosBebe == null) return; 

    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;

    // 3. BUSCAR DADOS DE SAÚDE
    final vacinasSnap = await bebeRef.collection('vacinas').get();
    final sintomasSnap = await bebeRef.collection('sintomas').orderBy('data', descending: true).limit(10).get();
    final medidasSnap = await bebeRef.collection('medidas').orderBy('data', descending: true).limit(10).get();
    final consultasSnap = await bebeRef.collection('consultas').orderBy('data', descending: true).limit(5).get();
    
    // NOVO: Buscar Remédios Ativos
    final remediosSnap = await bebeRef.collection('medicamentos').where('ativo', isEqualTo: true).get();

    // 4. MONTAR O DOCUMENTO
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildCabecalho(dadosBebe),
            pw.SizedBox(height: 20),
            
            // Seção de Medicamentos (NOVA)
            if (remediosSnap.docs.isNotEmpty) ...[
              _buildSecaoTitulo("Medicamentos em Uso"),
              _buildTabelaRemedios(remediosSnap.docs),
              pw.SizedBox(height: 20),
            ],
            
            _buildSecaoTitulo("Crescimento (Ultimos registros)"),
            _buildTabelaCrescimento(medidasSnap.docs),
            
            pw.SizedBox(height: 20),
            _buildSecaoTitulo("Historico de Sintomas"),
            _buildListaSintomas(sintomasSnap.docs),
            
            pw.SizedBox(height: 20),
            _buildSecaoTitulo("Vacinas Aplicadas"),
            _buildListaVacinas(vacinasSnap.docs),
            
             pw.SizedBox(height: 20),
            _buildSecaoTitulo("Consultas Recentes"),
            _buildListaConsultas(consultasSnap.docs),
            
            pw.SizedBox(height: 30),
            _buildRodape(),
          ];
        },
      ),
    );

    // 5. ABRIR O PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Relatorio_${dadosBebe['nome']}.pdf',
    );
  }

  // --- WIDGETS DO PDF ---

  static pw.Widget _buildCabecalho(Map<String, dynamic> bebe) {
    DateTime dpp;
    if (bebe['data_parto'] is Timestamp) {
      dpp = (bebe['data_parto'] as Timestamp).toDate();
    } else {
      dpp = DateTime.parse(bebe['data_parto']);
    }
    
    String idade = "${DateTime.now().difference(dpp).inDays ~/ 30} meses";

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("RELATORIO DE SAUDE", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(bebe['nome'], style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: _corPrimaria)),
            pw.Text("Data: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.Divider(color: _corPrimaria),
        pw.Text("Nascimento: ${DateFormat('dd/MM/yyyy').format(dpp)}  |  Idade: $idade", style: const pw.TextStyle(fontSize: 14)),
      ],
    );
  }

  static pw.Widget _buildSecaoTitulo(String titulo) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: const pw.BoxDecoration(color: PdfColor(0.95, 0.95, 0.95)),
      width: double.infinity,
      child: pw.Text(titulo, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _corTexto)),
    );
  }

  // --- NOVA TABELA DE REMÉDIOS ---
  static pw.Widget _buildTabelaRemedios(List<QueryDocumentSnapshot> docs) {
    return pw.Table.fromTextArray(
      headers: ['Nome', 'Dosagem', 'Posologia'],
      data: docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return [
          d['nome'],
          d['dosagem'],
          "${d['intervalo']} em ${d['intervalo']} horas (${d['dias']} dias)"
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _corPrimaria),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }

  static pw.Widget _buildTabelaCrescimento(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return pw.Text("Sem registros de crescimento.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey));

    return pw.Table.fromTextArray(
      headers: ['Data', 'Peso (kg)', 'Altura (cm)', 'Perímetro (cm)'],
      data: docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return [
          DateFormat('dd/MM/yyyy').format(DateTime.parse(d['data'])),
          "${d['peso']} kg",
          "${d['altura']} cm",
          d['perimetro']?.toString() ?? '-'
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _corPrimaria),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignment: pw.Alignment.center,
    );
  }

  static pw.Widget _buildListaSintomas(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return pw.Text("Sem sintomas recentes.", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey));

    return pw.Column(
      children: docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(width: 60, child: pw.Text(DateFormat('dd/MM').format(DateTime.parse(d['data'])), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
              pw.Container(width: 80, child: pw.Text(d['tipo'], style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: _corPrimaria))),
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
      spacing: 10,
      runSpacing: 5,
      children: docs.map((doc) {
        String nome = doc.id.replaceAll('vac_', '').replaceAll('_', ' ').toUpperCase(); 
        if (nome.length > 25) nome = nome.substring(0, 25); // Trunca nome longo
        
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: pw.BoxDecoration(border: pw.Border.all(color: _corPrimaria), borderRadius: pw.BorderRadius.circular(4)),
          child: pw.Text("[OK] $nome", style: const pw.TextStyle(fontSize: 9)),
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
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            children: [
              pw.Container(width: 60, child: pw.Text(DateFormat('dd/MM').format(DateTime.parse(d['data'])), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
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
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text("Gerado pelo app Pequenos Passos Pro", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
        ),
      ],
    );
  }
}