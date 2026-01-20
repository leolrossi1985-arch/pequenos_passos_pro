import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/bebe_service.dart';
import '../../services/notificacao_service.dart';

class AbaConsultas extends StatefulWidget {
  const AbaConsultas({super.key});

  @override
  State<AbaConsultas> createState() => _AbaConsultasState();
}

class _AbaConsultasState extends State<AbaConsultas> {
  
  void _abrirFormConsulta() { 
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _ModalConsulta()
      )
    ); 
  }

  // Ícones inteligentes por especialidade
  IconData _getIconeEspecialidade(String esp) {
    if (esp.contains('Dentista')) return Icons.face_retouching_natural;
    if (esp.contains('Oftalmo')) return Icons.remove_red_eye;
    if (esp.contains('Fono')) return Icons.hearing;
    if (esp.contains('Vacina')) return Icons.vaccines;
    if (esp.contains('Emergência')) return Icons.local_hospital;
    return Icons.medical_services_outlined; // Padrão (Pediatra)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      
      // --- CORREÇÃO 1: POSICIONAMENTO DO BOTÃO ---
      // Padding bottom de 140 para subir o botão acima da barra de navegação
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140),
        child: FloatingActionButton.extended(
          heroTag: "btnConsultas", 
          onPressed: _abrirFormConsulta, 
          backgroundColor: const Color(0xFF1976D2), // Azul Médico
          foregroundColor: Colors.white, 
          elevation: 4,
          icon: const Icon(Icons.add_rounded), 
          label: const Text("Agendar", style: TextStyle(fontWeight: FontWeight.bold))
        ),
      ), 
      
      body: FutureBuilder<DocumentReference?>(
        future: BebeService.getRefBebeAtivo(),
        builder: (context, snapshotRef) {
          if (!snapshotRef.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blue));
          final ref = snapshotRef.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: ref.collection('consultas').orderBy('data').snapshots(), 
            builder: (ctx, snap) { 
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.blue));
              
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Icon(Icons.calendar_month_outlined, size: 60, color: Colors.blue.withOpacity(0.2)),
                       const SizedBox(height: 15),
                       Text("Nenhuma consulta agendada", style: TextStyle(color: Colors.blue.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 16)),
                     ],
                   ),
                 ); 
              }
              
              return ListView.builder(
                // --- CORREÇÃO 2: PADDING DA LISTA ---
                // Bottom: 160 para o último card não ficar atrás do botão ou da barra
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 160), 
                itemCount: snap.data!.docs.length, 
                itemBuilder: (ctx, i) { 
                  final d = snap.data!.docs[i].data() as Map<String, dynamic>; 
                  final DateTime data = DateTime.parse(d['data']);
                  final bool isPast = data.isBefore(DateTime.now());
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isPast ? Colors.grey.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(isPast ? 0.02 : 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5)
                        )
                      ],
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // DATA (CALENDÁRIO LATERAL)
                          Container(
                            width: 70,
                            decoration: BoxDecoration(
                              color: isPast ? Colors.grey.shade200 : Colors.blue.shade50,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('dd').format(data), 
                                  style: TextStyle(
                                    fontSize: 24, 
                                    fontWeight: FontWeight.w900, 
                                    color: isPast ? Colors.grey : Colors.blue.shade800
                                  )
                                ),
                                Text(
                                  DateFormat('MMM').format(data).toUpperCase(), 
                                  style: TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: isPast ? Colors.grey : Colors.blue.shade800
                                  )
                                ),
                              ],
                            ),
                          ),
                          
                          // CONTEÚDO
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(_getIconeEspecialidade(d['especialidade'] ?? ''), size: 18, color: isPast ? Colors.grey : Colors.blue),
                                      const SizedBox(width: 8),
                                      Text(
                                        d['especialidade'] ?? 'Consulta', 
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, 
                                          color: isPast ? Colors.grey : Colors.blue, 
                                          fontSize: 12
                                        )
                                      ),
                                      const Spacer(),
                                      // Botão de Deletar Discreto
                                      GestureDetector(
                                        onTap: () => snap.data!.docs[i].reference.delete(),
                                        child: Icon(Icons.close, size: 16, color: Colors.grey.shade300),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    d['medico'] ?? 'Médico não informado', 
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900, 
                                      fontSize: 16, 
                                      color: isPast ? Colors.grey : const Color(0xFF2D3A3A)
                                    )
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('HH:mm').format(data), 
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)
                                      ),
                                      if (d['local'] != null && d['local'].toString().isNotEmpty) ...[
                                        const SizedBox(width: 10),
                                        Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade500),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text(d['local'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                                      ]
                                    ],
                                  )
                                ],
                              ),
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

// --- MODAL DE CONSULTA (PREMIUM) ---
class _ModalConsulta extends StatefulWidget { const _ModalConsulta(); @override State<_ModalConsulta> createState() => _ModalConsultaState(); }
class _ModalConsultaState extends State<_ModalConsulta> {
  final _medicoCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  
  DateTime _dataConsulta = DateTime.now().add(const Duration(days: 1));
  String _especialidade = 'Pediatra';
  int _lembreteMinutos = 60; 

  Future<void> _selecionarData() async {
    final d = await showDatePicker(context: context, initialDate: _dataConsulta, firstDate: DateTime.now(), lastDate: DateTime(2030));
    if (d != null) setState(() => _dataConsulta = DateTime(d.year, d.month, d.day, _dataConsulta.hour, _dataConsulta.minute));
  }

  Future<void> _selecionarHora() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dataConsulta));
    if (t != null) setState(() => _dataConsulta = DateTime(_dataConsulta.year, _dataConsulta.month, _dataConsulta.day, t.hour, t.minute));
  }

  @override 
  Widget build(BuildContext context) {
    String diaSemana = DateFormat('EEEE', 'pt_BR').format(_dataConsulta);
    // Capitaliza primeira letra
    diaSemana = diaSemana[0].toUpperCase() + diaSemana.substring(1);
    String diaMes = DateFormat('dd MMM', 'pt_BR').format(_dataConsulta);
    String hora = DateFormat('HH:mm').format(_dataConsulta);

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      padding: EdgeInsets.fromLTRB(24, 30, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            const Center(child: Text("Agendar Consulta", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)))), 
            const SizedBox(height: 30),
            
            // ESPECIALIDADE
            const Text("Especialidade", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            DropdownButtonFormField<String>(
              value: _especialidade, 
              icon: const Icon(Icons.keyboard_arrow_down_rounded), 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), 
              decoration: const InputDecoration(border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey))), 
              items: ['Pediatra', 'Dentista', 'Emergência', 'Vacina', 'Fonoaudiólogo', 'Oftalmologista', 'Outro'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
              onChanged: (val) => setState(() => _especialidade = val!)
            ),
            
            const SizedBox(height: 25),
            
            // DATA E HORA (GRANDES)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selecionarData,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("DATA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(height: 5),
                          Text(diaMes, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Text(diaSemana, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: _selecionarHora,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("HORA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(height: 5),
                          Text(hora, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const Text("Toque p/ mudar", style: TextStyle(fontSize: 12, color: Colors.transparent)), // Espaço reserva
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 25),
            
            // CAMPOS
            TextField(controller: _medicoCtrl, decoration: InputDecoration(labelText: "Nome do Médico / Clínica", prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[50])),
            const SizedBox(height: 15),
            TextField(controller: _localCtrl, decoration: InputDecoration(labelText: "Endereço / Local", prefixIcon: const Icon(Icons.location_on_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[50])),
            
            const SizedBox(height: 25),
            
            // LEMBRETE
            DropdownButtonFormField<int>(
              value: _lembreteMinutos,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.notifications_active_outlined, color: Colors.orange), labelText: "Lembrete", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: const [DropdownMenuItem(value: 0, child: Text("Sem lembrete")), DropdownMenuItem(value: 15, child: Text("15 min antes")), DropdownMenuItem(value: 30, child: Text("30 min antes")), DropdownMenuItem(value: 60, child: Text("1 hora antes")), DropdownMenuItem(value: 1440, child: Text("1 dia antes"))],
              onChanged: (v) => setState(() => _lembreteMinutos = v!),
            ),

            const SizedBox(height: 30),
            
            // BOTÃO SALVAR
            SizedBox(
              width: double.infinity, 
              height: 55, 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), 
                onPressed: () async { 
                  final bebeRef = await BebeService.getRefBebeAtivo(); 
                  if (bebeRef != null) { 
                    await bebeRef.collection('consultas').add({ 'especialidade': _especialidade, 'medico': _medicoCtrl.text, 'local': _localCtrl.text, 'obs': _obsCtrl.text, 'data': _dataConsulta.toIso8601String() }); 
                    
                    if (_lembreteMinutos > 0) { 
                      int idNotif = DateTime.now().millisecondsSinceEpoch ~/ 1000; 
                      DateTime dataLembrete = _dataConsulta.subtract(Duration(minutes: _lembreteMinutos));
                      if (dataLembrete.isAfter(DateTime.now())) {
                        await NotificacaoService.agendarNotificacao(id: idNotif, titulo: "Consulta: $_especialidade 🩺", corpo: "Com ${_medicoCtrl.text.isEmpty ? 'o médico' : _medicoCtrl.text} às $hora", dataHora: dataLembrete); 
                      }
                    } 
                  } 
                  if (mounted) Navigator.pop(context); 
                }, 
                child: const Text("AGENDAR CONSULTA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
              )
            )
          ]
        ),
      )
    );
  }
}