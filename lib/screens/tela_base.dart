import 'dart:ui'; // Necessário para o Blur
import 'package:flutter/material.dart';

// --- IMPORTS DAS TELAS ---
// Certifique-se que os arquivos estão na mesma pasta ou ajuste os caminhos
import 'tela_principal.dart';       
import 'tela_rotina_hub.dart';      
import 'tela_ferramentas.dart';     
import 'tela_saude.dart';           
import 'tela_progresso.dart';       

class TelaBase extends StatefulWidget {
  const TelaBase({super.key});

  @override
  State<TelaBase> createState() => _TelaBaseState();
}

class _TelaBaseState extends State<TelaBase> {
  int _indiceAtual = 0;

  final List<Widget> _telas = [
    const TelaPrincipal(), 
    const TelaRotinaHub(), 
    const TelaFerramentas(), 
    const TelaSaude(), 
    const TelaProgresso(), 
  ];

  void _onTabTapped(int index) {
    setState(() => _indiceAtual = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), 
      extendBody: true, // O conteúdo passa por trás da barra (importante!)
      
      body: IndexedStack(
        index: _indiceAtual,
        children: _telas,
      ),
      
      bottomNavigationBar: _buildFloatingGlassDock(context),
    );
  }

  Widget _buildFloatingGlassDock(BuildContext context) {
    // 1. Pega a altura da barra de sistema do Android/iOS (Botões ou Gesto)
    final double safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      // 2. Margem Inferior Dinâmica:
      // 20px (Espaço visual que queremos) + safeAreaBottom (Altura dos botões do Android)
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + safeAreaBottom), 
      
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 75, // Altura da doca
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.local_activity_outlined, Icons.local_activity_rounded, "Atividades"),
                _buildNavItem(1, Icons.access_time, Icons.access_time_filled_rounded, "Rotina"),
                _buildNavItem(2, Icons.grid_view, Icons.grid_view_rounded, "Ferramentas"),
                _buildNavItem(3, Icons.medical_services_outlined, Icons.medical_services_rounded, "Saúde"),
                _buildNavItem(4, Icons.show_chart_rounded, Icons.bar_chart_rounded, "Evolução"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconOff, IconData iconOn, String label) {
    bool isSelected = _indiceAtual == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D3A3A) : Colors.transparent, 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? iconOn : iconOff,
              color: isSelected ? Colors.white : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade500,
              ),
            )
          ],
        ),
      ),
    );
  }
}