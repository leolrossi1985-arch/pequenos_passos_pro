import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/rotina_service.dart';
import '../services/bebe_service.dart';
import '../services/sono_global_service.dart';
import '../widgets/card_proxima_soneca.dart';
import '../utils/calculadora_sono.dart';

class TelaRotinaGeral extends StatefulWidget {
  const TelaRotinaGeral({super.key});

  @override
  State<TelaRotinaGeral> createState() => _TelaRotinaGeralState();
}

class _TelaRotinaGeralState extends State<TelaRotinaGeral> with TickerProviderStateMixin {
  final _globalService = SonoGlobalService();
  final _mlController = TextEditingController();
  late AnimationController _pulseController;
  DateTime _dataSelecionada = DateTime.now();
  
  // Variável para segurar a conexão com o banco e evitar recriação
  Stream<QuerySnapshot>? _fluxoRotina; 
  
  // Variáveis para modais manuais
  DateTime _inicioManual = DateTime.now().subtract(const Duration(hours: 1));
  DateTime _fimManual = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 2), 
      lowerBound: 0.95, 
      upperBound: 1.05
    )..repeat(reverse: true);

    // INICIALIZA O STREAM AQUI (Apenas uma vez)
    _iniciarListenerBanco();
  }

  void _iniciarListenerBanco() {
    setState(() {
      _fluxoRotina = RotinaService.streamHistorico().asBroadcastStream();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mlController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE NEGÓCIO ---
  void _mudarDia(int dias) { 
    setState(() => _dataSelecionada = _dataSelecionada.add(Duration(days: dias))); 
  }
  
  bool get _isHoje { 
    final h = DateTime.now(); 
    return _dataSelecionada.year == h.year && _dataSelecionada.month == h.month && _dataSelecionada.day == h.day; 
  }


  // --- MÉTODOS DE FEEDBACK ---
  void _mostrarSucesso(String msg) { 
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg), 
          backgroundColor: Colors.green, 
          behavior: SnackBarBehavior.floating, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        )
      ); 
    }
  }
  
  void _mostrarAviso(String msg) { 
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg), 
          backgroundColor: Colors.orange, 
          behavior: SnackBarBehavior.floating, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        )
      ); 
    }
  }

  // --- AÇÕES DO USUÁRIO ---

  // 1. MAMADA
  void _acaoAmamentar(String lado) async {
    if (_globalService.dormindoNotifier.value) { 
      _mostrarAviso("O bebê está dormindo! Acorde-o antes."); 
      return; 
    }
    
    if (_globalService.amamentandoNotifier.value) {
      if (_globalService.ladoMamadaNotifier.value == lado) { 
        
        String tempoDecorrido = _globalService.tempoMamadaNotifier.value;
        _globalService.pararMamada(); 
        
        // Salva direto, sem travas excessivas, pois o stream agora é estável
        await RotinaService.registrarEvento('mamada', {
          'lado': lado,
          'duracao_fmt': tempoDecorrido,
          'data': DateTime.now().toIso8601String()
        });
        
        _mostrarSucesso("Mamada finalizada!"); 
      } else { 
        _mostrarAviso("Finalize o lado atual antes de trocar!"); 
      }
    } else { 
      _globalService.iniciarMamada(lado); 
    }
  }

  // 2. SONO
  void _acaoDormir() async {
    if (_globalService.amamentandoNotifier.value) { 
      _mostrarAviso("Pare a mamada antes de iniciar o sono."); 
      return; 
    }
    
    if (_globalService.dormindoNotifier.value) { 
      String tempoDecorrido = _globalService.tempoSonoNotifier.value;
      _globalService.pararSono(); 
      
      await RotinaService.registrarEvento('sono', {
        'duracao_fmt': tempoDecorrido,
        'data': DateTime.now().toIso8601String()
      });
      
      _mostrarSucesso("Soneca salva!"); 
    } else { 
      _globalService.iniciarSono(); 
    }
  }

  // 3. FRALDA
  void _registrarFralda(String tipo) async { 
    await RotinaService.registrarEvento('fralda', {
      'conteudo': tipo, 
      'data': _dataSelecionada.toIso8601String()
    }); 
    
    _mostrarSucesso("Fralda registrada!"); 
  }

  // 4. BANHO
  void _registrarBanho() async {
    await RotinaService.registrarEvento('banho', {
      'conteudo': 'Banho Tomado',
      'data': _dataSelecionada.toIso8601String()
    });
    
    _mostrarSucesso("Banho relaxante registrado! 🛁");
  }
  
  // 5. MAMADEIRA
  void _registrarMamadeira() async { 
    if (_mlController.text.isNotEmpty) { 
      await RotinaService.registrarEvento('mamadeira', {
        'ml': _mlController.text,
        'data': _dataSelecionada.toIso8601String()
      }); 
      
      Navigator.pop(context); 
      _mlController.clear(); 
      _mostrarSucesso("Mamadeira registrada!"); 
    } 
  }
  
  // 6. DELETAR
  void _deletarRegistro(String id, Map<String, dynamic> dados) async { 
    String tipo = dados['tipo'] ?? '';

    await RotinaService.removerEvento(id, tipo, dados);

    _mostrarSucesso("Registro removido."); 
  }

  // --- MODAIS ---
  
  void _editarRegistro(String id, Map<String, dynamic> dados) {
    if (dados['tipo'] != 'sono' && dados['tipo'] != 'mamada') return;
    
    final minutosCtrl = TextEditingController(text: "${(dados['duracao_segundos'] ?? 0) ~/ 60}");
    String? ladoAtual = dados['lado']; 
    DateTime dataInicioEdit = DateTime.parse(dados['data']);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Editar ${dados['tipo'] == 'sono' ? 'Soneca' : 'Mamada'}", style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time, color: Colors.teal),
                  title: const Text("Horário de Início"),
                  trailing: TextButton(
                    onPressed: () async {
                      final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dataInicioEdit));
                      if (t != null) setStateDialog(() => dataInicioEdit = DateTime(dataInicioEdit.year, dataInicioEdit.month, dataInicioEdit.day, t.hour, t.minute));
                    },
                    child: Text(DateFormat('HH:mm').format(dataInicioEdit), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ),
                ),
                TextField(controller: minutosCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Duração (minutos)", suffixText: "min", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                if (dados['tipo'] == 'mamada') ...[
                  const SizedBox(height: 15),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ChoiceChip(label: const Text("Esq"), selected: ladoAtual == 'E', selectedColor: Colors.pink.shade100, onSelected: (s) => setStateDialog(() => ladoAtual = 'E')),
                      const SizedBox(width: 10),
                      ChoiceChip(label: const Text("Dir"), selected: ladoAtual == 'D', selectedColor: Colors.pink.shade100, onSelected: (s) => setStateDialog(() => ladoAtual = 'D')),
                  ])
                ]
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () async {
                  final ref = await BebeService.getRefBebeAtivo();
                  if (ref != null) {
                    int novosMinutos = int.tryParse(minutosCtrl.text) ?? 0;
                    DateTime novoFim = dataInicioEdit.add(Duration(minutes: novosMinutos));
                    Map<String, dynamic> updateData = {'duracao_segundos': novosMinutos * 60, 'duracao_fmt': "$novosMinutos min", 'data': dataInicioEdit.toIso8601String(), 'fim': novoFim.toIso8601String()};
                    if (dados['tipo'] == 'mamada' && ladoAtual != null) updateData['lado'] = ladoAtual;
                    await ref.collection('rotina').doc(id).update(updateData);
                    if (mounted) { Navigator.pop(ctx); _mostrarSucesso("Atualizado!"); }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text("SALVAR", style: TextStyle(color: Colors.white))
              ),
            ],
          );
        }
      ),
    );
  }

  void _abrirRegistroSonoManual() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent, 
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) { 
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom), 
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))), 
              padding: const EdgeInsets.all(20), 
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  const Text("Registrar Sono Passado", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)), 
                  const SizedBox(height: 20), 
                  Row(
                    children: [
                      Expanded(child: Column(children: [const Text("Dormiu às:"), TextButton(onPressed: () async { final d = await showDatePicker(context: context, initialDate: _inicioManual, firstDate: DateTime.now().subtract(const Duration(days: 2)), lastDate: DateTime.now()); if(d!=null) { final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_inicioManual)); if(t!=null) setStateModal(()=> _inicioManual = DateTime(d.year, d.month, d.day, t.hour, t.minute)); } }, child: Text(DateFormat('HH:mm').format(_inicioManual), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)))] )), 
                      const Icon(Icons.arrow_forward, color: Colors.grey), 
                      Expanded(child: Column(children: [const Text("Acordou às:"), TextButton(onPressed: () async { final d = await showDatePicker(context: context, initialDate: _fimManual, firstDate: DateTime.now().subtract(const Duration(days: 2)), lastDate: DateTime.now()); if(d!=null) { final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_fimManual)); if(t!=null) setStateModal(()=> _fimManual = DateTime(d.year, d.month, d.day, t.hour, t.minute)); } }, child: Text(DateFormat('HH:mm').format(_fimManual), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)))] ))
                    ]
                  ), 
                  const SizedBox(height: 30), 
                  SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () async { 
                    if (_fimManual.isBefore(_inicioManual)) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hora fim deve ser maior que início"))); return; } 
                    int duracao = _fimManual.difference(_inicioManual).inSeconds; 
                    int min = duracao ~/ 60; 
                    
                    await RotinaService.registrarEvento('sono', {
                          'duracao_segundos': duracao, 
                          'duracao_fmt': "$min min", 
                          'data': _inicioManual.toIso8601String(), 
                          'fim': _fimManual.toIso8601String(), 
                          'manual': true 
                    });
                    
                    if (mounted) Navigator.pop(context); 
                  }, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("SALVAR REGISTRO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))))
                ]
              )
            )
          ); 
        }
      )
    ); 
  }

  void _abrirModalMamadeira() { 
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom), child: Container(decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))), padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text("Registrar Mamadeira", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)), const SizedBox(height: 20), TextField(controller: _mlController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Quantidade (ml)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)), suffixText: "ml", prefixIcon: const Icon(Icons.local_drink, color: Colors.orange)), autofocus: true), const SizedBox(height: 25), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _registrarMamadeira, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0), child: const Text("SALVAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))))])))); 
  }

  // --- BUILD METHOD E WIDGETS ---
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: BebeService.lerBebeAtivo(), 
      builder: (context, snapshotBebe) {
        int mesesVida = 0;
        if (snapshotBebe.hasData && snapshotBebe.data != null) {
           dynamic dataParto = snapshotBebe.data!['data_parto'];
           DateTime dpp = (dataParto is Timestamp) ? dataParto.toDate() : DateTime.parse(dataParto);
           mesesVida = DateTime.now().difference(dpp).inDays ~/ 30;
        }
        int janelaMinutos = CalculadoraSono.getJanelaVigiliaMinutos(mesesVida);

        return ValueListenableBuilder<bool>(valueListenable: _globalService.amamentandoNotifier, builder: (context, amamentando, _) {
          return ValueListenableBuilder<String>(valueListenable: _globalService.tempoMamadaNotifier, builder: (context, tempoMamada, _) {
            return ValueListenableBuilder<String>(valueListenable: _globalService.ladoMamadaNotifier, builder: (context, ladoMamada, _) {
              return ValueListenableBuilder<bool>(valueListenable: _globalService.dormindoNotifier, builder: (context, dormindo, _) {
                return ValueListenableBuilder<String>(valueListenable: _globalService.tempoSonoNotifier, builder: (context, tempoSono, _) {
                  
                  // ESTADOS VISUAIS
                  Color corTema = Colors.teal;
                  String statusText = "Rotina do Bebê";
                  String subStatusText = "Acompanhe o dia a dia";
                  IconData statusIcon = Icons.wb_sunny_rounded;
                  String timerDisplay = "";
                  bool isActive = false;

                  if (amamentando) { 
                    corTema = const Color(0xFFEC407A); 
                    statusText = "Amamentando"; 
                    subStatusText = ladoMamada == 'E' ? "Peito Esquerdo" : "Peito Direito";
                    statusIcon = Icons.favorite_rounded; 
                    timerDisplay = tempoMamada; 
                    isActive = true;
                  } else if (dormindo) { 
                    corTema = const Color(0xFF3949AB); 
                    statusText = "Dormindo"; 
                    subStatusText = "Shhh... sono tranquilo";
                    statusIcon = Icons.bedtime_rounded; 
                    timerDisplay = tempoSono; 
                    isActive = true;
                  }

                  return Scaffold(
                    backgroundColor: const Color(0xFFF9FAFB),
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: _buildSeletorData(),
                      automaticallyImplyLeading: false,
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 160),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          
                          // --- 1. CARD PRINCIPAL ---
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              width: MediaQuery.of(context).size.width * 0.9,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: isActive 
                                  ? LinearGradient(colors: [corTema, corTema.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight) 
                                  : const LinearGradient(colors: [Colors.white, Colors.white]),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: isActive ? corTema.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.05),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10)
                                  )
                                ]
                              ),
                              child: Column(
                                children: [
                                  if (!isActive) ...[
                                    const Text("Tudo calmo por aqui...", style: TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 10),
                                  ],
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isActive)
                                        ScaleTransition(scale: _pulseController, child: Icon(statusIcon, color: Colors.white.withValues(alpha: 0.8), size: 24)),
                                      const SizedBox(width: 10),
                                      Text(statusText.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: isActive ? Colors.white70 : Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  isActive 
                                    ? Text(timerDisplay, style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Colors.white, height: 1))
                                    : Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Text(subStatusText, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
                                    ),
                                  
                                  if (isActive) ...[
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: 160, height: 50,
                                      child: ElevatedButton(
                                        onPressed: amamentando ? () => _acaoAmamentar(ladoMamada) : _acaoDormir,
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: corTema, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                                        child: const Text("FINALIZAR", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      ),
                                    )
                                  ] else ...[
                                    _buildTimelineNavegavel(janelaMinutos, dormindo),
                                    const SizedBox(height: 15),
                                    _buildLegendaTimeline()
                                  ]
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- 1.5 SMART WIDGET (CONSULTOR DE SONO) ---
                          if (_fluxoRotina != null)
                             StreamBuilder<QuerySnapshot>(
                               stream: _fluxoRotina,
                               builder: (context, snapshot) {
                                 DateTime? ultimoAcordar;
                                 if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                   for (var doc in snapshot.data!.docs) {
                                     final data = doc.data() as Map<String, dynamic>;
                                     if (data['tipo'] == 'sono') {
                                       if (data['fim'] != null) {
                                         try {
                                           final fim = DateTime.parse(data['fim']);
                                           if (DateTime.now().difference(fim).inHours < 24) {
                                             ultimoAcordar = fim;
                                             break;
                                           }
                                         } catch (_) {}
                                       } else if (data['data'] != null && data['duracao_segundos'] != null) {
                                           try {
                                             final inicio = DateTime.parse(data['data']);
                                             final duracao = data['duracao_segundos'] as int;
                                             final fim = inicio.add(Duration(seconds: duracao));
                                             if (DateTime.now().difference(fim).inHours < 24) {
                                                ultimoAcordar = fim;
                                                break;
                                             }
                                           } catch (_) {}
                                       }
                                     }
                                   }
                                 }
                                 return CardProximaSoneca(
                                   ultimoAcordar: ultimoAcordar,
                                   janelaVigiliaMinutos: janelaMinutos,
                                   isDormindo: dormindo,
                                 );
                               }
                             ),

                          const SizedBox(height: 30),

                          // --- 2. ALIMENTAÇÃO ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Alimentação", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(child: _buildBotaoPeito('E', "Esq", amamentando, ladoMamada)), 
                                    const SizedBox(width: 15), 
                                    Expanded(child: _buildBotaoPeito('D', "Dir", amamentando, ladoMamada))
                                  ],
                                ),
                                const SizedBox(height: 15),
                                _buildBotaoLargo("Mamadeira", Icons.local_drink_rounded, Colors.orange, _abrirModalMamadeira),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- 3. SONO ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Sono", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                                    if(!dormindo) GestureDetector(onTap: _abrirRegistroSonoManual, child: Text("Registro Manual", style: TextStyle(fontSize: 12, color: Colors.indigo.shade300, fontWeight: FontWeight.bold)))
                                  ],
                                ),
                                const SizedBox(height: 15),
                                if (!dormindo)
                                  _buildBotaoLargo("Iniciar Soneca", Icons.nights_stay_rounded, Colors.indigo, _acaoDormir, isPrimary: true),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- 4. HIGIENE ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Higiene", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                                    GestureDetector(
                                      onTap: _registrarBanho,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: Colors.cyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.cyan.withValues(alpha: 0.3))),
                                        child: const Row(children: [Icon(Icons.bathtub_outlined, size: 16, color: Colors.cyan), SizedBox(width: 5), Text("Banho", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyan))]),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  children: [
                                    Expanded(child: _buildBotaoFralda("Xixi", Icons.water_drop_rounded, Colors.blue, () => _registrarFralda("Xixi"))), 
                                    const SizedBox(width: 12), 
                                    Expanded(child: _buildBotaoFralda("Cocô", Icons.circle, Colors.brown, () => _registrarFralda("Cocô"))), 
                                    const SizedBox(width: 12), 
                                    Expanded(child: _buildBotaoFralda("Ambos", Icons.all_inclusive_rounded, Colors.purple, () => _registrarFralda("Ambos")))
                                  ]
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),
                          
                          // --- 5. HISTÓRICO ---
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.history, color: Colors.grey),
                                      const SizedBox(width: 10),
                                      Text("Linha do Tempo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey.shade700)),
                                    ],
                                  ),
                                ),
                                _buildHistoricoDoDia(),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
              });
            });
          });
        });
      }
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildSeletorData() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () => _mudarDia(-1), icon: const Icon(Icons.chevron_left_rounded, size: 22, color: Colors.black87), padding: EdgeInsets.zero, constraints: const BoxConstraints()), const SizedBox(width: 15), Text(_isHoje ? "Hoje" : DateFormat("d MMM", "pt_BR").format(_dataSelecionada), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(width: 15), IconButton(onPressed: _isHoje ? null : () => _mudarDia(1), icon: Icon(Icons.chevron_right_rounded, size: 22, color: _isHoje ? Colors.grey.shade200 : Colors.black87), padding: EdgeInsets.zero, constraints: const BoxConstraints())]),
    );
  }

  Widget _buildLegendaTimeline() {
    return Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 5, children: [_itemLegenda(const Color(0xFF3949AB), "Sono", isBox: true), _itemLegenda(Colors.purple.withValues(alpha: 0.3), "Previsão", isBox: true, hasBorder: true), _itemLegenda(Colors.pink, "Mamada"), _itemLegenda(Colors.orange, "Mamadeira"), _itemLegenda(Colors.teal, "Fralda")]);
  }

  Widget _itemLegenda(Color cor, String texto, {bool isBox = false, bool hasBorder = false}) {
    return Row(mainAxisSize: MainAxisSize.min, children: [if (isBox) Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(3), border: hasBorder ? Border.all(color: Colors.purple.withValues(alpha: 0.6)) : null)) else Icon(Icons.circle, size: 8, color: cor), const SizedBox(width: 4), Text(texto, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))]);
  }

  Widget _buildTimelineNavegavel(int janelaMinutos, bool isDormindoAgora) {
    return FutureBuilder<DocumentReference?>(future: BebeService.getRefBebeAtivo(), builder: (context, snapRef) {
      if (!snapRef.hasData) return const SizedBox(height: 70);
      return StreamBuilder<QuerySnapshot>(stream: snapRef.data!.collection('rotina').orderBy('data', descending: true).limit(100).snapshots(), builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 70);
        final inicioDia = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day, 0, 0, 0);
        final fimDia = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day, 23, 59, 59);
        List<Widget> elementos = [];
        elementos.add(Container(width: double.infinity, height: 4, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(2))));
        double getPos(DateTime dt) { int minutos = (dt.hour * 60) + dt.minute; return minutos / 1440.0; }
        DateTime? ultimoAcordarHoje;
        for (var doc in snapshot.data!.docs) {
          var d = doc.data() as Map<String, dynamic>;
          if (d['data'] == null) continue;
          DateTime inicio; try { inicio = DateTime.parse(d['data']); } catch(e) { continue; }
          String tipo = d['tipo'];
          if (inicio.isBefore(fimDia.add(const Duration(hours: 12))) && (d['fim'] != null ? DateTime.parse(d['fim']).isAfter(inicioDia.subtract(const Duration(hours: 12))) : inicio.isAfter(inicioDia.subtract(const Duration(hours: 12))))) {
            if (tipo == 'sono') {
                DateTime fim;
                if (d['fim'] != null) { fim = DateTime.parse(d['fim']); } else { int dur = d['duracao_segundos'] ?? 0; fim = inicio.add(Duration(seconds: dur)); }
                if (_isHoje && fim.isBefore(DateTime.now()) && (ultimoAcordarHoje == null || fim.isAfter(ultimoAcordarHoje))) { ultimoAcordarHoje = fim; }
                if (inicio.isBefore(fimDia) && fim.isAfter(inicioDia)) {
                    DateTime iv = inicio.isBefore(inicioDia) ? inicioDia : inicio;
                    DateTime fv = fim.isAfter(fimDia) ? fimDia : fim;
                    double ps = getPos(iv);
                    double pe = getPos(fv);
                    double w = pe - ps;
                    if (w < 0.005) w = 0.005;
                    elementos.add(Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: ps + w, child: Container(alignment: Alignment.centerRight, child: FractionallySizedBox(widthFactor: w / (ps + w), child: Container(height: 24, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)]), borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: const Color(0xFF3949AB).withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))])))))));
                }
            } else if (inicio.isAfter(inicioDia) && inicio.isBefore(fimDia)) {
                double pos = getPos(inicio);
                Color corIcon = Colors.grey; IconData iconData = Icons.circle; double yAlign = 0.0;
                if (tipo == 'mamada') { corIcon = Colors.pink; iconData = Icons.favorite; yAlign = -0.7; } else if (tipo == 'fralda') { iconData = Icons.water_drop; corIcon = Colors.teal; yAlign = 0.7; } else if (tipo == 'mamadeira') { corIcon = Colors.orange; iconData = Icons.local_drink; yAlign = -0.7; } else if (tipo == 'banho') { corIcon = Colors.cyan; iconData = Icons.bathtub; yAlign = 0.7; } 
                else if (tipo == 'nutricao') { corIcon = Colors.lightGreen; iconData = Icons.restaurant_menu; yAlign = -0.7; }
                elementos.add(Align(alignment: Alignment((pos * 2) - 1, yAlign), child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)]), child: Icon(iconData, size: 10, color: corIcon))));
            }
          }
        }
        if (_isHoje && !isDormindoAgora && ultimoAcordarHoje != null) {
           DateTime inicioPrev = ultimoAcordarHoje.add(Duration(minutes: janelaMinutos));
           DateTime fimPrev = inicioPrev.add(const Duration(minutes: 90)); 
           if (inicioPrev.isBefore(fimDia)) {
             double ps = getPos(inicioPrev);
             double pe = fimPrev.day != inicioPrev.day ? 1.0 : getPos(fimPrev);
             double w = pe - ps;
             if (w > 0) { elementos.add(Align(alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: ps + w, child: Container(alignment: Alignment.centerRight, child: FractionallySizedBox(widthFactor: w / (ps + w), child: Container(height: 24, decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.purple.withValues(alpha: 0.3), width: 1, style: BorderStyle.solid)))))))); }
           }
        }
        if (_isHoje) { double posAgora = getPos(DateTime.now()); elementos.add(Align(alignment: Alignment((posAgora * 2) - 1, 0), child: Container(width: 2, height: 40, color: Colors.redAccent.withValues(alpha: 0.6)))); }
        return Container(height: 70, width: double.infinity, margin: const EdgeInsets.symmetric(vertical: 5), child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [...List.generate(25, (h) { double pos = (h * 60) / 1440.0; bool showLabel = h % 2 == 0; return Positioned(left: pos * (MediaQuery.of(context).size.width - 96) + 10, bottom: -15, child: Column(children: [Container(height: showLabel ? 8 : 4, width: 1, color: Colors.grey.withValues(alpha: 0.3)), if (showLabel) Text("$h", style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold))])); }), ...elementos]));
      });
    });
  }

  Widget _buildBotaoPeito(String lado, String label, bool amamentando, String ladoAtivo) {
    bool isAtivo = amamentando && ladoAtivo == lado;
    return GestureDetector(
      onTap: () => _acaoAmamentar(lado), 
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), 
        height: 100, 
        decoration: BoxDecoration(
          color: isAtivo ? const Color(0xFFEC407A) : Colors.white, 
          borderRadius: BorderRadius.circular(24), 
          boxShadow: [
            BoxShadow(color: isAtivo ? const Color(0xFFEC407A).withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))
          ], 
          border: Border.all(color: isAtivo ? Colors.transparent : Colors.pink.shade50)
        ), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(isAtivo ? Icons.pause_circle_filled : Icons.play_circle_fill_rounded, color: isAtivo ? Colors.white : Colors.pink.shade200, size: 32), 
            const SizedBox(height: 8), 
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isAtivo ? Colors.white : Colors.grey.shade700))
          ]
        )
      )
    );
  }

  Widget _buildBotaoLargo(String label, IconData icon, Color cor, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        height: 70, 
        width: double.infinity, 
        decoration: BoxDecoration(color: isPrimary ? cor : Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: cor.withValues(alpha: isPrimary ? 0.3 : 0.05), blurRadius: 15, offset: const Offset(0, 5))], border: isPrimary ? null : Border.all(color: cor.withValues(alpha: 0.2))), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
             Icon(icon, color: isPrimary ? Colors.white : cor, size: 26), 
             const SizedBox(width: 15), 
             Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : cor))
          ]
        )
      )
    );
  }

  Widget _buildBotaoFralda(String label, IconData icon, Color cor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))], border: Border.all(color: Colors.grey.shade100)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: cor, size: 24), const SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700))]))
    );
  }

  // --- CORREÇÃO DO STREAM BUILDER ---
  Widget _buildHistoricoDoDia() {
    // Usamos o _fluxoRotina que foi inicializado apenas UMA vez no initState
    return StreamBuilder<QuerySnapshot>(
      stream: _fluxoRotina, 
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()));
        
        final inicioDia = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day);
        final fimDia = DateTime(_dataSelecionada.year, _dataSelecionada.month, _dataSelecionada.day, 23, 59, 59);
        
        final docs = snapshot.data!.docs.where((d) {
          var dados = d.data() as Map<String, dynamic>;
          DateTime dt; try { dt = DateTime.parse(dados['data']); } catch(e) { return false; }
          return dt.isAfter(inicioDia) && dt.isBefore(fimDia);
        }).toList();

        if (docs.isEmpty) return const Padding(padding: EdgeInsets.all(40), child: Center(child: Text("Sem registros hoje ainda 💤", style: TextStyle(color: Colors.grey))));

        return ListView.builder(
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(), 
          padding: const EdgeInsets.symmetric(horizontal: 24), 
          itemCount: docs.length,
          itemBuilder: (ctx, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            DateTime dt; try { dt = DateTime.parse(d['data']); } catch (e) { dt = DateTime.now(); }
            final hora = DateFormat('HH:mm').format(dt);
            
            Color cor = Colors.grey; 
            IconData icone = Icons.circle;
            
            if (d['tipo'] == 'mamada') { 
              cor = const Color(0xFFEC407A); icone = Icons.favorite_rounded; 
            }
            else if (d['tipo'] == 'sono') { 
              cor = const Color(0xFF3949AB); icone = Icons.bedtime_rounded; 
            }
            else if (d['tipo'] == 'fralda') { 
              cor = Colors.teal; icone = Icons.layers_rounded; 
            }
            else if (d['tipo'] == 'mamadeira') { 
              cor = Colors.orange; icone = Icons.local_drink_rounded; 
            }
            else if (d['tipo'] == 'banho') { 
              cor = Colors.cyan; icone = Icons.bathtub_rounded; 
            }
            else if (d['tipo'] == 'nutricao') {
              cor = Colors.lightGreen; icone = Icons.restaurant_menu_rounded;
            }

            // --- MOSTRAR LADO NA LISTA ---
            String descricao = "";
            if (d['tipo'] == 'nutricao') {
              descricao = "${d['alimento'] ?? 'Alimento'} (${d['reacao'] ?? '-'})";
            } else {
              descricao = d['duracao_fmt'] ?? d['conteudo'] ?? (d['ml'] != null ? "${d['ml']} ml" : "");
              
              if (d['tipo'] == 'mamada' && d['lado'] != null) {
                String ladoTexto = d['lado'] == 'E' ? ' (Esq)' : ' (Dir)';
                descricao += ladoTexto;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(children: [Text(hora, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 12))]),
                  const SizedBox(width: 15),
                  Column(children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: cor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: cor.withValues(alpha: 0.4), blurRadius: 6)])), 
                    if (i != docs.length - 1) Container(width: 2, height: 40, color: Colors.grey.shade100)
                  ]),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _editarRegistro(docs[i].id, d), 
                      child: Container(
                        padding: const EdgeInsets.all(12), 
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)), 
                        child: Row(children: [
                          Icon(icone, size: 18, color: cor), 
                          const SizedBox(width: 10), 
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(d['tipo'].toString().toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)), 
                            Text(descricao, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87))
                          ])), 
                          GestureDetector(
                            onTap: () => _deletarRegistro(docs[i].id, d), 
                            child: Icon(Icons.close_rounded, size: 16, color: Colors.grey.shade300)
                          )
                        ])
                      )
                    )
                  )
              ]),
            );
          },
        );
      }
    );
  }
}