import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/dentes_service.dart';

class AbaDentes extends StatefulWidget { 
  const AbaDentes({super.key});

  @override
  State<AbaDentes> createState() => _AbaDentesState(); 
}

class _AbaDentesState extends State<AbaDentes> {
  Map<String, DateTime> _dentesNascidos = {};

  final List<Map<String, dynamic>> _arcadaMap = [
    // --- SUPERIOR ---
    {'id': 's_molar2_esq',  'x': -0.85, 'y': -0.30, 'nome': '2º Molar Sup Esq', 'meses': '25-33m', 'tipo': 'molar'},
    {'id': 's_molar1_esq',  'x': -0.72, 'y': -0.50, 'nome': '1º Molar Sup Esq', 'meses': '13-19m', 'tipo': 'molar'},
    {'id': 's_canino_esq',  'x': -0.55, 'y': -0.65, 'nome': 'Canino Sup Esq',   'meses': '16-22m', 'tipo': 'canino'},
    {'id': 's_lateral_esq', 'x': -0.35, 'y': -0.78, 'nome': 'Lateral Sup Esq',  'meses': '9-13m',  'tipo': 'incisivo'},
    {'id': 's_central_esq', 'x': -0.12, 'y': -0.85, 'nome': 'Central Sup Esq',  'meses': '8-12m',  'tipo': 'incisivo'},
    {'id': 's_central_dir', 'x': 0.12,  'y': -0.85, 'nome': 'Central Sup Dir',  'meses': '8-12m',  'tipo': 'incisivo'},
    {'id': 's_lateral_dir', 'x': 0.35,  'y': -0.78, 'nome': 'Lateral Sup Dir',  'meses': '9-13m',  'tipo': 'incisivo'},
    {'id': 's_canino_dir',  'x': 0.55,  'y': -0.65, 'nome': 'Canino Sup Dir',   'meses': '16-22m', 'tipo': 'canino'},
    {'id': 's_molar1_dir',  'x': 0.72,  'y': -0.50, 'nome': '1º Molar Sup Dir', 'meses': '13-19m', 'tipo': 'molar'},
    {'id': 's_molar2_dir',  'x': 0.85,  'y': -0.30, 'nome': '2º Molar Sup Dir', 'meses': '25-33m', 'tipo': 'molar'},

    // --- INFERIOR ---
    {'id': 'i_molar2_esq',  'x': -0.85, 'y': 0.30, 'nome': '2º Molar Inf Esq', 'meses': '23-31m', 'tipo': 'molar'},
    {'id': 'i_molar1_esq',  'x': -0.72, 'y': 0.50, 'nome': '1º Molar Inf Esq', 'meses': '14-18m', 'tipo': 'molar'},
    {'id': 'i_canino_esq',  'x': -0.55, 'y': 0.65, 'nome': 'Canino Inf Esq',   'meses': '17-23m', 'tipo': 'canino'},
    {'id': 'i_lateral_esq', 'x': -0.35, 'y': 0.78, 'nome': 'Lateral Inf Esq',  'meses': '10-16m', 'tipo': 'incisivo'},
    {'id': 'i_central_esq', 'x': -0.12, 'y': 0.85, 'nome': 'Central Inf Esq',  'meses': '6-10m',  'tipo': 'incisivo'},
    {'id': 'i_central_dir', 'x': 0.12,  'y': 0.85, 'nome': 'Central Inf Dir',  'meses': '6-10m',  'tipo': 'incisivo'},
    {'id': 'i_lateral_dir', 'x': 0.35,  'y': 0.78, 'nome': 'Lateral Inf Dir',  'meses': '10-16m', 'tipo': 'incisivo'},
    {'id': 'i_canino_dir',  'x': 0.55,  'y': 0.65, 'nome': 'Canino Inf Dir',   'meses': '17-23m', 'tipo': 'canino'},
    {'id': 'i_molar1_dir',  'x': 0.72,  'y': 0.50, 'nome': '1º Molar Inf Dir', 'meses': '14-18m', 'tipo': 'molar'},
    {'id': 'i_molar2_dir',  'x': 0.85,  'y': 0.30, 'nome': '2º Molar Inf Dir', 'meses': '23-31m', 'tipo': 'molar'},
  ];

  void _toggleDente(String id, String nome) {
    if (_dentesNascidos.containsKey(id)) {
      DentesService.desmarcarDente(id);
    } else {
      DentesService.marcarDente(id, nome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: DentesService.streamDentes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _dentesNascidos = {};
          for (var doc in snapshot.data!.docs) {
            _dentesNascidos[doc.id] = DateTime.parse(doc['data_nascimento']);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // CARD DE PROGRESSO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF80CBC4), Color(0xFF4DB6AC)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.face_retouching_natural, color: Colors.white, size: 28),
                    const SizedBox(width: 15),
                    Column(
                      children: [
                        const Text("DENTIÇÃO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Text("${_dentesNascidos.length} / 20", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // --- ARCADA PREMIUM ---
              SizedBox(
                height: 380, 
                width: 320,
                child: Stack(
                  children: [
                    // GENGIVA (Gradiente Radial para profundidade)
                    Center(
                      child: Container(
                        width: 300, height: 360,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Colors.red.shade100, Colors.red.shade300],
                            center: Alignment.center,
                            radius: 0.8
                          ),
                          borderRadius: const BorderRadius.all(Radius.elliptical(300, 360)),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                          ]
                        ),
                      ),
                    ),
                    
                    // FUNDO DA BOCA (Profundidade simulada com cor escura)
                    Center(
                      child: Container(
                        width: 160, height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E2723).withOpacity(0.3), // Cor de fundo da boca
                          borderRadius: const BorderRadius.all(Radius.elliptical(160, 200)),
                        ),
                      ),
                    ),
                    
                    // DENTES
                    ..._arcadaMap.map((dente) {
                      bool nasceu = _dentesNascidos.containsKey(dente['id']);
                      bool isSuperior = dente['y'] < 0;

                      return Align(
                        alignment: Alignment(dente['x'], dente['y']),
                        child: _ToothWidget(
                          denteData: dente,
                          nasceu: nasceu,
                          isSuperior: isSuperior,
                          onTap: () => _abrirInfoDente(dente, nasceu),
                        ),
                      );
                    }),

                    const Align(alignment: Alignment(0, -0.15), child: Text("SUPERIOR", style: TextStyle(color: Colors.black12, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2))),
                    const Align(alignment: Alignment(0, 0.15), child: Text("INFERIOR", style: TextStyle(color: Colors.black12, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2))),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              Text("Toque no dente para detalhes", style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  void _abrirInfoDente(Map<String, dynamic> dente, bool nasceu) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: nasceu ? Colors.teal.shade50 : Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.face, size: 40, color: nasceu ? Colors.teal : Colors.grey)
            ),
            const SizedBox(height: 15),
            Text(dente['nome'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)), 
              child: Text("Previsão: ${dente['meses']}", style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold))
            ),
            const SizedBox(height: 25),
            
            Text(
              "O nascimento deste dente pode causar coceira na gengiva e salivação. Dica: Mordedores gelados ajudam muito!", 
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 14)
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () { 
                  _toggleDente(dente['id'], dente['nome']); 
                  Navigator.pop(ctx); 
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: nasceu ? Colors.red.shade50 : const Color(0xFF2D3A3A), 
                  foregroundColor: nasceu ? Colors.red : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                child: Text(nasceu ? "REMOVER (CORRIGIR)" : "JÁ NASCEU! 🎉", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              )
            )
          ],
        ),
      )
    );
  }
}

// --- WIDGET DO DENTE (CORRIGIDO SEM 'inset') ---
class _ToothWidget extends StatelessWidget {
  final Map<String, dynamic> denteData;
  final bool nasceu;
  final VoidCallback onTap;
  final bool isSuperior;

  const _ToothWidget({required this.denteData, required this.nasceu, required this.onTap, required this.isSuperior});

  @override
  Widget build(BuildContext context) {
    String tipo = denteData['tipo'];
    double w = 35; double h = 42;
    BorderRadius radius;

    if (tipo == 'molar') { 
      w = 46; h = 38; 
      radius = BorderRadius.circular(12); 
    } else if (tipo == 'canino') { 
       w = 34; h = 46; 
       radius = BorderRadius.vertical(top: Radius.circular(isSuperior?8:22), bottom: Radius.circular(isSuperior?22:8));
    } else { // Incisivo
      w = 38; h = 46;
      radius = BorderRadius.vertical(top: Radius.circular(isSuperior?8:16), bottom: Radius.circular(isSuperior?16:8));
    }
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut, 
        width: w, height: h,
        decoration: BoxDecoration(
          // GRADIENTE SUBSTITUI A SOMBRA INTERNA
          gradient: nasceu 
            ? const LinearGradient(
                colors: [Colors.white, Color(0xFFEEEEEE)], // Branco perolado
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
              )
            : LinearGradient(
                colors: [const Color(0xFFFFEBEE).withOpacity(0.6), const Color(0xFFFFCDD2).withOpacity(0.6)], // Gengiva pálida
                begin: Alignment.topLeft,
                end: Alignment.bottomRight
              ),
          
          borderRadius: radius,
          
          // Sombra EXTERNA normal (essa funciona)
          boxShadow: nasceu ? [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2)), 
          ] : [],
          
          border: Border.all(color: nasceu ? Colors.grey.shade300 : Colors.red.shade100, width: nasceu ? 0.5 : 1),
        ),
        child: nasceu ? Center(child: Icon(Icons.check_rounded, size: 18, color: Colors.teal.shade300)) : null,
      ),
    );
  }
}