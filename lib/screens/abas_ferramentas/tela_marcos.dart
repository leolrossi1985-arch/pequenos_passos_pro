import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/bebe_service.dart';
import '../../data/conteudo_marcos_completo.dart';

class TelaMarcos extends StatefulWidget {
  const TelaMarcos({super.key});

  @override
  State<TelaMarcos> createState() => _TelaMarcosState();
}

class _TelaMarcosState extends State<TelaMarcos> {
  List<String> _marcosConcluidos = [];
  bool _carregando = true;
  int _mesesBebe = 0;
  
  // Controle da Idade Selecionada na Linha do Tempo
  int _idadeSelecionada = 2; // Começa no primeiro marco

  // Lista única de idades disponíveis nos dados (para montar a timeline)
  final List<int> _idadesDisponiveis = [];

  @override
  void initState() {
    super.initState();
    _extrairIdadesDisponiveis();
    _inicializarDados();
  }

  void _extrairIdadesDisponiveis() {
    // Pega todas as idades únicas do arquivo de dados e ordena
    final idades = marcosCompletos.map((m) => m['meses'] as int).toSet().toList();
    idades.sort();
    _idadesDisponiveis.addAll(idades);
  }

  void _inicializarDados() async {
    final ref = await BebeService.getRefBebeAtivo();
    if (ref != null) {
      // 1. Calcular Idade Real
      final snapBebe = await ref.get();
      if (snapBebe.exists) {
        final dados = snapBebe.data() as Map<String, dynamic>;
        DateTime dpp = (dados['data_parto'] is Timestamp) ? (dados['data_parto'] as Timestamp).toDate() : DateTime.parse(dados['data_parto']);
        _mesesBebe = DateTime.now().difference(dpp).inDays ~/ 30;
      }

      // 2. Ler progresso
      final snapProg = await ref.collection('progresso').doc('marcos').get();
      if (snapProg.exists && snapProg.data() != null) {
        final dadosProg = snapProg.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _marcosConcluidos = List<String>.from(dadosProg['concluidos'] ?? []);
            _carregando = false;
            
            // Auto-seleciona a idade mais próxima na timeline
            _selecionarIdadeMaisProxima();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _carregando = false;
            _selecionarIdadeMaisProxima();
          });
        }
      }
    }
  }

  void _selecionarIdadeMaisProxima() {
    // Encontra a idade na lista que é igual ou imediatamente superior à idade do bebê
    int maisProxima = _idadesDisponiveis.first;
    for (var idade in _idadesDisponiveis) {
      if (idade <= _mesesBebe + 1) { // +1 de margem
        maisProxima = idade;
      }
    }
    // Se o bebê for muito velho, pega o último
    if (_mesesBebe > _idadesDisponiveis.last) maisProxima = _idadesDisponiveis.last;

    setState(() {
      _idadeSelecionada = maisProxima;
    });
  }

  void _toggleMarco(String id) async {
    setState(() {
      if (_marcosConcluidos.contains(id)) {
        _marcosConcluidos.remove(id);
      } else {
        _marcosConcluidos.add(id);
      }
    });

    final ref = await BebeService.getRefBebeAtivo();
    if (ref != null) {
      await ref.collection('progresso').doc('marcos').set({
        'concluidos': _marcosConcluidos,
        'ultimo_update': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
    }
  }

  // Cores Premium e Suaves
  Color _getCorCategoria(String cat) {
     if(cat.contains('Social')) return const Color(0xFF4CAF50); // Green
     if(cat.contains('Lingua')) return const Color(0xFFE91E63); // Pink
     if(cat.contains('Cogni')) return const Color(0xFF2196F3); // Blue
     if(cat.contains('Motor')) return const Color(0xFFFF9800); // Orange
     return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) return const Center(child: CircularProgressIndicator(color: Colors.teal));

    // Filtra os dados apenas para a idade selecionada na timeline
    final dadosDaIdade = marcosCompletos.where((m) => m['meses'] == _idadeSelecionada).toList();

    // Calcula progresso desta aba específica
    int totalAba = 0;
    int feitosAba = 0;
    for (var grupo in dadosDaIdade) {
      List subs = grupo['sub_marcos'];
      totalAba += subs.length;
      for (var item in subs) {
        if (_marcosConcluidos.contains(item['id'])) feitosAba++;
      }
    }
    double progressoAba = totalAba > 0 ? feitosAba / totalAba : 0.0;

    return Column(
      children: [
        // ==========================================================
        // 1. TIMELINE HORIZONTAL (Seletor de Idade)
        // ==========================================================
        Container(
          height: 90,
          color: Colors.white,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            itemCount: _idadesDisponiveis.length,
            itemBuilder: (context, index) {
              final int idade = _idadesDisponiveis[index];
              final bool isSelected = idade == _idadeSelecionada;
              final bool isPassado = idade < _mesesBebe;
              
              return GestureDetector(
                onTap: () => setState(() => _idadeSelecionada = idade),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal : (isPassado ? Colors.teal.shade50 : Colors.white),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? Colors.teal : Colors.grey.shade300,
                      width: isSelected ? 0 : 1
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(color: Colors.teal.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                    ] : []
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$idade", 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isPassado ? Colors.teal : Colors.grey)
                        )
                      ),
                      Text(
                        "MESES", 
                        style: TextStyle(
                          fontSize: 9, 
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white70 : (isPassado ? Colors.teal.withOpacity(0.6) : Colors.grey)
                        )
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ==========================================================
        // 2. CONTEÚDO DA IDADE SELECIONADA
        // ==========================================================
        Expanded(
          child: ListView(
            // --- CORREÇÃO DE PADDING ---
            // Aumentado para 160 para compensar a barra de navegação flutuante da TelaBase
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 160),
            
            children: [
              // --- CARD DE RESUMO DA IDADE ---
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft, end: Alignment.bottomRight
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ]
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Marcos de $_idadeSelecionada Meses",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "$feitosAba de $totalAba completados",
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          // Barra de Progresso Linear
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressoAba,
                              backgroundColor: Colors.black12,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 6,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                      child: Icon(
                        progressoAba == 1.0 ? Icons.emoji_events : Icons.trending_up, 
                        color: Colors.white, size: 32
                      ),
                    )
                  ],
                ),
              ),

              // --- LISTA DE CATEGORIAS DESTA IDADE ---
              if (dadosDaIdade.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Nenhum dado encontrado.")))
              else
                ...dadosDaIdade.map((grupo) {
                  return _buildGrupoCategoria(grupo);
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrupoCategoria(Map<String, dynamic> grupo) {
    Color corTema = _getCorCategoria(grupo['categoria']);
    List subMarcos = grupo['sub_marcos'];
    
    // Filtra itens já feitos dentro deste grupo para mostrar progresso visual
    int feitosNoGrupo = subMarcos.where((m) => _marcosConcluidos.contains(m['id'])).length;
    bool grupoCompleto = feitosNoGrupo == subMarcos.length && subMarcos.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4))
        ],
        border: Border.all(color: grupoCompleto ? corTema.withOpacity(0.3) : Colors.transparent)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABEÇALHO DA CATEGORIA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: corTema.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  grupoCompleto ? Icons.check_circle : Icons.circle, 
                  color: corTema, size: 18
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    grupo['categoria'].toString().toUpperCase(),
                    style: TextStyle(
                      color: corTema,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.0
                    ),
                  ),
                ),
                Text(
                  "$feitosNoGrupo/${subMarcos.length}",
                  style: TextStyle(color: corTema, fontWeight: FontWeight.bold, fontSize: 12),
                )
              ],
            ),
          ),

          // DESCRIÇÃO DO GRUPO (Se houver)
          if (grupo['descricao'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                grupo['descricao'],
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 13),
              ),
            ),

          // LISTA DE ITENS
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subMarcos.length,
            separatorBuilder: (c, i) => Divider(height: 1, indent: 50, endIndent: 20, color: Colors.grey.shade100),
            itemBuilder: (ctx, i) {
              final item = subMarcos[i];
              // Verifica se é um mapa de dados válido
              if (item is! Map) return Container();

              final bool isChecked = _marcosConcluidos.contains(item['id']);

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleMarco(item['id']),
                  borderRadius: i == subMarcos.length - 1 
                      ? const BorderRadius.vertical(bottom: Radius.circular(16))
                      : BorderRadius.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkbox Customizado
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: isChecked ? corTema : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isChecked ? corTema : Colors.grey.shade300,
                              width: 2
                            )
                          ),
                          child: isChecked 
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                        ),
                        const SizedBox(width: 12),
                        // Texto
                        Expanded(
                          child: Text(
                            item['texto'],
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isChecked ? Colors.grey : Colors.black87,
                              decoration: isChecked ? TextDecoration.lineThrough : null,
                              decorationColor: corTema
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}