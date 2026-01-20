import 'package:flutter/material.dart';

class StandardPageStructure extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  // Cor do cabeçalho (padrão Teal, mas pode ser mudada por tela)
  final Color headerColor; 
  // Altura da área colorida do cabeçalho
  final double headerHeight;

  const StandardPageStructure({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
    this.actions,
    this.floatingActionButton,
    this.headerColor = Colors.teal, // Cor padrão
    this.headerHeight = 200.0, // Altura padrão da área colorida
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cor de fundo geral (o que aparece atrás do "cartão" de conteúdo)
      backgroundColor: headerColor, 
      
      body: Stack(
        children: [
          // CAMADA 1: O Fundo Colorido do Cabeçalho (Fixo no topo)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: Container(
              color: headerColor,
              // Adicionamos um padrão sutil ou degradê aqui se quiser no futuro
            ),
          ),

          // CAMADA 2: O Conteúdo Principal (O "Cartão" branco)
          Positioned.fill(
            // Começa um pouco abaixo do topo para mostrar o cabeçalho
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 20, 
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB), // Cor de fundo do conteúdo (Off-white)
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30), // CURVA SUAVE NO TOPO DO CONTEÚDO
                ),
                // Sombra opcional para dar mais profundidade
                // boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
              ),
              // ClipRRect garante que o conteúdo interno respeite a curva
              child: ClipRRect(
                 borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                 child: body
              ),
            ),
          ),

          // CAMADA 3: A AppBar (Transparente, flutuando sobre tudo)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Transparente!
              foregroundColor: Colors.white,
              elevation: 0, // Sem sombra na AppBar
              actions: actions,
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}