import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/bebe_service.dart';

class AbaSintomas extends StatefulWidget {
  const AbaSintomas({super.key});

  @override
  State<AbaSintomas> createState() => _AbaSintomasState();
}

class _AbaSintomasState extends State<AbaSintomas> {
  
  void _abrirFormSintomas() { 
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, // Fundo transparente para bordas arredondadas
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _ModalSintomas()
      )
    ); 
  }

  // Helper para ícones
  IconData _getIconeSintoma(String tipo) {
    switch (tipo) {
      case 'Febre': return Icons.thermostat_rounded;
      case 'Tosse': return Icons.sick_rounded; 
      case 'Vômito': return Icons.waves_rounded;
      case 'Pele': return Icons.back_hand_rounded;
      case 'Choro': return Icons.mood_bad_rounded;
      default: return Icons.healing_rounded;
    }
  }

  // Helper para cores
  Color _getCorSintoma(String tipo) {
    switch (tipo) {
      case 'Febre': return Colors.red;
      case 'Tosse': return Colors.orange;
      case 'Vômito': return Colors.brown;
      case 'Pele': return Colors.pinkAccent;
      case 'Choro': return Colors.purple;
      default: return Colors.teal;
    }
  }

  Color _getCorIntensidade(String intensidade) {
    if (intensidade == 'Grave') return Colors.red.shade700;
    if (intensidade == 'Moderada') return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      
      // --- CORREÇÃO 1: Botão Flutuante Ajustado ---
      // Padding bottom de 140 para subir o botão acima da barra de navegação
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140),
        child: FloatingActionButton.extended(
          heroTag: "btnSintomas", 
          onPressed: _abrirFormSintomas, 
          backgroundColor: const Color(0xFFD32F2F), // Vermelho Médico
          foregroundColor: Colors.white, 
          elevation: 4,
          icon: const Icon(Icons.add_rounded), 
          label: const Text("Registrar", style: TextStyle(fontWeight: FontWeight.bold))
        ),
      ), 
      
      body: FutureBuilder<DocumentReference?>(
        future: BebeService.getRefBebeAtivo(),
        builder: (context, snapshotRef) {
          if (!snapshotRef.hasData) return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          final ref = snapshotRef.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: ref.collection('sintomas').orderBy('data', descending: true).snapshots(), 
            builder: (ctx, snap) { 
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
              
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.monitor_heart_outlined, size: 60, color: Colors.red.withOpacity(0.2)),
                       const SizedBox(height: 15),
                       Text("Nenhum sintoma registrado", style: TextStyle(color: Colors.red.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 16)),
                     ],
                   ),
                 ); 
              }
              
              return ListView.builder(
                // --- CORREÇÃO 2: Padding Bottom Aumentado ---
                // Alterado para 160 para compensar a barra de navegação
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 160), 
                itemCount: snap.data!.docs.length, 
                itemBuilder: (ctx, i) { 
                  final d = snap.data!.docs[i].data() as Map<String, dynamic>; 
                  final tipo = d['tipo'] ?? 'Outro';
                  final intensidade = d['intensidade'] ?? 'Leve';
                  
                  final corIcone = _getCorSintoma(tipo);
                  final corBadge = _getCorIntensidade(intensidade);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5)
                        )
                      ],
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ícone do Sintoma
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: corIcone.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Icon(_getIconeSintoma(tipo), color: corIcone, size: 24),
                          ),
                          const SizedBox(width: 16),
                          
                          // Conteúdo
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tipo, 
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2D3A3A))
                                    ),
                                    Text(
                                      DateFormat('dd/MM HH:mm').format(DateTime.parse(d['data'])),
                                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Badge de Intensidade
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: corBadge.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: corBadge.withOpacity(0.2))
                                  ),
                                  child: Text(
                                    intensidade.toUpperCase(), 
                                    style: TextStyle(color: corBadge, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                if (d['detalhes'] != null && d['detalhes'].toString().isNotEmpty)
                                  Text(
                                    d['detalhes'], 
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.4)
                                  ),
                              ],
                            ),
                          ),
                          
                          // Botão de Deletar Discreto
                          GestureDetector(
                            onTap: () => snap.data!.docs[i].reference.delete(),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Icon(Icons.close, size: 18, color: Colors.grey.shade300),
                            ),
                          )
                        ],
                      ),
                    ),
                  ); 
                }
              ); 
            }
          );
        }
      )
    );
  }
}

// --- MODAL PREMIUM ---
class _ModalSintomas extends StatefulWidget { const _ModalSintomas(); @override State<_ModalSintomas> createState() => _ModalSintomasState(); }
class _ModalSintomasState extends State<_ModalSintomas> {
  final _txtController = TextEditingController(); 
  String _tipoSelecionado = 'Febre'; 
  String _intensidade = 'Leve';
  final DateTime _dataOcorrencia = DateTime.now();
  final List<String> _tipos = ['Febre', 'Tosse', 'Vômito', 'Pele', 'Choro', 'Outro'];

  @override Widget build(BuildContext context) { 
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), 
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40), 
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          const Center(child: Text("Novo Sintoma", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)))), 
          const SizedBox(height: 25), 
          
          const Text("O que o bebê está sentindo?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10, 
            runSpacing: 10,
            children: _tipos.map((t) => ChoiceChip(
              label: Text(t), 
              selected: _tipoSelecionado == t, 
              selectedColor: Colors.red.shade100, 
              labelStyle: TextStyle(
                color: _tipoSelecionado == t ? Colors.red.shade900 : Colors.black87,
                fontWeight: _tipoSelecionado == t ? FontWeight.bold : FontWeight.normal
              ),
              onSelected: (v) => setState(() => _tipoSelecionado = t)
            )).toList()
          ), 
          
          const SizedBox(height: 25), 
          
          const Text("Intensidade", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              children: ['Leve', 'Moderada', 'Grave'].map((n) => Expanded(
                child: InkWell(
                  onTap: () => setState(() => _intensidade = n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _intensidade == n ? _getCorIntensidadeModal(n) : Colors.transparent,
                      borderRadius: BorderRadius.circular(11), // 12 - 1 da borda
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      n, 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: _intensidade == n ? Colors.white : Colors.black87
                      )
                    ),
                  ),
                ),
              )).toList()
            ),
          ),
          
          const SizedBox(height: 25), 
          
          TextField(
            controller: _txtController, 
            decoration: InputDecoration(
              labelText: "Detalhes (Temp, Remédio...)", 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), 
              prefixIcon: const Icon(Icons.edit_note),
              filled: true,
              fillColor: const Color(0xFFF5F7FA)
            ), 
            maxLines: 2
          ), 
          
          const SizedBox(height: 30), 
          
          SizedBox(
            width: double.infinity, height: 55, 
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F), 
                foregroundColor: Colors.white, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0
              ), 
              onPressed: () async { 
                final bebeRef = await BebeService.getRefBebeAtivo(); 
                if (bebeRef != null) { 
                  await bebeRef.collection('sintomas').add({ 'tipo': _tipoSelecionado, 'intensidade': _intensidade, 'detalhes': _txtController.text, 'data': _dataOcorrencia.toIso8601String() }); 
                } 
                if (mounted) Navigator.pop(context); 
              }, 
              child: const Text("SALVAR REGISTRO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
            )
          )
      ])
    ); 
  }

  Color _getCorIntensidadeModal(String i) {
    if (i == 'Grave') return Colors.red;
    if (i == 'Moderada') return Colors.orange;
    return Colors.green;
  }
}