import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/bebe_service.dart';

class AbaCrescimento extends StatefulWidget { 
  const AbaCrescimento({super.key});

  @override
  State<AbaCrescimento> createState() => _AbaCrescimentoState(); 
}

class _AbaCrescimentoState extends State<AbaCrescimento> {
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _perimetroController = TextEditingController(); 
  DateTime _dataSelecionada = DateTime.now();

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    _perimetroController.dispose();
    super.dispose();
  }

  void _abrirFormulario({DocumentSnapshot? doc}) {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      _pesoController.text = data['peso'].toString();
      _alturaController.text = data['altura'].toString();
      _perimetroController.text = (data['perimetro'] ?? '').toString();
      _dataSelecionada = DateTime.parse(data['data']);
    } else {
      _pesoController.clear();
      _alturaController.clear();
      _perimetroController.clear();
      _dataSelecionada = DateTime.now();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Text("Registrar Medidas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)))),
              const SizedBox(height: 25),
              
              // DATA
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _dataSelecionada, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (d != null) setState(() => _dataSelecionada = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: Colors.indigo, size: 20),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("DATA DA MEDIÇÃO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // CAMPOS DE MEDIDA (GRID)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pesoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Peso (kg)", 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: const Icon(Icons.monitor_weight_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA)
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _alturaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Altura (cm)", 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: const Icon(Icons.height_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA)
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _perimetroController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Perímetro Cefálico (cm)", 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.face_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA)
                ),
              ),

              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final bebeRef = await BebeService.getRefBebeAtivo();
                    if (bebeRef == null) return;

                    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0;
                    final altura = double.tryParse(_alturaController.text.replaceAll(',', '.')) ?? 0.0;
                    final perimetro = double.tryParse(_perimetroController.text.replaceAll(',', '.')) ?? 0.0;

                    final dados = {
                      'peso': peso,
                      'altura': altura,
                      'perimetro': perimetro,
                      'data': _dataSelecionada.toIso8601String(),
                    };

                    if (doc == null) {
                      await bebeRef.collection('medidas').add(dados);
                    } else {
                      await doc.reference.update(dados);
                    }

                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Medidas salvas!"), backgroundColor: Colors.indigo));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5), // Indigo 500
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0
                  ),
                  child: const Text("SALVAR MEDIDAS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      
      // --- CORREÇÃO AQUI ---
      // Aumentei o padding bottom para 140. 
      // A barra tem ~80px + margem + safeArea. 140px garante que o botão fique visível.
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140), 
        child: FloatingActionButton.extended(
          onPressed: () => _abrirFormulario(),
          backgroundColor: const Color(0xFF3F51B5),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text("Nova Medida", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      
      body: FutureBuilder<DocumentReference?>(
        future: BebeService.getRefBebeAtivo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          final bebeRef = snapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: bebeRef.collection('medidas').orderBy('data', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.straighten_rounded, size: 60, color: Colors.indigo.withOpacity(0.2)),
                      const SizedBox(height: 15),
                      Text("Nenhuma medida registrada.", style: TextStyle(color: Colors.indigo.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              final ultimoRegistro = docs.first;
              final historico = docs.sublist(1);

              return ListView(
                // Mantemos o padding da lista em 160 para o último item não cortar
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
                children: [
                  // --- CARD DESTAQUE (ÚLTIMA MEDIDA) ---
                  _buildCardDestaque(ultimoRegistro),
                  
                  const SizedBox(height: 30),
                  
                  if (historico.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(left: 10, bottom: 15),
                      child: Text("HISTÓRICO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                    ),

                  // --- LISTA HISTÓRICO ---
                  ...historico.map((doc) => _buildItemHistorico(doc))
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCardDestaque(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final date = DateTime.parse(data['data']);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Medida Atual", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd ' 'MMM' ' yyyy', 'pt_BR').format(date).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              ),
              IconButton(onPressed: () => _abrirFormulario(doc: doc), icon: const Icon(Icons.edit_rounded, color: Colors.white70))
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoDestaque("${data['peso']} kg", "Peso", Icons.monitor_weight_outlined),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildInfoDestaque("${data['altura']} cm", "Altura", Icons.height_rounded),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildInfoDestaque("${data['perimetro'] ?? '-'} cm", "Cabeça", Icons.face_rounded),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoDestaque(String valor, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }

  Widget _buildItemHistorico(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final date = DateTime.parse(data['data']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3A3A))),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              _buildTagHistorico("${data['peso']}kg", Colors.blue),
              const SizedBox(width: 10),
              _buildTagHistorico("${data['altura']}cm", Colors.orange),
            ],
          ),
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text("Editar")),
            const PopupMenuItem(value: 'delete', child: Text("Excluir", style: TextStyle(color: Colors.red))),
          ],
          onSelected: (v) {
            if (v == 'edit') _abrirFormulario(doc: doc);
            if (v == 'delete') doc.reference.delete();
          },
        ),
      ),
    );
  }

  Widget _buildTagHistorico(String texto, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: cor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(texto, style: TextStyle(color: cor.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}