import 'package:flutter/material.dart';
import '../utils/calculadora_desenvolvimento.dart'; // <--- Importe a calculadora

class LinhaTempoBebe extends StatefulWidget {
  final int semanaSelecionada;
  final int semanaReal;
  final Function(int) onSemanaSelecionada;

  const LinhaTempoBebe({
    super.key, 
    required this.semanaSelecionada, 
    required this.semanaReal,
    required this.onSemanaSelecionada,
  });

  @override
  State<LinhaTempoBebe> createState() => _LinhaTempoBebeState();
}

class _LinhaTempoBebeState extends State<LinhaTempoBebe> {
  ScrollController? _scrollController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Centraliza na semana SELECIONADA
    _scrollController ??= ScrollController(
      initialScrollOffset: (widget.semanaSelecionada * 78.0) - (MediaQuery.of(context).size.width / 2) + 35, 
    );
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125, 
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 80, 
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final semana = index + 1;
          
          // --- AQUI ESTÁ A MÁGICA: USA A CALCULADORA ---
          final status = CalculadoraDesenvolvimento.getStatusSemana(semana);
          // ---------------------------------------------
          
          final bool isSelecionado = semana == widget.semanaSelecionada;
          final bool isHoje = semana == widget.semanaReal;
          
          Color corBg;
          Color corIcone;
          IconData icone;
          double tamanhoBola = isSelecionado ? 60 : 45;

          if (status == 'raio') {
            corBg = const Color(0xFFFFF3E0);
            corIcone = const Color(0xFFFF9800);
            icone = Icons.flash_on;
          } else if (status == 'nuvem') {
            corBg = const Color(0xFFECEFF1);
            corIcone = const Color(0xFF78909C);
            icone = Icons.cloud;
          } else {
            corBg = const Color(0xFFE0F2F1);
            corIcone = const Color(0xFF4E8D7C);
            icone = Icons.wb_sunny;
          }

          if (isSelecionado) {
            corBg = corIcone;
            corIcone = Colors.white;
          }

          return GestureDetector(
            onTap: () => widget.onSemanaSelecionada(semana),
            child: Container(
              width: 78,
              color: Colors.transparent,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isHoje)
                    const Icon(Icons.arrow_drop_down, color: Colors.teal, size: 20)
                  else
                    const SizedBox(height: 20),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    height: tamanhoBola,
                    width: tamanhoBola,
                    decoration: BoxDecoration(
                      color: corBg.withValues(alpha: isSelecionado ? 1.0 : 0.5),
                      shape: BoxShape.circle,
                      border: isSelecionado 
                        ? Border.all(color: Colors.white, width: 3) 
                        : Border.all(color: corIcone.withValues(alpha: 0.3), width: 1),
                      boxShadow: isSelecionado 
                        ? [BoxShadow(color: corBg.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))] 
                        : [],
                    ),
                    child: Icon(icone, color: corIcone, size: isSelecionado ? 28 : 20),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    "$semana",
                    style: TextStyle(
                      fontWeight: isSelecionado ? FontWeight.w900 : FontWeight.bold,
                      color: isSelecionado ? const Color(0xFF2D3A3A) : Colors.grey,
                      fontSize: isSelecionado ? 16 : 12,
                    ),
                  ),
                  
                  if (isHoje && !isSelecionado)
                    const Text("Hoje", style: TextStyle(fontSize: 9, color: Colors.teal, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}