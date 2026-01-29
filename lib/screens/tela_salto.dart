import 'package:flutter/material.dart';
import '../services/progresso_service.dart';
import '../utils/calculadora_desenvolvimento.dart'; 

class TelaSalto extends StatefulWidget {
  final int semana;

  const TelaSalto({super.key, required this.semana});

  @override
  State<TelaSalto> createState() => _TelaSaltoState();
}

class _TelaSaltoState extends State<TelaSalto> {
  List<String> _sinaisMarcados = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProgresso();
  }

  void _carregarProgresso() async {
    final sinais = await ProgressoService.lerItens('sinais', widget.semana);
    if (mounted) {
      setState(() {
        _sinaisMarcados = sinais;
        _carregando = false;
      });
    }
  }

  void _toggleSinal(String item) async {
    await ProgressoService.alternarItem('sinais', widget.semana, item);
    setState(() {
      if (_sinaisMarcados.contains(item)) {
        _sinaisMarcados.remove(item);
      } else {
        _sinaisMarcados.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dados
    final dadosBase = CalculadoraDesenvolvimento.getDadosSemana(widget.semana);
    final status = dadosBase['status'] ?? CalculadoraDesenvolvimento.statusNuvem;
    final titulo = dadosBase['titulo'] ?? "Semana ${widget.semana}";
    final descricao = dadosBase['desc'] ?? "Sem descrição disponível."; 
    
    // Cores e Ícones
    final cores = CalculadoraDesenvolvimento.getCoresCard(widget.semana);
    final corPrincipal = cores[0];
    final corSecundaria = cores[1];
    final iconeCabecalho = CalculadoraDesenvolvimento.getIcone(widget.semana);

    // Conteúdo Rico
    final conteudoRico = CalculadoraDesenvolvimento.getConteudoDetalhado(widget.semana);
    final sinais = conteudoRico['sinais'] as List<String>;
    final dicas = conteudoRico['dicas'] as List<String>;
    final habilidades = conteudoRico['habilidades'] as List<String>;

    // Títulos Dinâmicos
    String tituloSinais = "Sinais Comuns";
    String subTituloSinais = "Marque o que você percebeu";
    
    if (status == CalculadoraDesenvolvimento.statusCrise) {
      tituloSinais = "Fase de Crise";
      subTituloSinais = "Sinais de irritabilidade esperados";
    } else if (status == CalculadoraDesenvolvimento.statusSol) {
      tituloSinais = "Fase Ensolarada";
      subTituloSinais = "Comportamentos positivos";
    }

    if (_carregando) {
      return Scaffold(backgroundColor: const Color(0xFFF9FAFB), body: Center(child: CircularProgressIndicator(color: corPrincipal)));
    }

    // Cálculo de Progresso dos Sinais (Gamificação)
    double progressoSinais = sinais.isNotEmpty ? _sinaisMarcados.length / sinais.length : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // --- 1. CABEÇALHO EXPANSIVO (PREMIUM) ---
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: corPrincipal,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("Semana ${widget.semana}", style: const TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [corPrincipal, corSecundaria],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Ícone Gigante Decorativo (Marca D'água)
                  Positioned(
                    right: -20,
                    bottom: -30,
                    child: Icon(iconeCabecalho, size: 180, color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 70,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                          child: Text(titulo.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. DESCRIÇÃO INTRODUTÓRIA ---
                  Text(
                    descricao,
                    style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey.shade800, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 30),

                  // --- 3. CHECKLIST DE SINAIS (COM BARRA DE PROGRESSO) ---
                  if (sinais.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tituloSinais, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A))),
                            Text(subTituloSinais, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                        Text("${(progressoSinais * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, color: corPrincipal, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressoSinais,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(corPrincipal),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Lista de Checkboxes Estilizada
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: sinais.asMap().entries.map((entry) {
                          int idx = entry.key;
                          String sinal = entry.value;
                          bool isChecked = _sinaisMarcados.contains(sinal);
                          bool isLast = idx == sinais.length - 1;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _toggleSinal(sinal),
                              borderRadius: isLast ? const BorderRadius.vertical(bottom: Radius.circular(16)) : (idx == 0 ? const BorderRadius.vertical(top: Radius.circular(16)) : BorderRadius.zero),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        color: isChecked ? corPrincipal : Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isChecked ? corPrincipal : Colors.grey.shade300, width: 2),
                                      ),
                                      child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Text(
                                        sinal,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isChecked ? Colors.grey : Colors.black87,
                                          decoration: isChecked ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 35),
                  ],

                  // --- 4. DICAS (Cards com Ícone) ---
                  if (dicas.isNotEmpty) ...[
                    const Text("Dicas & Cuidados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A))),
                    const SizedBox(height: 15),
                    ...dicas.map((dica) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border(left: BorderSide(color: corSecundaria, width: 4)),
                        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_circle, color: corSecundaria, size: 24),
                          const SizedBox(width: 12),
                          Expanded(child: Text(dica, style: const TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF455A64)))),
                        ],
                      ),
                    )),
                    const SizedBox(height: 35),
                  ],

                  // --- 5. HABILIDADES (Card Dourado/Destaque) ---
                  if (habilidades.isNotEmpty) ...[
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFFF8E1), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFECB3)),
                            boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("NOVAS HABILIDADES", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFFFB300), letterSpacing: 1.2)),
                              const SizedBox(height: 15),
                              ...habilidades.map((hab) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(hab, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF5D4037)))),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                        // Decoração (Medalha)
                        const Positioned(
                          right: 15, top: -15,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25,
                            child: Icon(Icons.emoji_events, color: Color(0xFFFFB300), size: 30),
                          ),
                        )
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}