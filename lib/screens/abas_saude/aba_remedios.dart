import 'dart:io';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/bebe_service.dart';
import '../../services/medicamento_service.dart';
import '../../services/notificacao_service.dart';
import '../../utils/image_helper.dart'; 

class AbaRemedios extends StatefulWidget {
  const AbaRemedios({super.key});

  @override
  State<AbaRemedios> createState() => _AbaRemediosState();
}

class _AbaRemediosState extends State<AbaRemedios> {
  
  void _abrirFormMedicamento() { 
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _ModalMedicamento()
      )
    ); 
  }

  Widget _buildImagemRemedio(String dadosImagem, bool ativo) {
    if (dadosImagem.isEmpty) {
      return Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: ativo ? Colors.deepPurple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.medication_liquid_rounded, color: ativo ? Colors.deepPurple : Colors.grey, size: 28),
      );
    }

    final img = ImageHelper.base64ToImage(dadosImagem);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => _TelaImagemFull(imagem: img)));
      },
      child: Hero(
        tag: dadosImagem.hashCode, 
        child: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: img, fit: BoxFit.cover),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }

  // FUNÇÃO AUXILIAR PARA CANCELAR ALARMES
  Future<void> _cancelarAlarmesDoRemedio(String docId) async {
    // O ID base é o hash do ID do documento
    int idBase = docId.hashCode;
    
    // Cancela o ID base e os próximos 50 possíveis agendamentos (ciclos futuros)
    // Isso garante que nenhuma notificação sobre
    for (int i = 0; i < 55; i++) {
      await NotificacaoService.cancelarNotificacao(idBase + i);
    }
    print("Alarmes do remédio $docId cancelados.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140),
        child: FloatingActionButton.extended(
          heroTag: "btnRemedios", 
          onPressed: _abrirFormMedicamento, 
          backgroundColor: const Color(0xFF673AB7), 
          foregroundColor: Colors.white, 
          elevation: 4,
          icon: const Icon(Icons.add_rounded), 
          label: const Text("Adicionar", style: TextStyle(fontWeight: FontWeight.bold))
        ),
      ),
      
      body: FutureBuilder<DocumentReference?>(
        future: BebeService.getRefBebeAtivo(),
        builder: (context, snapshotRef) {
          if (!snapshotRef.hasData) return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          final ref = snapshotRef.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: ref.collection('medicamentos').orderBy('criado_em', descending: true).snapshots(), 
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
              
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                 return _buildEmptyState();
              }
              
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 160), 
                itemCount: snap.data!.docs.length, 
                itemBuilder: (ctx, i) {
                  final d = snap.data!.docs[i].data() as Map<String, dynamic>;
                  final id = snap.data!.docs[i].id;
                  return _buildCardMedicamento(id, d);
                },
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 60, color: Colors.deepPurple.withOpacity(0.2)),
          const SizedBox(height: 15),
          Text("Nenhum medicamento", style: TextStyle(color: Colors.deepPurple.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCardMedicamento(String id, Map<String, dynamic> d) {
    final bool ativo = d['ativo'] ?? true;
    final int intervalo = d['intervalo'] ?? 6;
    final int dias = d['diasDuracao'] ?? 5; 
    
    DateTime inicio;
    try { inicio = DateTime.parse(d['inicio']); } catch(e) { inicio = DateTime.now(); }
    
    DateTime prox = inicio;
    if (ativo) { 
      while(prox.isBefore(DateTime.now())) {
        prox = prox.add(Duration(hours: intervalo)); 
      }
    }

    String textoDuracao = dias == -1 ? "Uso Contínuo" : "$dias dias";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ativo ? Colors.deepPurple.withOpacity(0.08) : Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5)
          )
        ],
        border: Border.all(color: ativo ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagemRemedio(d['imagemPath']??"", ativo),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['nome'] ?? 'Sem Nome', 
                        style: TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 16,
                          color: ativo ? const Color(0xFF2D3A3A) : Colors.grey
                        )
                      ),
                      const SizedBox(height: 4),
                      Text("Dose: ${d['dosagem']}", style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      Text("A cada ${intervalo}h • $textoDuracao", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                if (ativo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Column(
                      children: [
                        const Text("PRÓXIMA", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        Text(DateFormat('HH:mm').format(prox), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple)),
                        Text(DateFormat('dd/MM').format(prox), style: TextStyle(fontSize: 10, color: Colors.deepPurple.withOpacity(0.7))),
                      ],
                    ),
                  )
              ],
            ),
          ),
          
          // --- AÇÕES DO CARD (CORRIGIDO PARA CANCELAR ALARMES) ---
          if (ativo) ...[
            Container(height: 1, color: Colors.grey.withOpacity(0.1)),
            InkWell(
              onTap: () async {
                 // 1. Cancela alarmes do celular
                 await _cancelarAlarmesDoRemedio(id);
                 // 2. Atualiza no banco
                 await MedicamentoService.finalizarMedicamento(id);
                 if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tratamento finalizado e alarme desligado."), backgroundColor: Colors.green));
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 18, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text("CONCLUIR TRATAMENTO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade700, letterSpacing: 0.5)),
                  ],
                ),
              ),
            )
          ] else ...[
             // Opção de excluir se já inativo
             Container(height: 1, color: Colors.grey.withOpacity(0.1)),
             InkWell(
              onTap: () async {
                // 1. Cancela alarmes (por garantia)
                await _cancelarAlarmesDoRemedio(id);
                // 2. Deleta do banco
                await MedicamentoService.deletarMedicamento(id);
                if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removido e alarmes cancelados."), backgroundColor: Colors.grey));
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("REMOVER DO HISTÓRICO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}

// --- MODAL DE CADASTRO ---
class _ModalMedicamento extends StatefulWidget {
  const _ModalMedicamento();
  @override
  State<_ModalMedicamento> createState() => _ModalMedicamentoState();
}

class _ModalMedicamentoState extends State<_ModalMedicamento> {
  final _nomeCtrl = TextEditingController(); 
  final _doseCtrl = TextEditingController(); 
  
  int _intervaloHoras = 6; 
  int _diasDuracao = 5; 
  DateTime _dataInicio = DateTime.now(); 

  XFile? _imagemSelecionada;
  bool _salvando = false;

  Future<void> _tirarFoto(bool isCamera) async { 
    final picker = ImagePicker(); 
    final foto = await picker.pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery, imageQuality: 25, maxWidth: 600); 
    if (foto != null) setState(() => _imagemSelecionada = foto);
  }

  Future<void> _selecionarInicio() async {
    final data = await showDatePicker(context: context, initialDate: _dataInicio, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 30)));
    if (data == null) return;
    if (mounted) {
      final hora = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dataInicio));
      if (hora != null) setState(() => _dataInicio = DateTime(data.year, data.month, data.day, hora.hour, hora.minute));
    }
  }

  void _salvar() async {
    if (_nomeCtrl.text.isEmpty) return;
    setState(() => _salvando = true);
    
    try {
      String imagemBase64 = "";
      if (_imagemSelecionada != null) {
         final bytes = await _imagemSelecionada!.readAsBytes();
         imagemBase64 = base64Encode(bytes);
      }

      // O SERVICE AGORA CUIDA DO AGENDAMENTO PARA GARANTIR O ID CORRETO
      await MedicamentoService.adicionarMedicamento(
        nome: _nomeCtrl.text.trim(), 
        dosagem: _doseCtrl.text.trim(), 
        intervaloHoras: _intervaloHoras, 
        diasDuracao: _diasDuracao, 
        dataInicio: _dataInicio, 
        imagemPath: imagemBase64 
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar.")));
      }
    }
  }

  @override 
  Widget build(BuildContext context) { 
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), 
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24), 
      child: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("Novo Medicamento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)))), 
            const SizedBox(height: 25), 
            
            Row(
              children: [
                GestureDetector(
                  onTap: () => showModalBottomSheet(context: context, builder: (_) => Wrap(children: [ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Câmera"), onTap: (){ Navigator.pop(context); _tirarFoto(true); }), ListTile(leading: const Icon(Icons.photo), title: const Text("Galeria"), onTap: (){ Navigator.pop(context); _tirarFoto(false); })])), 
                  child: Container(
                    height: 80, width: 80, 
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.deepPurple.withOpacity(0.2), width: 1), image: _imagemSelecionada != null ? DecorationImage(image: FileImage(File(_imagemSelecionada!.path)), fit: BoxFit.cover) : null), 
                    child: _imagemSelecionada == null ? const Icon(Icons.add_a_photo_rounded, color: Colors.deepPurple, size: 24) : null
                  )
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      TextField(controller: _nomeCtrl, decoration: const InputDecoration(labelText: "Nome do Remédio", prefixIcon: Icon(Icons.medication), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0))), 
                      const SizedBox(height: 10), 
                      TextField(controller: _doseCtrl, decoration: const InputDecoration(labelText: "Dose (ex: 5ml)", prefixIcon: Icon(Icons.opacity), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0))), 
                    ],
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 20), 
            
            Row(children: [
              Expanded(child: DropdownButtonFormField<int>(value: _intervaloHoras, decoration: const InputDecoration(labelText: "Intervalo", border: OutlineInputBorder()), items: [4, 6, 8, 12, 24].map((v) => DropdownMenuItem(value: v, child: Text("A cada ${v}h"))).toList(), onChanged: (v) => setState(() => _intervaloHoras = v!))), 
              const SizedBox(width: 15), 
              Expanded(child: InkWell(onTap: _selecionarInicio, child: InputDecorator(decoration: const InputDecoration(labelText: "1ª Dose", border: OutlineInputBorder(), prefixIcon: Icon(Icons.access_time)), child: Text(DateFormat("HH:mm").format(_dataInicio), style: const TextStyle(fontWeight: FontWeight.bold)))))
            ]), 

            const SizedBox(height: 15),

            DropdownButtonFormField<int>(value: _diasDuracao, decoration: const InputDecoration(labelText: "Duração", border: OutlineInputBorder(), prefixIcon: Icon(Icons.date_range)), items: const [DropdownMenuItem(value: 3, child: Text("3 dias")), DropdownMenuItem(value: 5, child: Text("5 dias")), DropdownMenuItem(value: 7, child: Text("7 dias")), DropdownMenuItem(value: 10, child: Text("10 dias")), DropdownMenuItem(value: 14, child: Text("14 dias")), DropdownMenuItem(value: -1, child: Text("Uso Contínuo"))], onChanged: (v) => setState(() => _diasDuracao = v!)), 
            
            const SizedBox(height: 30), 
            
            SizedBox(
              width: double.infinity, height: 55, 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF673AB7), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0), 
                onPressed: _salvando ? null : _salvar, 
                child: _salvando ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("INICIAR TRATAMENTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
              )
            )
          ]),
      )
    ); 
  }
}

class _TelaImagemFull extends StatelessWidget {
  final ImageProvider imagem;
  const _TelaImagemFull({required this.imagem});
  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)), body: Center(child: InteractiveViewer(child: Image(image: imagem))));
  }
}