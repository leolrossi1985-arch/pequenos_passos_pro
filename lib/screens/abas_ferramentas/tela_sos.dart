import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/conteudo_sos.dart';

class TelaSOS extends StatelessWidget {
  const TelaSOS({super.key});

  Future<void> _ligarEmergencia() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '192');
    try { 
      if (await canLaunchUrl(launchUri)) await launchUrl(launchUri); 
    } catch (e) { 
      debugPrint("Erro: $e"); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 25),
                
                // --- 1. BOTÃO DE EMERGÊNCIA (HERO) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _ligarEmergencia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F), // Vermelho Material 700
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone_in_talk_rounded, size: 28),
                          ),
                          const SizedBox(width: 15),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("LIGAR SAMU", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              Text("Emergência Nacional 192", style: TextStyle(fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- 2. DISCLAIMER (AVISO LEGAL) ---
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Este é um guia rápido de referência.\nEm emergências reais, busque ajuda profissional imediatamente.",
                          style: TextStyle(color: Colors.red.shade900, fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Row(
                    children: const [
                      Icon(Icons.medical_services_outlined, color: Colors.grey, size: 20),
                      SizedBox(width: 10),
                      Text("PRIMEIROS SOCORROS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- 3. LISTA DE GUIAS ---
          SliverPadding(
            // --- CORREÇÃO AQUI ---
            // Aumentado bottom para 160
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
            
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final guia = guiasSOS[index];
                  final Color corGuia = guia['cor'] as Color;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: corGuia.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(guia['icone'], color: corGuia, size: 24),
                        ),
                        title: Text(
                          guia['titulo'], 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3A3A)),
                        ),
                        
                        // --- CONTEÚDO EXPANDIDO (PASSOS) ---
                        children: [
                          const Divider(),
                          const SizedBox(height: 10),
                          ...(guia['passos'] as List<String>).asMap().entries.map((entry) {
                            int idx = entry.key + 1;
                            String passo = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bolinha com número
                                  Container(
                                    width: 24, height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: corGuia,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "$idx",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Texto do passo
                                  Expanded(
                                    child: Text(
                                      passo,
                                      style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF455A64)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
                childCount: guiasSOS.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}