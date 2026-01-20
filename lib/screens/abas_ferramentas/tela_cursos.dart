import 'package:flutter/material.dart';
import '../../data/conteudo_cursos.dart';
import 'tela_detalhe_curso.dart'; 

class TelaCursos extends StatelessWidget {
  const TelaCursos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: ListView.builder(
        // --- CORREÇÃO DE PADDING ---
        // Aumentado bottom para 160 para compensar a barra de navegação da TelaBase
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 160), 
        
        itemCount: cursosPremium.length,
        itemBuilder: (context, index) {
          final curso = cursosPremium[index];
          final Color cor = Color(curso['cor']);
          final int totalAulas = (curso['aulas'] as List).length;
          
          // Design diferenciado para o primeiro item (Destaque)
          final bool isDestaque = index == 0; 

          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => TelaDetalheCurso(curso: curso)));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 25),
              height: isDestaque ? 160 : 130, // Destaque é maior
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: cor.withOpacity(0.15), 
                    blurRadius: 20, 
                    offset: const Offset(0, 8),
                    spreadRadius: -5
                  )
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.05)),
              ),
              child: Stack(
                children: [
                  // FUNDO DECORATIVO
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: cor.withOpacity(0.05),
                    ),
                  ),
                  
                  Row(
                    children: [
                      // ÁREA DO ÍCONE
                      Container(
                        width: isDestaque ? 130 : 110,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.1),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Hero(
                              tag: "icon_${curso['id']}", 
                              child: Icon(curso['icone'], size: isDestaque ? 60 : 45, color: cor)
                            ),
                            // Badge "Premium" ou "Novo"
                            if (isDestaque)
                              Positioned(
                                top: 12, left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                  child: Text("NOVO", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: cor)),
                                ),
                              )
                          ],
                        ),
                      ),
                      
                      // ÁREA DE CONTEÚDO
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Categoria pequena
                              Text(
                                "CURSO COMPLETO", 
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.0)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                curso['titulo'], 
                                style: TextStyle(
                                  fontSize: isDestaque ? 20 : 17, 
                                  fontWeight: FontWeight.w800, 
                                  color: const Color(0xFF2D3A3A),
                                  height: 1.1
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                curso['subtitulo'], 
                                maxLines: 2, 
                                overflow: TextOverflow.ellipsis, 
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3)
                              ),
                              const Spacer(),
                              
                              // RODAPÉ DO CARD
                              Row(
                                children: [
                                  Icon(Icons.play_circle_fill, size: 16, color: cor),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$totalAulas Aulas", 
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.bold)
                                  ),
                                  const Spacer(),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300)
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}