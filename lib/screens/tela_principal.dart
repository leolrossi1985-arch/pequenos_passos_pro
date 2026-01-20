import 'dart:io';
import 'dart:ui'; // Necessário para o Blur
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- IMPORTS DO PROJETO ---
import '../utils/calculadora_desenvolvimento.dart';
import '../models/atividade.dart';
import '../services/bebe_service.dart';
import '../widgets/linha_tempo_bebe.dart';
import '../data/conteudo_atividades.dart'; 
import 'tela_admin.dart';
import 'tela_detalhes.dart';
import 'tela_salto.dart';
import 'tela_selecao.dart';
import 'tela_perfil.dart'; 
import 'tela_configuracoes.dart';

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final List<String> _admins = ['leo.l.r@bol.com.br'];

  String _nomeBebe = "Carregando...";
  String? _fotoBebe;
  int _semanasDeVida = 0;
  String _faixaEtariaAtual = ""; 
  bool _temBebe = false;
  bool _isGestante = false;

  List<Map<String, dynamic>> _sugestoesHoje = [];
  List<String> _idsConcluidosHoje = [];
  Map<String, double> _historicoProgresso = {}; 
  bool _carregandoSugestoes = true;

  final List<Map<String, dynamic>> _categoriasSistema = [
    {'nome': 'Motor', 'cor': 0xFFFF9800, 'icone': Icons.directions_run_rounded}, 
    {'nome': 'Cognitivo', 'cor': 0xFF2196F3, 'icone': Icons.lightbulb_rounded}, 
    {'nome': 'Sensorial', 'cor': 0xFF9C27B0, 'icone': Icons.touch_app_rounded}, 
    {'nome': 'Linguagem', 'cor': 0xFFE91E63, 'icone': Icons.chat_bubble_rounded}, 
    {'nome': 'Social', 'cor': 0xFF4CAF50, 'icone': Icons.people_rounded}, 
    {'nome': 'Vida Prática', 'cor': 0xFF009688, 'icone': Icons.cleaning_services_rounded}, 
    {'nome': 'Visão', 'cor': 0xFF607D8B, 'icone': Icons.visibility_rounded},
    {'nome': 'Auditivo', 'cor': 0xFF795548, 'icone': Icons.hearing_rounded},
  ];

  List<Map<String, dynamic>> _categoriasDisponiveis = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _carregarDadosBebe();
  }

  // ... (MÉTODOS DE CARREGAMENTO MANTIDOS IGUAIS) ...
  void _carregarDadosBebe() async {
    final dados = await BebeService.lerBebeAtivo();
    if (dados != null) {
      DateTime dpp;
      if (dados['data_parto'] is Timestamp) {
        dpp = (dados['data_parto'] as Timestamp).toDate();
      } else {
        dpp = DateTime.parse(dados['data_parto']);
      }
      DateTime hoje = DateTime.now();
      int diasDeVida = hoje.difference(dpp).inDays;
      int semanas = (diasDeVida / 7).floor(); 
      String faixa = _obterFaixaEtaria(semanas);

      if (mounted) {
        setState(() {
          _nomeBebe = dados['nome'];
          _fotoBebe = dados['fotoUrl'];
          _semanasDeVida = semanas;
          _faixaEtariaAtual = faixa;
          _temBebe = true;
          _isGestante = semanas < 0;
        });
        _carregarHistoricoLocal();
        if (!_isGestante) {
          _sincronizarMetasDoDia(faixa);
          _filtrarCategoriasPorIdadeLocal(faixa); 
        } else {
          setState(() => _carregandoSugestoes = false);
        }
      }
    } else {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaSelecao()));
    }
  }

  ImageProvider? _getImagemPerfil() {
    if (_fotoBebe != null && _fotoBebe!.isNotEmpty) {
      if (kIsWeb) return NetworkImage(_fotoBebe!);
      return FileImage(File(_fotoBebe!));
    }
    return null;
  }

  void _carregarHistoricoLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final keySufixo = _nomeBebe.replaceAll(' ', '');
    String historicoJson = prefs.getString('historico_$keySufixo') ?? '{}';
    if (mounted) setState(() => _historicoProgresso = Map<String, double>.from(json.decode(historicoJson)));
  }

  String _obterFaixaEtaria(int semanas) {
    if (semanas <= 13) return '0-3 meses'; 
    if (semanas <= 26) return '3-6 meses';
    if (semanas <= 39) return '6-9 meses';
    if (semanas <= 52) return '9-12 meses';
    if (semanas <= 104) return '1-2 anos';
    return '2-3 anos'; 
  }

  void _filtrarCategoriasPorIdadeLocal(String idadeAlvo) {
    final catsEncontradas = atividadesLocais.where((a) => a['idadeAlvo'] == idadeAlvo).map((a) => a['categoria'] as String).toSet();
    setState(() {
      _categoriasDisponiveis = _categoriasSistema.where((cat) => catsEncontradas.contains(cat['nome'])).toList();
    });
  }

  String _descobrirSalto(int semanas) {
    if (semanas < 0) return "Faltam ${semanas.abs()} semanas! 🤰";
    return CalculadoraDesenvolvimento.getTituloFase(semanas);
  }

  List<Color> _getCoresCard(int semanas) {
    if (_isGestante) return [const Color(0xFFBA68C8), const Color(0xFF9C27B0)];
    String status = CalculadoraDesenvolvimento.getStatusSemana(semanas);
    if (status == 'raio') return [const Color(0xFFFFB74D), const Color(0xFFF57C00)]; 
    if (status == 'nuvem') return [const Color(0xFF90A4AE), const Color(0xFF607D8B)]; 
    return [const Color(0xFF6A9C89), const Color(0xFF4E8D7C)]; 
  }

  Future<void> _sincronizarMetasDoDia(String faixaEtaria) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;
    final hojeStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final metaRef = bebeRef.collection('metas_diarias').doc(hojeStr);
    try {
      final doc = await metaRef.get();
      if (doc.exists && doc.data() != null) {
        final dados = doc.data()!;
        final idsSalvos = List<String>.from(dados['sugestoes'] ?? []);
        if (idsSalvos.isEmpty) {
           await _gerarNovasMetasLocal(faixaEtaria, metaRef);
        } else {
           final atividadesSalvas = atividadesLocais.where((a) => idsSalvos.contains(a['id'])).toList();
           if (mounted) {
             setState(() {
               _sugestoesHoje = atividadesSalvas;
               _idsConcluidosHoje = List<String>.from(dados['concluidas'] ?? []);
               _carregandoSugestoes = false;
             });
             _atualizarHistorico(); 
           }
        }
      } else {
        await _gerarNovasMetasLocal(faixaEtaria, metaRef);
      }
    } catch (e) {
      if (mounted) setState(() => _carregandoSugestoes = false);
    }
  }

  Future<void> _gerarNovasMetasLocal(String faixaEtaria, DocumentReference metaRef) async {
    setState(() => _carregandoSugestoes = true);
    var possiveis = atividadesLocais.where((a) => a['idadeAlvo'] == faixaEtaria).toList();
    if (possiveis.isEmpty) possiveis = atividadesLocais; 
    possiveis.shuffle();
    final novas = possiveis.take(5).toList();
    final novosIds = novas.map((a) => a['id'] as String).toList();
    try {
      await metaRef.set({'data': FieldValue.serverTimestamp(), 'sugestoes': novosIds, 'concluidas': []});
      if (mounted) {
        setState(() { _sugestoesHoje = novas; _idsConcluidosHoje = []; });
        _atualizarHistorico();
      }
    } catch (e) { debugPrint("Erro metas: $e"); } 
    finally { if (mounted) setState(() => _carregandoSugestoes = false); }
  }

  Future<void> _alternarConclusao(String idAtividade) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;
    final hojeStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final metaRef = bebeRef.collection('metas_diarias').doc(hojeStr);
    setState(() {
      if (_idsConcluidosHoje.contains(idAtividade)) { _idsConcluidosHoje.remove(idAtividade); } else { _idsConcluidosHoje.add(idAtividade); }
    });
    await metaRef.update({'concluidas': _idsConcluidosHoje});
    _atualizarHistorico();
  }

  Future<void> _atualizarHistorico() async {
    if (_sugestoesHoje.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final keySufixo = _nomeBebe.replaceAll(' ', '');
    final hojeStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    double progresso = _idsConcluidosHoje.length / _sugestoesHoje.length;
    _historicoProgresso[hojeStr] = progresso;
    await prefs.setString('historico_$keySufixo', json.encode(_historicoProgresso));
    if (mounted) setState(() {}); 
  }

  Widget _construirImagem(String url, {double height = 80, double width = 80, Color? bgCor}) {
    Color fundo = bgCor?.withOpacity(0.15) ?? Colors.teal.withOpacity(0.1);
    if (url.startsWith('http')) {
      return Container(
        height: height, width: width, color: fundo, padding: const EdgeInsets.all(12),
        child: Image.network(url, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: Colors.grey.shade400)),
      );
    }
    return Container(height: height, width: width, color: fundo, child: Icon(Icons.image, color: bgCor ?? Colors.teal));
  }

  // --- WIDGETS DE UI ---

  Widget _buildCalendarioSemanal() {
    DateTime hoje = DateTime.now();
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          DateTime dia = hoje.subtract(const Duration(days: 3)).add(Duration(days: index));
          String chaveData = DateFormat('yyyy-MM-dd').format(dia);
          String diaSemana = DateFormat('EEE', 'pt_BR').format(dia).toUpperCase().replaceAll('.', '');
          String diaNumero = DateFormat('dd').format(dia);
          bool isHoje = chaveData == DateFormat('yyyy-MM-dd').format(hoje);
          double progresso = _historicoProgresso[chaveData] ?? 0.0;

          return Container(
            width: 50,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isHoje ? const Color(0xFF2D3A3A) : Colors.white, // Dark para hoje (Premium)
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
              border: Border.all(color: isHoje ? Colors.transparent : Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(diaSemana, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isHoje ? Colors.white70 : Colors.grey)),
                const SizedBox(height: 2),
                Text(diaNumero, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isHoje ? Colors.white : Colors.black87)),
                const SizedBox(height: 6),
                Container(
                  height: 6, width: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: progresso > 0 ? (isHoje ? Colors.white : (progresso >= 1.0 ? Colors.green : Colors.orange)) : Colors.transparent
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSugestoesDoDia() {
    if (!_temBebe || _isGestante) return const SizedBox.shrink();
    if (_carregandoSugestoes) return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
    int total = _sugestoesHoje.isEmpty ? 1 : _sugestoesHoje.length;
    double progresso = _idsConcluidosHoje.length / total.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Meta Diária ✨", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A))),
                  Text("${(progresso * 100).toInt()}% concluído", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.grey),
                onPressed: () async {
                    final ref = await BebeService.getRefBebeAtivo();
                    if (ref != null) {
                      final hojeStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                      _gerarNovasMetasLocal(_faixaEtariaAtual, ref.collection('metas_diarias').doc(hojeStr));
                    }
                },
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5), 
          child: Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                width: MediaQuery.of(context).size.width * 0.9 * progresso,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3A3A), // Cor Premium Escura
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          )
        ),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            itemCount: _sugestoesHoje.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final data = _sugestoesHoje[index];
              final atv = Atividade.fromMap(data['id'], data);
              final isConcluido = _idsConcluidosHoje.contains(atv.id);

              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaDetalhes(atividade: atv))),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    border: isConcluido ? Border.all(color: Colors.green.withOpacity(0.3), width: 1.5) : null
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Expanded(
                        flex: 3, 
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), 
                              child: Container(
                                width: double.infinity, 
                                color: atv.cor.withOpacity(0.08),
                                child: _construirImagem(atv.imagemUrl, bgCor: atv.cor)
                              )
                            ), 
                            Positioned(
                              top: 8, right: 8, 
                              child: InkWell(
                                onTap: () => _alternarConclusao(atv.id), 
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 28, width: 28,
                                  decoration: BoxDecoration(color: isConcluido ? Colors.green : Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                                  child: Icon(Icons.check, size: 16, color: isConcluido ? Colors.white : Colors.grey.shade300)
                                )
                              )
                            )
                          ]
                        )
                      ),
                      Expanded(
                        flex: 2, 
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), 
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: atv.cor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(atv.categoria.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: atv.cor))),
                            const SizedBox(height: 6), 
                            Expanded(child: Text(atv.titulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, height: 1.2, decoration: isConcluido ? TextDecoration.lineThrough : null, color: isConcluido ? Colors.grey : const Color(0xFF2D3A3A))))
                          ])
                        )
                      )
                    ]
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriasHorizontal() {
    if (_categoriasDisponiveis.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Nenhuma categoria.", style: TextStyle(color: Colors.grey))));
    return SizedBox(
      height: 110, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categoriasDisponiveis.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final cat = _categoriasDisponiveis[index];
          final Color cor = Color(cat['cor']);
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaListaPorCategoria(categoria: cat['nome'], idadeAlvo: _faixaEtariaAtual, cor: cor))),
            child: Container(
              width: 80, margin: const EdgeInsets.only(right: 16),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(height: 60, width: 60, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))], border: Border.all(color: Colors.white, width: 2)), child: Icon(cat['icone'], color: cor, size: 28)),
                const SizedBox(height: 8),
                Text(cat['nome'], textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.grey[800]), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Altura do Header Flutuante (Ajuste se necessário)
    final double headerHeight = MediaQuery.of(context).padding.top + 90;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), // Cerâmica Premium
      extendBody: true, // Conteúdo passa por trás do dock inferior
      body: Stack(
        children: [
          // 1. CONTEÚDO ROLÁVEL (CUSTOM SCROLL VIEW)
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Padding Top (Header) + Padding Bottom (Dock)
              SliverPadding(
                padding: EdgeInsets.only(top: headerHeight, bottom: 140), 
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      if (_temBebe) 
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20), 
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaSalto(semana: _semanasDeVida))), 
                            borderRadius: BorderRadius.circular(28), 
                            child: Container(
                              width: double.infinity, padding: const EdgeInsets.all(24), 
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: _getCoresCard(_semanasDeVida), begin: Alignment.topLeft, end: Alignment.bottomRight), 
                                borderRadius: BorderRadius.circular(28), 
                                boxShadow: [BoxShadow(color: _getCoresCard(_semanasDeVida).first.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
                              ), 
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(right: -20, top: -20, child: Icon(Icons.auto_awesome, color: Colors.white.withOpacity(0.15), size: 120)),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("DESENVOLVIMENTO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))), 
                                      const SizedBox(height: 15), 
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_isGestante ? "Bebê a Caminho" : "${_semanasDeVida}ª Semana", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1)), Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20))]), 
                                      const SizedBox(height: 5), 
                                      Text(_descobrirSalto(_semanasDeVida), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500))
                                  ]),
                                ],
                              )
                            )
                          )
                        ),
                      
                      if (_temBebe && !_isGestante) 
                        Padding(
                          padding: const EdgeInsets.only(top: 25, bottom: 10), 
                          child: LinhaTempoBebe(
                            semanaReal: _semanasDeVida,           
                            semanaSelecionada: _semanasDeVida, 
                            onSemanaSelecionada: (novaSemana) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => TelaSalto(semana: novaSemana)));
                            },
                          )
                        ),

                      if (!_isGestante) _buildCalendarioSemanal(),
                      _buildSugestoesDoDia(), 
                      const SizedBox(height: 30),
                      if (_temBebe && !_isGestante) ...[
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Explorar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A)))),
                        const SizedBox(height: 15),
                        _buildCategoriasHorizontal(), 
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. HEADER FLUTUANTE (LIQUID GLASS)
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
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaPerfil())).then((_) => _carregarDadosBebe()),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'perfil_bebe',
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.teal.shade200, width: 2)),
                                child: CircleAvatar(radius: 20, backgroundColor: Colors.grey[200], backgroundImage: _getImagemPerfil(), child: _getImagemPerfil() == null ? const Icon(Icons.face, color: Colors.grey) : null),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Olá, família!", style: TextStyle(fontSize: 12, color: Colors.grey)), Text(_nomeBebe, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A)))]),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.authStateChanges(),
                            builder: (ctx, snap) {
                              if (snap.hasData && _admins.contains(snap.data?.email)) {
                                return IconButton(icon: const Icon(Icons.admin_panel_settings, color: Colors.grey), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaAdmin())));
                              }
                              return const SizedBox.shrink();
                            }
                          ),
                          Container(
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.withOpacity(0.2))),
                            child: IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black87, size: 20), tooltip: "Configurações", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaConfiguracoes()))),
                          )
                        ],
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
}

class TelaListaPorCategoria extends StatelessWidget {
  final String categoria; final String idadeAlvo; final Color cor;
  const TelaListaPorCategoria({super.key, required this.categoria, required this.idadeAlvo, required this.cor});
  @override 
  Widget build(BuildContext context) {
    final listaFiltrada = atividadesLocais.where((a) {
      return a['idadeAlvo'] == idadeAlvo && a['categoria'] == categoria;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: Text(categoria), backgroundColor: cor, foregroundColor: Colors.white),
      body: listaFiltrada.isEmpty 
        ? const Center(child: Text("Nenhuma atividade.", style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16), 
            itemCount: listaFiltrada.length, 
            itemBuilder: (context, index) {
              final data = listaFiltrada[index];
              final atv = Atividade.fromMap(data['id'], data);
              return Card(
                margin: const EdgeInsets.only(bottom: 15), 
                elevation: 0, // Flat Style
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)), 
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10), 
                  leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(color: cor.withOpacity(0.1), width: 60, height: 60, padding: const EdgeInsets.all(5), child: Image.network(atv.imagemUrl, fit: BoxFit.contain, errorBuilder: (_,__,___)=> Icon(Icons.image, color: cor)))), 
                  title: Text(atv.titulo, style: const TextStyle(fontWeight: FontWeight.bold)), 
                  subtitle: Text(atv.descricaoCurta, maxLines: 2, overflow: TextOverflow.ellipsis), 
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey), 
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaDetalhes(atividade: atv)))
                )
              );
            }
          ),
    );
  }
}