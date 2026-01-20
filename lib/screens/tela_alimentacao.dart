import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/alimentacao_service.dart';
import '../services/bebe_service.dart';
import '../data/conteudo_alimentos.dart'; 
import '../services/resumo_service.dart'; // <--- IMPORTANTE: Adicione este import

class TelaAlimentacao extends StatefulWidget {
  const TelaAlimentacao({super.key});
  @override
  State<TelaAlimentacao> createState() => _TelaAlimentacaoState();
}

class _TelaAlimentacaoState extends State<TelaAlimentacao> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, Map<String, dynamic>> _mapaProvados = {};
  String _termoBusca = "";
  final TextEditingController _buscaController = TextEditingController();
  int _mesesBebe = 0;
  List<Map<String, dynamic>> _sugestaoDoDia = [];
  bool _carregandoMenu = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _inicializarDados();
  }

  void _inicializarDados() async {
    final dadosBebe = await BebeService.lerBebeAtivo();
    if (dadosBebe != null) {
      DateTime dpp;
      if (dadosBebe['data_parto'] is Timestamp) {
        dpp = (dadosBebe['data_parto'] as Timestamp).toDate();
      } else {
        dpp = DateTime.parse(dadosBebe['data_parto']);
      }
      _mesesBebe = DateTime.now().difference(dpp).inDays ~/ 30;
    }

    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef != null) {
      bebeRef.collection('alimentacao').snapshots().listen((snap) {
        final novoMapa = <String, Map<String, dynamic>>{};
        for (var doc in snap.docs) {
          novoMapa[doc.id] = doc.data();
        }
        if (mounted) setState(() => _mapaProvados = novoMapa);
      });
    }

    if (_mesesBebe >= 6) {
      _gerarMenuDoDiaLocal();
    }

    if (mounted) setState(() => _carregandoMenu = false);
  }

  void _gerarMenuDoDiaLocal() {
    final frutas = alimentosIniciais.where((e) => e['categoria'] == 'Fruta').toList();
    final legumes = alimentosIniciais.where((e) => e['categoria'] == 'Legume').toList();
    final prot = alimentosIniciais.where((e) => e['categoria'] == 'Proteína').toList();

    if (frutas.isNotEmpty && legumes.isNotEmpty && prot.isNotEmpty) {
      frutas.shuffle();
      legumes.shuffle();
      prot.shuffle();
      setState(() {
        _sugestaoDoDia = [frutas.first, legumes.first, prot.first];
      });
    }
  }

  String _gerarId(String nome) {
    return nome.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^\w]'), '');
  }

  void _abrirDetalhes(Map<String, dynamic> alimento) {
    final docId = _gerarId(alimento['nome']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom), 
        child: _ModalDetalhesAlimento(
          alimento: alimento, 
          docId: docId, 
          dadosProvado: _mapaProvados[docId]
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO ---

  Widget _buildCardGamificacao() {
    int totalProvados = _mapaProvados.length;
    int meta = 50;
    double progresso = (totalProvados / meta).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF43A047), Color(0xFF2E7D32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(children: [
          Stack(alignment: Alignment.center, children: [
             SizedBox(width: 80, height: 80, child: CircularProgressIndicator(value: progresso, color: Colors.white, backgroundColor: Colors.white24, strokeWidth: 8)),
             Text("${(progresso * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ]),
          const SizedBox(width: 24),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
             const Text("Desafio dos Sabores", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
             const SizedBox(height: 8),
             Text("Já exploramos $totalProvados de $meta novos sabores!", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          ]))
      ]),
    );
  }

  Widget _buildSugestaoPrato() {
    if (_sugestaoDoDia.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [Icon(Icons.restaurant, color: Color(0xFF2D3A3A)), SizedBox(width: 10), Text("Sugestão do Dia", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2D3A3A)))]),
              IconButton(onPressed: _gerarMenuDoDiaLocal, icon: const Icon(Icons.refresh, color: Colors.grey))
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _sugestaoDoDia.map((item) => GestureDetector(
                onTap: () => _abrirDetalhes(item),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)),
                      child: CircleAvatar(
                        radius: 35, 
                        backgroundColor: Colors.grey[50], 
                        backgroundImage: NetworkImage(item['imagemUrl'])
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item['nome'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(item['categoria'], style: const TextStyle(fontSize: 10, color: Colors.grey))
                  ]
                ),
              )).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAvisoAleitamento() {
    return Container(
      padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.blue.shade100)), 
      child: Column(children: [
        const Icon(Icons.baby_changing_station, size: 40, color: Colors.blue), 
        const SizedBox(height: 15), 
        Text("Aleitamento Exclusivo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800, fontSize: 16)), 
        const SizedBox(height: 8), 
        Text("Seu bebê tem $_mesesBebe meses. Aguarde até os 6 meses para iniciar a introdução alimentar.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.blue.shade700, height: 1.4))
      ])
    );
  }

  Widget _buildAbaInicio() {
    if (_carregandoMenu) return const Center(child: CircularProgressIndicator(color: Colors.teal));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 160), 
      child: Column(children: [
        _buildCardGamificacao(),
        const SizedBox(height: 25),
        if (_mesesBebe < 6) _buildAvisoAleitamento() else _buildSugestaoPrato(),
      ]),
    );
  }

  Widget _buildLista(String categoria) {
    final listaFiltrada = alimentosIniciais.where((a) {
      bool catMatch = a['categoria'] == categoria;
      bool buscaMatch = a['nome'].toString().toLowerCase().contains(_termoBusca.toLowerCase());
      return catMatch && buscaMatch;
    }).toList();

    if (listaFiltrada.isEmpty) return const Center(child: Text("Nenhum alimento encontrado.", style: TextStyle(color: Colors.grey)));

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 160), 
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 0.8),
      itemCount: listaFiltrada.length,
      itemBuilder: (context, index) {
        final alimento = listaFiltrada[index];
        final id = _gerarId(alimento['nome']);
        final provado = _mapaProvados.containsKey(id);
        final reacao = provado ? _mapaProvados[id]!['reacao'] : '';
        
        return GestureDetector(
          onTap: () => _abrirDetalhes(alimento),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(20), 
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
              border: provado ? Border.all(color: _getCorReacao(reacao), width: 2) : null
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0), 
                    child: Image.network(alimento['imagemUrl'], fit: BoxFit.contain, errorBuilder: (_,__,___)=>const Icon(Icons.restaurant, color: Colors.grey, size: 30))
                  )
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 12), 
                  child: Text(
                    alimento['nome'], 
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: provado ? _getCorReacao(reacao) : Colors.black87), 
                    maxLines: 1, overflow: TextOverflow.ellipsis
                  )
                )
              ]
            ),
          ),
        );
      },
    );
  }

  Color _getCorReacao(String r) {
    if (r == 'gostou') return Colors.green;
    if (r == 'rejeitou') return Colors.orange;
    if (r == 'alergia') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
                child: TextField(
                  controller: _buscaController, 
                  onChanged: (v) => setState(() => _termoBusca = v), 
                  decoration: InputDecoration(
                    hintText: "Buscar alimento...", 
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey), 
                    fillColor: const Color(0xFFF5F7FA), 
                    filled: true, 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), 
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20), 
                    hintStyle: const TextStyle(color: Colors.grey)
                  )
                )
              ),
              TabBar(
                controller: _tabController, 
                isScrollable: true, 
                tabAlignment: TabAlignment.start, 
                indicatorColor: Colors.teal, 
                labelColor: Colors.teal, 
                unselectedLabelColor: Colors.grey, 
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14), 
                dividerColor: Colors.transparent, 
                indicatorSize: TabBarIndicatorSize.label,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tabs: const [Tab(text: "Início"), Tab(text: "Frutas"), Tab(text: "Legumes"), Tab(text: "Proteínas"), Tab(text: "Proibidos")]
              )
          ]),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF9FAFB), 
            child: TabBarView(
              controller: _tabController, 
              children: [
                _buildAbaInicio(), 
                _buildLista("Fruta"), 
                _buildLista("Legume"), 
                _buildLista("Proteína"), 
                _buildLista("Proibido")
              ]
            )
          )
        ),
      ],
    );
  }
}

class _ModalDetalhesAlimento extends StatefulWidget {
  final Map<String, dynamic> alimento;
  final String docId;
  final Map<String, dynamic>? dadosProvado;
  const _ModalDetalhesAlimento({required this.alimento, required this.docId, this.dadosProvado});
  @override
  State<_ModalDetalhesAlimento> createState() => _ModalDetalhesAlimentoState();
}

class _ModalDetalhesAlimentoState extends State<_ModalDetalhesAlimento> {
  String _reacao = 'gostou';
  final _notasController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    if (widget.dadosProvado != null) {
      _reacao = widget.dadosProvado!['reacao'] ?? 'gostou';
      _notasController.text = widget.dadosProvado!['notas'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.alimento;
    bool isProibido = a['categoria'] == 'Proibido';

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: EdgeInsets.fromLTRB(24, 30, 24, MediaQuery.of(context).viewInsets.bottom + 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
                Hero(tag: a['nome'], child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(20)), child: Image.network(a['imagemUrl'], width: 60, height: 60, errorBuilder: (_,__,___)=>const Icon(Icons.restaurant, size: 40, color: Colors.grey)))),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                   Text(a['nome'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A))),
                   const SizedBox(height: 5),
                   Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(a['categoria'].toUpperCase(), style: const TextStyle(color: Colors.teal, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)))
                ]))
            ]),
            const SizedBox(height: 30),
            
            if (isProibido)
              Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.warning_rounded, color: Colors.red, size: 32), const SizedBox(width: 15), Expanded(child: Text(a['corte_6m'], style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)))]))
            else ...[
               _buildInfoBox(Icons.health_and_safety_rounded, a['beneficio'] ?? "Nutritivo e saudável", Colors.teal),
               const SizedBox(height: 20),
               const Text("Como oferecer:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
               const SizedBox(height: 15),
               _buildCorteCard("6 meses", a['corte_6m'], Colors.orange),
               const SizedBox(height: 12),
               _buildCorteCard("9 meses+", a['corte_9m'], Colors.blue),
               
               const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Divider()),
               const Text("Diário do Bebê", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A))), const SizedBox(height: 20),
               Row(children: [Expanded(child: _buildOpcaoReacao('gostou', 'Amou', Icons.sentiment_very_satisfied_rounded, Colors.green)), const SizedBox(width: 10), Expanded(child: _buildOpcaoReacao('rejeitou', 'Cuspiu', Icons.sentiment_dissatisfied_rounded, Colors.orange)), const SizedBox(width: 10), Expanded(child: _buildOpcaoReacao('alergia', 'Alergia', Icons.warning_amber_rounded, Colors.red))]),
               const SizedBox(height: 20), 
               TextField(controller: _notasController, decoration: InputDecoration(labelText: "Notas ou observações...", alignLabelWithHint: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.grey)), filled: true, fillColor: const Color(0xFFF5F7FA)), maxLines: 3),
               const SizedBox(height: 30),
               SizedBox(
                 width: double.infinity, height: 55, 
                 child: ElevatedButton(
                   onPressed: () async { 
                     // 1. Salva no registro detalhado
                     await AlimentacaoService.registrarExperiencia(widget.docId, _reacao, _notasController.text, a); 
                     
                     // 2. SALVA NO RESUMO (CONTADOR) - AGORA SIM!
                     await ResumoService.atualizarNutricao(a['categoria'], DateTime.now());

                     if (mounted) Navigator.pop(context); 
                   }, 
                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3A3A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), 
                   child: const Text("SALVAR REGISTRO", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                 )
               )
            ]
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoBox(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.1))),
      child: Row(children: [Icon(icon, color: color, size: 24), const SizedBox(width: 15), Expanded(child: Text(text, style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w600, fontSize: 14)))]),
    );
  }

  Widget _buildCorteCard(String i, String t, MaterialColor c) => Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c.shade50, borderRadius: BorderRadius.circular(8)), child: Text(i, style: TextStyle(fontWeight: FontWeight.bold, color: c.shade800, fontSize: 12))), const Spacer()]), const SizedBox(height: 10), Text(t, style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14))]));
  
  Widget _buildOpcaoReacao(String v, String l, IconData i, Color c) { 
    bool s = _reacao == v; 
    return GestureDetector(
      onTap: ()=>setState(()=>_reacao=v), 
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15), 
        decoration: BoxDecoration(
          color: s ? c.withOpacity(0.1) : Colors.white, 
          borderRadius: BorderRadius.circular(16), 
          border: Border.all(color: s ? c : Colors.grey.shade200, width: s ? 2 : 1)
        ), 
        child: Column(children: [Icon(i, color: s ? c : Colors.grey, size: 28), const SizedBox(height: 8), Text(l, style: TextStyle(color: s ? c : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))])
      )
    ); 
  }
}