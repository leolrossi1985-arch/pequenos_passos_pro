import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/atividade.dart';
import '../services/bebe_service.dart';

class TelaDetalhes extends StatefulWidget {
  final Atividade atividade;

  const TelaDetalhes({super.key, required this.atividade});

  @override
  State<TelaDetalhes> createState() => _TelaDetalhesState();
}

class _TelaDetalhesState extends State<TelaDetalhes> {
  bool _isConcluido = false;
  Timer? _timer;
  int _segundos = 0;
  bool _rodando = false;

  @override
  void initState() {
    super.initState();
    _verificarConclusao();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _verificarConclusao() async {
    final ref = await BebeService.getRefBebeAtivo();
    if (ref != null) {
      final hojeStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final doc = await ref.collection('metas_diarias').doc(hojeStr).get();
      if (doc.exists) {
        List concluidas = doc.data()?['concluidas'] ?? [];
        if (mounted) {
          setState(() {
            _isConcluido = concluidas.contains(widget.atividade.id);
          });
        }
      }
    }
  }

  void _toggleConclusao() async {
    final ref = await BebeService.getRefBebeAtivo();
    if (ref == null) return;
    final hojeStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() => _isConcluido = !_isConcluido);

    final docRef = ref.collection('metas_diarias').doc(hojeStr);
    final doc = await docRef.get();
    
    if (doc.exists) {
      List concluidas = List.from(doc.data()?['concluidas'] ?? []);
      if (_isConcluido) {
        if (!concluidas.contains(widget.atividade.id)) concluidas.add(widget.atividade.id);
      } else {
        concluidas.remove(widget.atividade.id);
      }
      await docRef.update({'concluidas': concluidas});
    }
    
    if (_isConcluido && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Concluído! 🎉"), backgroundColor: Colors.green));
    }
  }

  void _toggleTimer() {
    if (_rodando) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _segundos++);
      });
    }
    setState(() => _rodando = !_rodando);
  }

  String _formatarTempo(int s) {
    int min = s ~/ 60;
    int sec = s % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: widget.atividade.cor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.atividade.categoria.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, shadows: [Shadow(color: Colors.black45, blurRadius: 5)]),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: widget.atividade.cor.withOpacity(0.2)),
                  Center(
                    child: Hero(
                      tag: widget.atividade.id,
                      child: Image.network(
                        widget.atividade.imagemUrl,
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (_,__,___) => Icon(Icons.image, size: 80, color: widget.atividade.cor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.atividade.titulo,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blueGrey[900], height: 1.2),
                    ),
                    const SizedBox(height: 15),
                    
                    // --- CHIPS (IDADE, CATEGORIA e TEMPO) ---
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip(widget.atividade.idadeAlvo, Icons.child_care, Colors.blue),
                          const SizedBox(width: 10),
                          _buildChip(widget.atividade.categoria, Icons.category, widget.atividade.cor),
                          const SizedBox(width: 10),
                          
                          // AQUI ESTÁ O TEMPO QUE VOCÊ PEDIU:
                          _buildChip(widget.atividade.tempo, Icons.timer, Colors.orange),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: widget.atividade.cor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: widget.atividade.cor.withOpacity(0.3))),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb, color: widget.atividade.cor),
                          const SizedBox(width: 12),
                          Expanded(child: Text(widget.atividade.descricaoCurta, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.atividade.cor.withOpacity(0.8)))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text("Como fazer", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(widget.atividade.instrucoesCompletas, style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800])),

                    const SizedBox(height: 40),

                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                        child: Column(
                          children: [
                            const Text("Cronômetro de Prática", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(_formatarTempo(_segundos), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, fontFamily: 'Monospace', color: Color(0xFF2D3A3A))),
                            const SizedBox(height: 15),
                            ElevatedButton.icon(
                              onPressed: _toggleTimer,
                              icon: Icon(_rodando ? Icons.pause : Icons.play_arrow),
                              label: Text(_rodando ? "PAUSAR" : "INICIAR"),
                              style: ElevatedButton.styleFrom(backgroundColor: _rodando ? Colors.orange : Colors.teal, foregroundColor: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleConclusao,
        backgroundColor: _isConcluido ? Colors.green : Colors.white,
        foregroundColor: _isConcluido ? Colors.white : Colors.grey,
        elevation: 4,
        icon: Icon(_isConcluido ? Icons.check_circle : Icons.circle_outlined),
        label: Text(_isConcluido ? "CONCLUÍDA" : "MARCAR COMO FEITO", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildChip(String label, IconData icon, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: cor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}