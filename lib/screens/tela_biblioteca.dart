import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/atividade.dart';
import 'tela_detalhes.dart';

class TelaBiblioteca extends StatefulWidget {
  const TelaBiblioteca({super.key});

  @override
  State<TelaBiblioteca> createState() => _TelaBibliotecaState();
}

class _TelaBibliotecaState extends State<TelaBiblioteca> {
  String filtroIdade = 'Todas';
  String _termoBusca = '';

  // Função de Cores
  Color _getCorCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'motor': return Colors.orange.shade700;
      case 'cognitivo': return Colors.blue.shade700;
      case 'sensorial': return Colors.purple.shade700;
      case 'social': return Colors.green.shade700;
      case 'linguagem': return Colors.pink.shade700;
      case 'auditivo': return Colors.amber.shade800;
      default: return Colors.teal;
    }
  }

  Widget _construirImagem(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url, fit: BoxFit.cover, height: 80, width: 80,
        errorBuilder: (context, error, stackTrace) => Container(height: 80, width: 80, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
    return Container(height: 80, width: 80, color: Colors.teal.withOpacity(0.1), child: const Icon(Icons.image, color: Colors.teal));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biblioteca de Atividades"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (texto) => setState(() => _termoBusca = texto),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar (ex: bola, sensorial)...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true, fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filtroIdade,
                      isExpanded: true,
                      icon: const Icon(Icons.filter_list, color: Colors.teal),
                      items: ['Todas', '0-3 meses', '3-6 meses', '6-9 meses', '9-12 meses', '2-3 anos']
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => filtroIdade = v!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('atividades').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Erro ao carregar."));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                final lista = docs.map((doc) {
                  return Atividade.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                }).where((atv) {
                  bool passaIdade = (filtroIdade == 'Todas') || (atv.idadeAlvo == filtroIdade);
                  bool passaBusca = _termoBusca.isEmpty || 
                                    atv.titulo.toLowerCase().contains(_termoBusca.toLowerCase()) || 
                                    atv.categoria.toLowerCase().contains(_termoBusca.toLowerCase());
                  return passaIdade && passaBusca;
                }).toList();

                if (lista.isEmpty) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: const [
                         Icon(Icons.search_off, size: 50, color: Colors.grey),
                         SizedBox(height: 10),
                         Text("Nenhuma atividade encontrada.", style: TextStyle(color: Colors.grey)),
                       ],
                     ),
                   );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 10),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final atv = lista[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaDetalhes(atividade: atv))),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8), 
                                child: _construirImagem(atv.imagemUrl)
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(atv.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        // ETIQUETA COLORIDA
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _getCorCategoria(atv.categoria).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            atv.categoria,
                                            style: TextStyle(
                                              fontSize: 11, 
                                              fontWeight: FontWeight.bold, 
                                              color: _getCorCategoria(atv.categoria)
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "•  ${atv.idadeAlvo}",
                                          style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}