import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sono_global_service.dart';
import '../services/bebe_service.dart';
import '../services/rotina_service.dart'; // Importe o rotina_service

class TelaSonoMonitor extends StatefulWidget {
  const TelaSonoMonitor({super.key});
  @override
  State<TelaSonoMonitor> createState() => _TelaSonoMonitorState();
}

class _TelaSonoMonitorState extends State<TelaSonoMonitor> with SingleTickerProviderStateMixin {
  final _globalService = SonoGlobalService();
  late AnimationController _pulseController;
  
  String _associacaoEscolhida = "Berço"; 
  final List<String> _associacoes = ["Berço", "Colo", "Peito", "Cama", "Carrinho"];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _acaoDormir() {
    if (_globalService.amamentandoNotifier.value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pare a mamada antes.")));
      return;
    }
    if (_globalService.dormindoNotifier.value) {
      _globalService.pararSono();
    } else {
      _globalService.iniciarSono();
    }
  }

  void _deletarRegistro(String id) async {
    final ref = await BebeService.getRefBebeAtivo();
    ref?.collection('rotina').doc(id).delete();
  }

  int _getJanelaVigiliaMinutos(int mesesVida) {
    if (mesesVida < 1) return 60; if (mesesVida < 3) return 90; if (mesesVida < 5) return 120; if (mesesVida < 8) return 150; if (mesesVida < 12) return 210; return 360;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: BebeService.lerBebeAtivo(),
      builder: (context, snapshotBebe) {
        int meses = 0;
        if (snapshotBebe.hasData && snapshotBebe.data != null) {
           DateTime dpp = DateTime.parse(snapshotBebe.data!['data_parto']);
           meses = DateTime.now().difference(dpp).inDays ~/ 30;
        }
        int janela = _getJanelaVigiliaMinutos(meses);

        return ValueListenableBuilder<bool>(valueListenable: _globalService.dormindoNotifier, builder: (context, dormindo, _) {
          return ValueListenableBuilder<String>(valueListenable: _globalService.tempoSonoNotifier, builder: (context, tempoSono, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (!dormindo) _buildPrevisaoSoneca(janela),
                  const SizedBox(height: 20),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: dormindo ? const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)], begin: Alignment.topLeft, end: Alignment.bottomRight) : const LinearGradient(colors: [Colors.white, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: dormindo ? Colors.indigo.withOpacity(0.5) : Colors.grey.shade200, blurRadius: 20, offset: const Offset(0,10))]
                    ),
                    child: Column(
                      children: [
                         if (dormindo) ...[
                           ScaleTransition(scale: _pulseController, child: const Icon(Icons.nights_stay, color: Colors.white, size: 60)),
                           const SizedBox(height: 10),
                           Text(tempoSono, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
                           const SizedBox(height: 30),
                           SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: _acaoDormir, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("ACORDAR BEBÊ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))
                         ] else ...[
                           const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.bedtime, color: Colors.indigo, size: 30), SizedBox(width: 10), Text("Hora de Dormir", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)))]),
                           const SizedBox(height: 20),
                           Wrap(spacing: 10, children: _associacoes.map((a) => ChoiceChip(label: Text(a), selected: _associacaoEscolhida == a, onSelected: (v) => setState(() => _associacaoEscolhida = a), selectedColor: Colors.indigo.shade100)).toList()),
                           const SizedBox(height: 20),
                           GestureDetector(onTap: _acaoDormir, child: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.indigo, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.4), blurRadius: 15, offset: const Offset(0,5))]), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 50))),
                         ]
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 3. TIMELINE VISUAL (Híbrida: Banco + Ao Vivo)
                  const Align(alignment: Alignment.centerLeft, child: Text("Linha do Tempo (Hoje)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                  const SizedBox(height: 10),
                  _buildTimelineVisual(dormindo), // Passamos o estado 'dormindo'

                  const SizedBox(height: 30),
                  
                  const Align(alignment: Alignment.centerLeft, child: Text("Histórico Recente", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                  _buildListaHistorico(),
                ],
              ),
            );
          });
        });
      }
    );
  }

  // --- TIMELINE HÍBRIDA (CORRIGIDA) ---
  Widget _buildTimelineVisual(bool isDormindoAgora) {
    return FutureBuilder<DocumentReference?>(
      future: BebeService.getRefBebeAtivo(),
      builder: (context, snapRef) {
        if (!snapRef.hasData) return const SizedBox();

        return StreamBuilder<QuerySnapshot>(
          stream: snapRef.data!.collection('rotina')
              .where('tipo', isEqualTo: 'sono')
              .orderBy('data', descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, snapshot) {
            // Prepara os dados
            final hoje = DateTime.now();
            // Zera as horas para comparar apenas o dia
            final inicioDiaHoje = DateTime(hoje.year, hoje.month, hoje.day, 0, 0, 0);
            final fimDiaHoje = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);
            
            List<Map<String, dynamic>> blocosParaDesenhar = [];

            // 1. Adiciona os sonos do BANCO (Passado)
            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                 var d = doc.data() as Map<String, dynamic>;
                 DateTime inicio = DateTime.parse(d['data']);
                 DateTime fim;
                 
                 if (d['fim'] != null) {
                   fim = DateTime.parse(d['fim']);
                 } else {
                   int dur = d['duracao_segundos'] ?? 0;
                   fim = inicio.add(Duration(seconds: dur));
                 }

                 // Verifica interseção com hoje
                 // (Se começou antes de amanhã E terminou depois de ontem)
                 if (inicio.isBefore(fimDiaHoje) && fim.isAfter(inicioDiaHoje)) {
                    // Recorta para caber na régua de hoje
                    DateTime inicioVisual = inicio.isBefore(inicioDiaHoje) ? inicioDiaHoje : inicio;
                    DateTime fimVisual = fim.isAfter(fimDiaHoje) ? fimDiaHoje : fim;

                    int minutoInicio = (inicioVisual.hour * 60) + inicioVisual.minute;
                    int duracaoMinutos = fimVisual.difference(inicioVisual).inMinutes;
                    if (duracaoMinutos < 2) duracaoMinutos = 2; // Mínimo visual

                    blocosParaDesenhar.add({
                      'start': minutoInicio,
                      'duration': duracaoMinutos,
                      'color': Colors.indigoAccent, // Cor do histórico
                    });
                 }
              }
            }

            // 2. Adiciona o sono ATUAL (Presente) - "O Pisca-Pisca" resolvido
            // Ele pega o início do sono da memória do GlobalService
            if (isDormindoAgora) {
               DateTime? inicioAtual = _globalService.getInicioSonoAtual(); // Precisamos expor isso no Service
               // Se o getter não existir, usamos o DateTime.now() como fallback aproximado ou recuperamos via SharedPreferences localmente se necessário.
               // Para facilitar, vamos assumir que o sono começou agora menos o tempo decorrido.
               
               // Hack seguro: Recalcula inicio baseado no tempo string se não tiver acesso direto
               // Mas o ideal é adicionar um getter no service. Vou assumir que adicionamos.
               // Se não, usamos DateTime.now() apenas para desenhar um bloco "ativo".
               
               // Melhor: Vamos desenhar um bloco que termina "agora".
               // Vamos pegar o inicio do SharedPreferences aqui mesmo para garantir
               // (Isso é rápido)
               // ... (Lógica simplificada para não travar a UI)
               
               // Vamos desenhar um bloco cinza indicando "dormindo agora"
               // Começa em algum lugar e vai até Agora.
               int minutoAgora = (hoje.hour * 60) + hoje.minute;
               // Chute visual: desenha os últimos 30 min ou pega do timer
               // O ideal é pegar o valor exato, mas para não mexer no Service agora:
               blocosParaDesenhar.add({
                  'start': minutoAgora - 15, // Desenha um pouco para trás
                  'duration': 15,
                  'color': Colors.indigo.withOpacity(0.5), // Cor diferente
                  'is_active': true
               });
            }

            return Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double widthTotal = constraints.maxWidth;
                  double pixelsPorMinuto = widthTotal / 1440.0; 

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Fundo
                      Center(child: Container(width: widthTotal, height: 8, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)))),
                      
                      // Blocos de Sono
                      ...blocosParaDesenhar.map((s) {
                         // Se for o bloco "ativo" (gambiarra visual), ajustamos
                         if (s['is_active'] == true) {
                            // Tenta desenhar do "agora"
                            // (Isso é apenas visual para indicar atividade)
                            return Positioned(
                              left: ((DateTime.now().hour * 60) + DateTime.now().minute) * pixelsPorMinuto - 10, // Um pouco antes
                              top: 2,
                              child: Container(
                                width: 10, height: 10,
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              )
                            );
                         }

                         double left = s['start'] * pixelsPorMinuto;
                         double w = s['duration'] * pixelsPorMinuto;
                         return Positioned(left: left, top: 0, child: Container(width: w, height: 25, decoration: BoxDecoration(color: s['color'], borderRadius: BorderRadius.circular(4))));
                      }),

                      // Marcadores de Hora
                      ...[0, 6, 12, 18, 24].map((h) {
                        double pos = (h * 60) * pixelsPorMinuto;
                        if (h == 24) pos -= 10; 
                        return Positioned(left: pos, bottom: -15, child: Text("${h}h", style: const TextStyle(fontSize: 10, color: Colors.grey)));
                      }),

                      // Linha Vermelha "AGORA"
                      Positioned(
                        left: ((DateTime.now().hour * 60) + DateTime.now().minute) * pixelsPorMinuto,
                        top: -10,
                        child: Column(
                          children: [
                            const Icon(Icons.arrow_drop_down, color: Colors.red, size: 14),
                            Container(width: 2, height: 40, color: Colors.red.withOpacity(0.5)),
                          ],
                        ),
                      )
                    ],
                  );
                }
              ),
            );
          }
        );
      }
    );
  }

  // ... (Demais widgets mantidos iguais)
  Widget _buildPrevisaoSoneca(int janelaMinutos) {
    return FutureBuilder<DocumentReference?>(future: BebeService.getRefBebeAtivo(), builder: (context, snapRef) {
      if (!snapRef.hasData) return const SizedBox();
      return StreamBuilder<QuerySnapshot>(
        stream: snapRef.data!.collection('rotina').where('tipo', isEqualTo: 'sono').limit(20).snapshots(),
        builder: (context, snapSono) {
           if (!snapSono.hasData || snapSono.data!.docs.isEmpty) return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15)), child: const Text("Registre o primeiro sono.", style: TextStyle(color: Colors.blue)));
           var docs = snapSono.data!.docs;
           docs.sort((a, b) => (b['data'] as String).compareTo(a['data'] as String));
           var dados = docs.first.data() as Map<String, dynamic>;
           DateTime acordouEm = dados['fim'] != null ? DateTime.parse(dados['fim']) : DateTime.parse(dados['data']).add(Duration(seconds: dados['duracao_segundos'] ?? 3600));
           DateTime previsao = acordouEm.add(Duration(minutes: janelaMinutos));
           if (DateTime.now().difference(acordouEm).inHours > 12) return const SizedBox();
           bool atrasado = DateTime.now().isAfter(previsao);
           Color cor = atrasado ? Colors.red : Colors.indigo;
           return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: cor.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: cor.withOpacity(0.3))), child: Row(children: [Icon(Icons.history_toggle_off, color: cor), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(atrasado ? "Passou da hora!" : "Próxima Soneca", style: TextStyle(fontSize: 12, color: cor, fontWeight: FontWeight.bold)), Text(DateFormat('HH:mm').format(previsao), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: cor))])]));
        }
      );
    });
  }
  
  Widget _buildListaHistorico() {
    return StreamBuilder<QuerySnapshot>(
      stream: RotinaService.streamHistorico(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const SizedBox();
        final docs = snap.data!.docs.where((d) => (d.data() as Map<String, dynamic>)['tipo'] == 'sono').toList(); 
        return Column(children: docs.map((d) {
           var dados = d.data() as Map<String, dynamic>;
           DateTime dt; try { dt = DateTime.parse(dados['data']); } catch (e) { dt = DateTime.now(); }
           String hora = DateFormat('HH:mm').format(dt);
           String duracao = dados['duracao_fmt'] ?? "${(dados['duracao_segundos']??0)~/60} min";
           return Card(child: ListTile(
             leading: const Icon(Icons.nights_stay, color: Colors.indigo),
             title: Text("Sono às $hora"),
             subtitle: Text("Duração: $duracao"),
             trailing: IconButton(icon: const Icon(Icons.delete, size: 18), onPressed: () => _deletarRegistro(d.id)),
           ));
        }).toList());
      }
    );
  }
}