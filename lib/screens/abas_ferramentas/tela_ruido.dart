import 'package:flutter/material.dart';
import 'dart:ui'; 
import '../../services/sono_global_service.dart';

class TelaRuido extends StatefulWidget {
  const TelaRuido({super.key});

  @override
  State<TelaRuido> createState() => _TelaRuidoState();
}

class _TelaRuidoState extends State<TelaRuido> with SingleTickerProviderStateMixin {
  final _globalService = SonoGlobalService();
  late AnimationController _waveController;

  final List<Map<String, dynamic>> _sons = [
    {'id': 'branco',  'label': 'R. Branco', 'file': 'branco.mp3',  'icon': Icons.radio,       'cor': Colors.grey},
    {'id': 'chuva',   'label': 'Chuva',     'file': 'chuva.mp3',   'icon': Icons.thunderstorm,'cor': Colors.blue},
    {'id': 'lareira', 'label': 'Lareira',   'file': 'lareira.mp3', 'icon': Icons.fireplace,   'cor': Colors.deepOrange},
    {'id': 'mar',     'label': 'Mar',       'file': 'mar.mp3',     'icon': Icons.tsunami,     'cor': Colors.cyan},
    {'id': 'shhh',    'label': 'Shhh',      'file': 'shhh.mp3',    'icon': Icons.mic_off,     'cor': Colors.indigo},
    {'id': 'utero',   'label': 'Útero',     'file': 'utero.mp3',   'icon': Icons.favorite,    'cor': Colors.pinkAccent},
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _abrirTimerSom() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E), 
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Temporizador", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
            const SizedBox(height: 20),
            _buildOpcaoTimer(15, "15 min"),
            _buildOpcaoTimer(30, "30 min"),
            _buildOpcaoTimer(45, "45 min"),
            _buildOpcaoTimer(60, "1 hora"),
            _buildOpcaoTimer(0, "Infinito (Desativar)"),
          ],
        ),
      )
    );
  }

  Widget _buildOpcaoTimer(int minutos, String label) {
    return ListTile(
      leading: Icon(minutos == 0 ? Icons.all_inclusive : Icons.timer, color: Colors.white54),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        _globalService.definirTempoDesligamento(minutos);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(minutos == 0 ? "Timer desativado" : "Som desligará em $label"),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Altura da tela para cálculos responsivos
    final screenHeight = MediaQuery.of(context).size.height;

    return ValueListenableBuilder<bool>(
      valueListenable: _globalService.tocandoNotifier,
      builder: (ctx, tocando, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _globalService.somAtivoIdNotifier,
          builder: (ctx, somAtivo, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: _globalService.timerDesligamentoNotifier,
              builder: (ctx, tempoRestante, _) {
                
                final dadosSomAtivo = _sons.firstWhere((s) => s['id'] == somAtivo, orElse: () => _sons[0]);
                final corAtiva = tocando ? (dadosSomAtivo['cor'] as Color) : Colors.white24;

                return Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: const BackButton(color: Colors.white),
                  ),
                  body: Container(
                    width: double.infinity,
                    height: double.infinity, // Garante que o gradiente cubra tudo
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    // CORREÇÃO AQUI: SingleChildScrollView para permitir rolagem
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Espaço para a AppBar
                          SizedBox(height: MediaQuery.of(context).padding.top + 20),

                          // --- 1. VISUALIZADOR CENTRAL (40% da tela) ---
                          SizedBox(
                            height: screenHeight * 0.40, // Altura fixa responsiva
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (tocando)
                                  ScaleTransition(
                                    scale: Tween(begin: 1.0, end: 1.4).animate(CurvedAnimation(parent: _waveController, curve: Curves.easeInOut)),
                                    child: Container(
                                      width: 160, height: 160,
                                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: corAtiva.withOpacity(0.2), width: 2)),
                                    ),
                                  ),
                                if (tocando)
                                  ScaleTransition(
                                    scale: Tween(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _waveController, curve: Curves.easeInOut)),
                                    child: Container(
                                      width: 160, height: 160,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: corAtiva.withOpacity(0.1)),
                                    ),
                                  ),
                                
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(tocando ? dadosSomAtivo['icon'] : Icons.nights_stay, size: 60, color: Colors.white.withOpacity(0.9)),
                                    const SizedBox(height: 15),
                                    Text(tocando ? dadosSomAtivo['label'] : "Modo Noturno", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    const SizedBox(height: 5),
                                    Text(tocando ? "Tocando agora" : "Selecione um som", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // --- 2. TIMER ---
                          if (tocando)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: GestureDetector(
                                onTap: _abrirTimerSom,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white12)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.timer_outlined, color: tempoRestante != null ? Colors.tealAccent : Colors.white54, size: 18),
                                      const SizedBox(width: 8),
                                      Text(tempoRestante ?? "Definir Timer", style: TextStyle(color: tempoRestante != null ? Colors.tealAccent : Colors.white70, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // --- 3. GRID DE SONS (ÁREA ROLÁVEL) ---
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(24, 30, 24, 50), // Padding inferior extra para scroll
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                            child: GridView.count(
                              crossAxisCount: 3,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              shrinkWrap: true, // IMPORTANTE: Permite que o Grid fique dentro do ScrollView
                              physics: const NeverScrollableScrollPhysics(), // Desativa rolagem interna do grid
                              children: _sons.map((som) {
                                bool isSelected = somAtivo == som['id'] && tocando;
                                return GestureDetector(
                                  onTap: () => _globalService.toggleSom(som['id'], som['file'], 1.0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    decoration: BoxDecoration(
                                      color: isSelected ? (som['cor'] as Color).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: isSelected ? (som['cor'] as Color) : Colors.white10, width: isSelected ? 2 : 1),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(isSelected ? Icons.pause_circle_filled : som['icon'], color: isSelected ? (som['cor'] as Color) : Colors.white70, size: 32),
                                        const SizedBox(height: 8),
                                        Text(som['label'], style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.white54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}