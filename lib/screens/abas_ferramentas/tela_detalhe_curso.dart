import 'package:flutter/material.dart';

class TelaDetalheCurso extends StatelessWidget {
  final Map<String, dynamic> curso;

  const TelaDetalheCurso({super.key, required this.curso});

  @override
  Widget build(BuildContext context) {
    final Color corTema = Color(curso['cor']);
    final Color corFundoClaro = corTema.withOpacity(0.05);
    final List aulas = curso['aulas'];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // --- 1. CABEÇALHO EXPANSIVO (PREMIUM) ---
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: corTema,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [corTema, corTema.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // Espaço para a status bar
                    Hero(
                      tag: "icon_${curso['id']}", // Animação suave de transição
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(curso['icone'], size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        curso['titulo'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${aulas.length} Aulas Exclusivas",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. CONTEÚDO (LISTA) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SOBRE O CURSO ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          curso['subtitulo'].toUpperCase(),
                          style: TextStyle(
                            color: corTema,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          curso['descricao'],
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (curso['autor'] != null)
                          Row(
                            children: [
                              Icon(Icons.verified, size: 16, color: corTema),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  curso['autor'],
                                  style: TextStyle(
                                    color: corTema,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  const Text(
                    "CONTEÚDO DO CURSO",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          // --- 3. LISTA DE AULAS (SLIVER LIST) ---
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final aula = aulas[index];
                  // Alterna cor de fundo levemente para dar ritmo
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.03),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        childrenPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: corFundoClaro,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: corTema,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          aula['titulo'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2D3A3A),
                          ),
                        ),
                        subtitle: aula['subtitulo'] != null 
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                aula['subtitulo'],
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            )
                          : null,
                        
                        // CONTEÚDO DA AULA (EXPANDIDO)
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: corFundoClaro, // Fundo levemente colorido
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                              border: Border(top: BorderSide(color: corTema.withOpacity(0.1)))
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.menu_book, size: 18, color: corTema),
                                    const SizedBox(width: 8),
                                    Text("Leitura", style: TextStyle(color: corTema, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  aula['texto'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.7, // Altura de linha boa para leitura
                                    color: Color(0xFF37474F), // Cinza escuro suave (não preto puro)
                                    fontFamily: 'Roboto', // Fonte limpa (padrão)
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                childCount: aulas.length,
              ),
            ),
          ),
          
          // Espaço final
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}