import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui'; 
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/rotina_service.dart';
import '../services/bebe_service.dart';
import '../services/sono_global_service.dart';

class TelaRotina extends StatefulWidget {
  const TelaRotina({super.key});

  @override
  State<TelaRotina> createState() => _TelaRotinaState();
}

class _TelaRotinaState extends State<TelaRotina> with TickerProviderStateMixin {
  final _globalService = SonoGlobalService();
  final _mlController = TextEditingController();
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 1), 
      lowerBound: 0.95, 
      upperBound: 1.05
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mlController.dispose();
    super.dispose();
  }

  // --- AÇÕES ---
  void _acaoAmamentar(String lado) {
    if (_globalService.dormindoNotifier.value) {
      _mostrarAviso("O bebê está dormindo! Acorde-o antes.");
      return;
    }
    if (_globalService.amamentandoNotifier.value) {
      if (_globalService.ladoMamadaNotifier.value == lado) {
        _globalService.pararMamada();
        _mostrarSucesso("Mamada finalizada!");
      } else {
        _mostrarAviso("Finalize o outro lado antes de trocar.");
      }
    } else {
      _globalService.iniciarMamada(lado);
    }
  }

  void _acaoDormir() {
    if (_globalService.amamentandoNotifier.value) {
      _mostrarAviso("Pare a mamada antes de iniciar o sono.");
      return;
    }
    if (_globalService.dormindoNotifier.value) {
      _globalService.pararSono(); 
      _mostrarSucesso("Soneca salva!");
    } else {
      _globalService.iniciarSono();
    }
  }

  void _registrarFralda(String tipo) {
    RotinaService.registrarEvento('fralda', {'conteudo': tipo});
    _mostrarSucesso("Fralda ($tipo) registrada!");
  }

  void _registrarMamadeira() {
    if (_mlController.text.isNotEmpty) {
      RotinaService.registrarEvento('mamadeira', {'ml': _mlController.text});
      Navigator.pop(context);
      _mlController.clear();
      _mostrarSucesso("Mamadeira registrada!");
    }
  }

  // --- MODAL TIMER DE SOM (CORRIGIDO) ---
  void _abrirTimerSom() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(20), child: Text("Desligar som em:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          // Usa timer_10 para 15 min (visual aproximado)
          ListTile(leading: const Icon(Icons.timer_10), title: const Text("15 minutos"), onTap: () { _globalService.definirTempoDesligamento(15); Navigator.pop(ctx); _mostrarSucesso("Timer: 15 min"); }),
          // Usa hourglass_bottom para 30 min (timer_30 não existe)
          ListTile(leading: const Icon(Icons.hourglass_bottom), title: const Text("30 minutos"), onTap: () { _globalService.definirTempoDesligamento(30); Navigator.pop(ctx); _mostrarSucesso("Timer: 30 min"); }),
          // Usa hourglass_top para 45 min
          ListTile(leading: const Icon(Icons.hourglass_top), title: const Text("45 minutos"), onTap: () { _globalService.definirTempoDesligamento(45); Navigator.pop(ctx); _mostrarSucesso("Timer: 45 min"); }),
          // Usa timer padrão para 1h
          ListTile(leading: const Icon(Icons.timer), title: const Text("1 hora"), onTap: () { _globalService.definirTempoDesligamento(60); Navigator.pop(ctx); _mostrarSucesso("Timer: 1h"); }),
          // Infinito
          ListTile(leading: const Icon(Icons.all_inclusive), title: const Text("Nunca (Infinito)"), onTap: () { _globalService.definirTempoDesligamento(0); Navigator.pop(ctx); _mostrarSucesso("Som contínuo"); }),
          const SizedBox(height: 20),
        ],
      )
    );
  }

  void _mostrarSucesso(String msg) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }
  
  void _mostrarAviso(String msg) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.orange));
  }

  void _abrirModalMamadeira() {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text("Registrar Mamadeira", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 15),
              TextField(
                controller: _mlController, 
                keyboardType: TextInputType.number, 
                decoration: InputDecoration(labelText: "Quantidade (ml)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), suffixText: "ml", prefixIcon: const Icon(Icons.local_drink)), 
                autofocus: true
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _registrarMamadeira, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("SALVAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _globalService.amamentandoNotifier,
      builder: (context, amamentando, _) {
        return ValueListenableBuilder<String>(
          valueListenable: _globalService.tempoMamadaNotifier,
          builder: (context, tempoMamada, _) {
            return ValueListenableBuilder<String>(
              valueListenable: _globalService.ladoMamadaNotifier,
              builder: (context, ladoMamada, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _globalService.dormindoNotifier,
                  builder: (context, dormindo, _) {
                    return ValueListenableBuilder<String>(
                      valueListenable: _globalService.tempoSonoNotifier,
                      builder: (context, tempoSono, _) {
                        
                        Color corStatus = Colors.teal;
                        String textoStatus = "Tudo calmo";
                        String tempoDisplay = "";
                        IconData iconeStatus = Icons.child_care;

                        if (amamentando) {
                          corStatus = Colors.pink; textoStatus = "Amamentando (${ladoMamada == 'E' ? 'Esq' : 'Dir'})"; tempoDisplay = tempoMamada; iconeStatus = Icons.favorite;
                        } else if (dormindo) {
                          corStatus = Colors.indigo; textoStatus = "Bebê Dormindo"; tempoDisplay = tempoSono; iconeStatus = Icons.nights_stay;
                        }

                        return Scaffold(
                          backgroundColor: const Color(0xFFF2F4F5),
                          body: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- CABEÇALHO SIMPLES ---
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text("Controle de Rotina", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                                ),

                                // --- SEÇÃO 1: AMAMENTAÇÃO (AGORA COM TIMER NOS BOTÕES) ---
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,4))]),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("AMAMENTAÇÃO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                                      const SizedBox(height: 15),
                                      Row(
                                        children: [
                                          Expanded(child: _buildBotaoPeito('E', "Esquerdo", amamentando, ladoMamada, tempoMamada)), 
                                          const SizedBox(width: 15), 
                                          Expanded(child: _buildBotaoPeito('D', "Direito", amamentando, ladoMamada, tempoMamada))
                                        ]
                                      ),
                                      const SizedBox(height: 15),
                                      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _abrirModalMamadeira, icon: const Icon(Icons.baby_changing_station, color: Colors.orange), label: const Text("Registrar Mamadeira", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: const BorderSide(color: Colors.orange), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))))
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // --- SEÇÃO 2: SONO (COM TIMER INTEGRADO) ---
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: dormindo ? const Color(0xFF1A237E) : Colors.white, 
                                    borderRadius: BorderRadius.circular(20), 
                                    boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,4))]
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!dormindo) const Text("SONO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                                      if (!dormindo) const SizedBox(height: 10),
                                      
                                      if (dormindo) ...[
                                        // ESTADO DORMINDO
                                        Center(
                                          child: Column(
                                            children: [
                                              ScaleTransition(scale: _pulseController, child: const Icon(Icons.nights_stay, color: Colors.white, size: 50)),
                                              const SizedBox(height: 10),
                                              const Text("Bebê Dormindo", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                                              Text(tempoSono, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
                                              const SizedBox(height: 20),
                                              SizedBox(
                                                width: double.infinity, 
                                                height: 50, 
                                                child: ElevatedButton.icon(
                                                  onPressed: _acaoDormir, 
                                                  icon: const Icon(Icons.wb_sunny),
                                                  label: const Text("ACORDAR BEBÊ"),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                                                )
                                              )
                                            ],
                                          ),
                                        )
                                      ] else ...[
                                        // ESTADO ACORDADO
                                        Row(
                                          children: [
                                            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.bedtime, color: Colors.indigo, size: 28)), 
                                            const SizedBox(width: 15), 
                                            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Iniciar Soneca", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), Text("Cronometrar sono", style: TextStyle(color: Colors.grey, fontSize: 12))])), 
                                            IconButton(onPressed: _acaoDormir, icon: const Icon(Icons.play_circle_fill, size: 48, color: Colors.indigo))
                                          ]
                                        )
                                      ]
                                    ]
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // --- SEÇÃO 3: RUÍDO BRANCO (NOVO) ---
                                const Padding(padding: EdgeInsets.only(left: 8, bottom: 10), child: Text("RUÍDO BRANCO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1))),
                                ValueListenableBuilder<bool>(
                                   valueListenable: _globalService.tocandoNotifier,
                                   builder: (ctx, tocando, _) {
                                     return ValueListenableBuilder<String?>(
                                       valueListenable: _globalService.somAtivoIdNotifier,
                                       builder: (ctx, somAtivo, _) {
                                         return ValueListenableBuilder<String?>(
                                           valueListenable: _globalService.timerDesligamentoNotifier,
                                           builder: (ctx, tempoRestante, _) {
                                              return Container(
                                                padding: const EdgeInsets.all(15),
                                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                                child: Column(
                                                  children: [
                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                                       _buildBotaoSom("utero", "Útero", "uterus_sound.mp3", somAtivo, tocando),
                                                       _buildBotaoSom("chuva", "Chuva", "rain.mp3", somAtivo, tocando),
                                                       _buildBotaoSom("shhh", "Shhh", "shushing.mp3", somAtivo, tocando),
                                                    ]),
                                                    if (tocando) ...[
                                                      const Divider(height: 25),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          const Text("Desligar em:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                                          if (tempoRestante != null)
                                                             Chip(label: Text(tempoRestante, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.teal, deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white), onDeleted: () => _globalService.definirTempoDesligamento(0))
                                                          else
                                                             TextButton.icon(onPressed: _abrirTimerSom, icon: const Icon(Icons.timer), label: const Text("Definir Tempo"))
                                                        ],
                                                      )
                                                    ]
                                                  ],
                                                ),
                                              );
                                           }
                                         );
                                       }
                                     );
                                   }
                                ),
                                const SizedBox(height: 25),

                                // --- SEÇÃO 4: FRALDAS ---
                                const Padding(padding: EdgeInsets.only(left: 8, bottom: 10), child: Text("TROCA DE FRALDA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1))),
                                Row(children: [Expanded(child: _buildCardFralda("Xixi", Icons.water_drop, Colors.blue, () => _registrarFralda("Xixi"))), const SizedBox(width: 12), Expanded(child: _buildCardFralda("Cocô", Icons.circle, Colors.brown, () => _registrarFralda("Cocô"))), const SizedBox(width: 12), Expanded(child: _buildCardFralda("Ambos", Icons.layers, Colors.purple, () => _registrarFralda("Ambos")))]),

                                const SizedBox(height: 30),
                                const Divider(),
                                const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Últimos Registros", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),

                                // --- HISTÓRICO (MANTIDO) ---
                                StreamBuilder<QuerySnapshot>(
                                  stream: RotinaService.streamHistorico(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return const SizedBox();
                                    final docs = snapshot.data!.docs;
                                    if (docs.isEmpty) return const Text("Nenhum registro hoje.");

                                    return ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      separatorBuilder: (_,__) => const Divider(height: 1),
                                      itemCount: docs.length,
                                      itemBuilder: (ctx, i) {
                                        final d = docs[i].data() as Map<String, dynamic>;
                                        DateTime dt; try { dt = DateTime.parse(d['data']); } catch (e) { dt = DateTime.now(); }
                                        final hora = DateFormat('HH:mm').format(dt);
                                        final dia = DateFormat('dd/MM').format(dt);
                                        String titulo = d['tipo'].toString().toUpperCase();
                                        String detalhe = d['duracao_fmt'] ?? d['conteudo'] ?? "${d['ml']} ml" ?? "";
                                        if (d['tipo'] == 'sono' && detalhe.isEmpty) detalhe = "${(d['duracao_segundos']??0)~/60} min";
                                        Color cor = Colors.grey;
                                        if (d['tipo'] == 'mamada') cor = Colors.pink; if (d['tipo'] == 'sono') cor = Colors.indigo; if (d['tipo'] == 'fralda') cor = Colors.blue; if (d['tipo'] == 'mamadeira') cor = Colors.orange;
                                        return ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: Container(width: 4, height: 40, color: cor), title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), subtitle: Text(detalhe), trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [Text(hora, style: const TextStyle(fontWeight: FontWeight.bold)), Text(dia, style: const TextStyle(fontSize: 10, color: Colors.grey))]));
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  }
                );
              }
            );
          }
        );
      }
    );
  }

  // --- WIDGETS ---
  Widget _buildBotaoPeito(String lado, String label, bool amamentando, String ladoAtivo, String tempo) {
    bool isAtivo = amamentando && ladoAtivo == lado;
    bool isDisabled = amamentando && ladoAtivo != lado;
    return GestureDetector(onTap: isDisabled ? null : () => _acaoAmamentar(lado), child: Opacity(opacity: isDisabled ? 0.4 : 1.0, child: AnimatedContainer(duration: const Duration(milliseconds: 300), height: 100, decoration: BoxDecoration(color: isAtivo ? Colors.pink : Colors.pink.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: isAtivo ? Colors.pink : Colors.pink.shade100), boxShadow: [if (isAtivo) BoxShadow(color: Colors.pink.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]), child: isAtivo ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("AMAMENTANDO", style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)), Text(tempo, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()])), const SizedBox(height: 5), const Icon(Icons.stop_circle, color: Colors.white, size: 30)]) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: TextStyle(fontSize: 14, color: Colors.pink.shade300, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Icon(Icons.play_arrow, color: Colors.pink, size: 28)]))));
  }

  Widget _buildBotaoSom(String id, String label, String arquivo, String? somAtivo, bool tocando) {
    bool isPlaying = (somAtivo == id && tocando);
    return GestureDetector(
      onTap: () => _globalService.toggleSom(id, arquivo, 1.0),
      child: Column(children: [
        AnimatedContainer(duration: const Duration(milliseconds: 300), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: isPlaying ? Colors.teal : Colors.teal.shade50, shape: BoxShape.circle, boxShadow: [if(isPlaying) BoxShadow(color: Colors.teal.withOpacity(0.4), blurRadius: 10)]), child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: isPlaying ? Colors.white : Colors.teal)),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isPlaying ? Colors.teal : Colors.grey))
      ]),
    );
  }

  Widget _buildCardFralda(String label, IconData icon, Color cor, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: cor, size: 24)), const SizedBox(height: 8), Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 12))])));
  }
}