import 'dart:io';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../services/bebe_service.dart';
import '../../utils/growth_standards.dart'; 
import '../../data/dados_vacinas.dart'; 
import '../../data/conteudo_marcos_completo.dart'; 

class TelaProgresso extends StatefulWidget {
  const TelaProgresso({super.key});

  @override
  State<TelaProgresso> createState() => _TelaProgressoState();
}

class _TelaProgressoState extends State<TelaProgresso> {
  bool _mostrarPeso = true;
  
  // Variáveis para o Header
  String _nomeBebe = "do Bebê";
  String? _fotoBebe;
  bool _temBebe = false;

  // Helpers de Data
  DateTime get _hoje => DateTime.now();
  String get _hojeIso => DateFormat('yyyy-MM-dd').format(_hoje);
  DateTime get _hojeZeroHora => DateTime(_hoje.year, _hoje.month, _hoje.day);

  @override
  void initState() {
    super.initState();
    _carregarDadosBebe();
  }

  void _carregarDadosBebe() async {
    final dados = await BebeService.lerBebeAtivo();
    if (dados != null) {
      if (mounted) {
        setState(() {
          String nomeCompleto = dados['nome'];
          _nomeBebe = "de ${nomeCompleto.split(' ')[0]}"; 
          _fotoBebe = dados['fotoUrl'];
          _temBebe = true;
        });
      }
    }
  }

  ImageProvider? _getImagemPerfil() {
    if (_fotoBebe != null && _fotoBebe!.isNotEmpty) {
      if (kIsWeb) return NetworkImage(_fotoBebe!);
      return FileImage(File(_fotoBebe!));
    }
    return null;
  }

  String _calcularIdade(dynamic dataParto) {
    if (dataParto == null) return "--";
    DateTime dpp = (dataParto is Timestamp) ? dataParto.toDate() : DateTime.parse(dataParto);
    final dias = DateTime.now().difference(dpp).inDays;
    if (dias < 30) return "$dias dias";
    return "${(dias / 30).floor()} meses";
  }

  @override
  Widget build(BuildContext context) {
    // Header mais alto para acomodar a foto e o título
    final double headerHeight = MediaQuery.of(context).padding.top + 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      extendBody: true,
      body: Stack(
        children: [
          FutureBuilder<DocumentReference?>(
            future: BebeService.getRefBebeAtivo(),
            builder: (context, snapshotRef) {
              if (snapshotRef.hasError) return const Center(child: Text("Erro ao carregar"));
              if (!snapshotRef.hasData) return const Center(child: CircularProgressIndicator(color: Colors.teal));
              final bebeRef = snapshotRef.data!;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20, headerHeight + 20, 20, 160), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Removemos o _buildHeaderVivo antigo pois agora temos o Header Flutuante
                    // _buildHeaderVivo(bebeRef), 
                    
                    const Text("Conquistas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                    const SizedBox(height: 15),
                    _buildGridEstatisticas(bebeRef),
                    const SizedBox(height: 35),

                    // --- RESUMO DIÁRIO ---
                    const Text("Resumo de Hoje", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                    const SizedBox(height: 15),
                    _buildResumoDiarioHibrido(bebeRef), 
                    
                    const SizedBox(height: 35),

                    // --- CRESCIMENTO ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Curva de Crescimento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                          padding: const EdgeInsets.all(2),
                          child: Row(children: [
                            _buildToogleOption("Peso", _mostrarPeso, () => setState(() => _mostrarPeso = true)),
                            _buildToogleOption("Altura", !_mostrarPeso, () => setState(() => _mostrarPeso = false)),
                          ]),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildGraficoCrescimentoVivo(bebeRef),
                    
                    const SizedBox(height: 35),
                    
                    // --- GRÁFICOS DETALHADOS ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Nutrição (Hoje)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                              const SizedBox(height: 10),
                              _buildGraficoNutricaoLive(bebeRef),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Sono (7 Dias)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                              const SizedBox(height: 10),
                              _buildGraficoSonoSemIndice(bebeRef),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          ),

          // HEADER FLUTUANTE COM FOTO
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.white.withOpacity(0.85),
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Evolução $_nomeBebe",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black.withOpacity(0.85), letterSpacing: -0.5),
                          ),
                          Text(
                            "Acompanhamento em Tempo Real",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      
                      // Avatar
                      Hero(
                        tag: 'perfil_bebe_progresso',
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.teal.shade200, width: 2)),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _getImagemPerfil(),
                            child: _getImagemPerfil() == null ? const Icon(Icons.face, color: Colors.grey) : null,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. RESUMO DIÁRIO (LÓGICA HÍBRIDA)
  // ===========================================================================
  Widget _buildResumoDiarioHibrido(DocumentReference ref) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.collection('resumos').doc(_hojeIso).snapshots(),
      builder: (context, snapshotHoje) {
        
        int mamadasHoje = 0;
        int fraldasHoje = 0;

        if (snapshotHoje.hasData && snapshotHoje.data != null && snapshotHoje.data!.exists) {
          final dados = snapshotHoje.data!.data() as Map<String, dynamic>;
          mamadasHoje = (dados['mamadas'] as num? ?? 0).toInt();
          fraldasHoje = (dados['fraldas'] as num? ?? 0).toInt();
        }

        return StreamBuilder<QuerySnapshot>(
          stream: ref.collection('resumos').orderBy(FieldPath.documentId, descending: true).limit(8).snapshots(),
          builder: (context, snapshotHist) {
            int somaMamadas = 0;
            int somaFraldas = 0;
            int dias = 0;

            if (snapshotHist.hasData) {
              for (var doc in snapshotHist.data!.docs) {
                final d = doc.data() as Map<String, dynamic>;
                somaMamadas += (d['mamadas'] as num? ?? 0).toInt();
                somaFraldas += (d['fraldas'] as num? ?? 0).toInt();
                dias++;
              }
            }
            double mediaM = dias > 0 ? somaMamadas / dias : 0.0;
            double mediaF = dias > 0 ? somaFraldas / dias : 0.0;

            return Row(
              children: [
                Expanded(child: _buildCardContador("Mamadas", mamadasHoje, mediaM, Icons.favorite_rounded, Colors.pinkAccent)),
                const SizedBox(width: 15),
                Expanded(child: _buildCardContador("Fraldas", fraldasHoje, mediaF, Icons.layers_rounded, Colors.blueAccent)),
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildCardContador(String titulo, int valor, double media, IconData icon, Color cor) {
    bool up = valor >= media;
    String txtMedia = "Média: ${media.toStringAsFixed(1)}";
    
    return Container(
      padding: const EdgeInsets.all(16), 
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: cor, size: 20)),
          Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 16, color: up ? Colors.green : Colors.orange)
        ]),
        const SizedBox(height: 12), 
        Text(titulo, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text("$valor", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A), height: 1)), 
          const SizedBox(width: 4), 
          Padding(padding: const EdgeInsets.only(bottom: 5), child: Text("hoje", style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)))
        ]),
        const SizedBox(height: 6), 
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)), child: Text(txtMedia, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)))
      ]),
    );
  }

  // ===========================================================================
  // 2. GRÁFICO NUTRIÇÃO (LIVE)
  // ===========================================================================
  Widget _buildGraficoNutricaoLive(DocumentReference ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: ref.collection('alimentacao').orderBy('data', descending: true).limit(20).snapshots(),
      builder: (c, s) {
        int f = 0, l = 0, p = 0;
        if (s.hasData) {
          for (var doc in s.data!.docs) {
             final d = doc.data() as Map<String, dynamic>;
             DateTime? dt;
             try { dt = DateTime.parse(d['data']); } catch(e) {}
             if (dt != null && dt.year == _hoje.year && dt.month == _hoje.month && dt.day == _hoje.day) {
               String cat = d['categoria'] ?? '';
               if (cat.contains('Fruta')) f++; else if (cat.contains('Legume')) l++; else if (cat.contains('Proteína')) p++;
             }
          }
        }
        int total = f + l + p;
        if (total == 0) return _buildEmptyState("Sem dados hoje");

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
          child: Column(children: [
            SizedBox(height: 120, child: PieChart(PieChartData(sectionsSpace: 3, centerSpaceRadius: 25, sections: [
              if(f>0) PieChartSectionData(value: f.toDouble(), color: Colors.orange, radius: 16, showTitle: false), 
              if(l>0) PieChartSectionData(value: l.toDouble(), color: Colors.green, radius: 16, showTitle: false), 
              if(p>0) PieChartSectionData(value: p.toDouble(), color: Colors.redAccent, radius: 16, showTitle: false)
            ]))),
            const SizedBox(height: 15),
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [_legendItem("Frutas", Colors.orange, f), _legendItem("Legumes", Colors.green, l), _legendItem("Prot.", Colors.redAccent, p)])
          ]),
        );
      }
    );
  }

  Widget _legendItem(String label, Color color, int count) {
    if (count == 0) return const SizedBox();
    return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text("$label ($count)", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))]);
  }

  // ===========================================================================
  // 3. GRÁFICO SONO (SEM ÍNDICE COMPOSTO)
  // ===========================================================================
  Widget _buildGraficoSonoSemIndice(DocumentReference ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: ref.collection('rotina').orderBy('data', descending: true).limit(100).snapshots(),
      builder: (c, s) {
        if (!s.hasData || s.data!.docs.isEmpty) return _buildEmptyState("Sem dados");
        Map<int, double> horasPorDia = {};
        for(int i=0; i<7; i++) horasPorDia[i] = 0.0;

        for (var doc in s.data!.docs) {
           final d = doc.data() as Map<String, dynamic>;
           if (d['tipo'] != 'sono') continue;
           if (d['data'] == null) continue;
           try {
             DateTime inicio = DateTime.parse(d['data']);
             DateTime diaDoSono = DateTime(inicio.year, inicio.month, inicio.day);
             int diff = _hojeZeroHora.difference(diaDoSono).inDays;
             if (diff >= 0 && diff < 7) {
               int segundos = d['duracao_segundos'] ?? 0;
               int chartIndex = 6 - diff;
               horasPorDia[chartIndex] = (horasPorDia[chartIndex] ?? 0) + (segundos / 3600.0);
             }
           } catch(e) {}
        }

        if (!horasPorDia.values.any((v) => v > 0)) return _buildEmptyState("Nenhum sono na semana");

        return Container(
          height: 195,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]),
          child: BarChart(BarChartData(
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                 int i = v.toInt(); 
                 int diasAtras = 6 - i;
                 DateTime dataDia = _hoje.subtract(Duration(days: diasAtras));
                 bool isToday = diasAtras == 0;
                 return Padding(
                   padding: const EdgeInsets.only(top: 5), 
                   child: Text(
                     DateFormat('E', 'pt_BR').format(dataDia)[0].toUpperCase(), 
                     style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isToday ? Colors.indigo : Colors.grey)
                   )
                 );
              }))
            ),
            barGroups: List.generate(7, (i) {
               double val = horasPorDia[i] ?? 0.0;
               bool isToday = i == 6;
               return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: val, color: isToday ? const Color(0xFF3949AB) : const Color(0xFF9FA8DA), width: 8, borderRadius: BorderRadius.circular(4), backDrawRodData: BackgroundBarChartRodData(show: true, toY: 14, color: Colors.grey.shade50))]);
            })
          ))
        );
      }
    );
  }

  // --- OUTROS WIDGETS ---
  Widget _buildToogleOption(String label, bool active, VoidCallback onTap) { return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: active ? const Color(0xFF2D3A3A) : Colors.transparent, borderRadius: BorderRadius.circular(18)), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.grey)))); }
  Widget _buildGridEstatisticas(DocumentReference ref) { return StreamBuilder<DocumentSnapshot>(stream: ref.snapshots(), builder: (context, snapBebe) { int mesesVida = 0; if (snapBebe.hasData && snapBebe.data!.data() != null) { final dados = snapBebe.data!.data() as Map<String, dynamic>; DateTime dpp = (dados['data_parto'] is Timestamp) ? (dados['data_parto'] as Timestamp).toDate() : DateTime.parse(dados['data_parto']); mesesVida = DateTime.now().difference(dpp).inDays ~/ 30; } return Row(children: [Expanded(child: _buildBadgeVacina(ref, mesesVida)), const SizedBox(width: 12), Expanded(child: _buildBadgeDentes(ref)), const SizedBox(width: 12), Expanded(child: _buildBadgeMarcos(ref, mesesVida))]); }); }
  Widget _buildBadgeVacina(DocumentReference ref, int mesesVida) { return StreamBuilder<QuerySnapshot>(stream: ref.collection('vacinas').snapshots(), builder: (c, s) { List<String> idsTomados = s.hasData ? s.data!.docs.map((d) => d.id).toList() : []; List<Map<String, dynamic>> vacinasDevidas = vacinasPadrao.where((v) => (v['meses'] as int) <= mesesVida).toList(); int tomadas = 0; for (var v in vacinasDevidas) { if (idsTomados.contains(v['id'])) tomadas++; } int total = vacinasDevidas.length == 0 ? 1 : vacinasDevidas.length; return _buildStatCard("Vacinas", "$tomadas/$total", tomadas >= total ? Icons.check_circle_rounded : Icons.pending_actions_rounded, tomadas >= total ? const Color(0xFF00C853) : const Color(0xFFFFAB00)); }); }
  Widget _buildBadgeDentes(DocumentReference ref) { return StreamBuilder<QuerySnapshot>(stream: ref.collection('dentes').snapshots(), builder: (c, s) => _buildStatCard("Dentes", "${s.data?.docs.length ?? 0}/20", Icons.face_retouching_natural_rounded, Colors.blue)); }
  Widget _buildBadgeMarcos(DocumentReference ref, int mesesVida) { return StreamBuilder<DocumentSnapshot>(stream: ref.collection('progresso').doc('marcos').snapshots(), builder: (c, snap) { int completados = 0; if(snap.hasData && snap.data!.exists) { var data = snap.data!.data() as Map<String, dynamic>; List lista = data['concluidos'] is List ? data['concluidos'] : []; completados = lista.length; } int totalIdade = 0; for (var grupo in marcosCompletos) { if (grupo['meses'] <= mesesVida + 1) { totalIdade += (grupo['sub_marcos'] as List? ?? []).length; } } if (totalIdade == 0) totalIdade = 1; return _buildStatCard("Marcos", "$completados/$totalIdade", Icons.emoji_events_rounded, Colors.amber.shade700); }); }
  Widget _buildStatCard(String title, String value, IconData icon, Color color) { return Container(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)), const SizedBox(height: 10), Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)), Text(title, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold))])); }
  Widget _buildGraficoCrescimentoVivo(DocumentReference ref) { return StreamBuilder<QuerySnapshot>(stream: ref.collection('medidas').orderBy('data').snapshots(), builder: (context, snapshot) { if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildEmptyState("Registre medidas na aba Saúde."); List<FlSpot> pontos = []; DateTime inicio = DateTime.parse(snapshot.data!.docs.first['data']); for (var doc in snapshot.data!.docs) { final d = doc.data() as Map<String, dynamic>; DateTime dt = DateTime.parse(d['data']); double x = dt.difference(inicio).inDays / 30.0; if (x < 0) x = 0; double y = _mostrarPeso ? (d['peso'] as num).toDouble() : (d['altura'] as num).toDouble(); pontos.add(FlSpot(x, y)); } List<List<FlSpot>> padrao = [[], []]; if (_mostrarPeso && pontos.isNotEmpty) padrao = GrowthStandards.calcularCurvasEsperadas(pesoInicial: pontos.first.y, mesesTotais: (pontos.last.x + 2).ceil()); return Container(height: 220, padding: const EdgeInsets.fromLTRB(0, 20, 20, 0), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15)]), child: LineChart(LineChartData(gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)), titlesData: FlTitlesData(show: true, rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 2, getTitlesWidget: (v,m)=>Text("${v.toInt()}m", style: const TextStyle(fontSize: 10, color: Colors.grey))))), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: pontos, isCurved: true, color: _mostrarPeso ? const Color(0xFF00695C) : Colors.blue, barWidth: 3, dotData: FlDotData(show: true), belowBarData: BarAreaData(show: true, color: (_mostrarPeso ? const Color(0xFF00695C) : Colors.blue).withOpacity(0.1))), if (_mostrarPeso) LineChartBarData(spots: padrao[1], isCurved: true, color: Colors.green.withOpacity(0.3), barWidth: 2, dashArray: [5, 5], dotData: FlDotData(show: false))]))); }); }
  Widget _buildEmptyState(String msg) => Container(height: 100, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)), child: Text(msg, style: const TextStyle(fontSize: 10, color: Colors.grey)));
}