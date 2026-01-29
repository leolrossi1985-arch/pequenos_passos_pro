import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/bebe_service.dart';
import '../../services/notificacao_service.dart';
import '../../data/dados_vacinas.dart'; 

class AbaVacinas extends StatefulWidget {
  const AbaVacinas({super.key});

  @override
  State<AbaVacinas> createState() => _AbaVacinasState();
}

class _AbaVacinasState extends State<AbaVacinas> {
  
  // Agrupa vacinas por idade para exibição organizada
  Map<int, List<Map<String, dynamic>>> _agruparVacinas() {
    Map<int, List<Map<String, dynamic>>> grupos = {};
    for (var v in vacinasPadrao) {
      int mes = v['meses'];
      if (!grupos.containsKey(mes)) grupos[mes] = [];
      grupos[mes]!.add(v);
    }
    // Ordena as chaves (meses)
    return Map.fromEntries(grupos.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  void _toggleVacina(String idVacina, bool estadoAtual) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;

    if (!estadoAtual) {
      await bebeRef.collection('vacinas').doc(idVacina).set({
        'tomadaEm': DateTime.now().toIso8601String(), 
        'id': idVacina
      });
    } else {
      await bebeRef.collection('vacinas').doc(idVacina).delete();
    }
  }

  void _agendarLembreteVacina(String nomeVacina) async {
    final data = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030), 
      helpText: "DATA DA VACINA"
    );

    if (data != null) {
       if (!mounted) return;
       final hora = await showTimePicker(
         context: context,
         initialTime: const TimeOfDay(hour: 9, minute: 0),
         helpText: "HORÁRIO DO LEMBRETE"
       );

       if (hora != null) {
         final dataLembrete = DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
         int idNotificacao = DateTime.now().millisecondsSinceEpoch ~/ 1000;
         
         await NotificacaoService.agendarNotificacao(
           id: idNotificacao, 
           titulo: "Vacina: $nomeVacina 💉", 
           corpo: "Hora de vacinar seu bebê!", 
           dataHora: dataLembrete
         );
         
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Lembrete agendado para ${data.day}/${data.month} às ${hora.format(context)}"), backgroundColor: Colors.teal)
           );
         }
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gruposVacinas = _agruparVacinas();

    return FutureBuilder<DocumentReference?>(
      future: BebeService.getRefBebeAtivo(),
      builder: (context, snapshotRef) {
        if (!snapshotRef.hasData) return const Center(child: CircularProgressIndicator(color: Colors.teal));
        final ref = snapshotRef.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: ref.collection('vacinas').snapshots(), 
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Colors.teal));
            final tomadas = snap.data!.docs.map((d) => d.id).toList();
            
            // Calcula progresso total
            int total = vacinasPadrao.length;
            int concluidas = tomadas.length;
            double progressoGeral = total > 0 ? concluidas / total : 0.0;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                // CARD DE RESUMO
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF009688), Color(0xFF4DB6AC)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(width: 60, height: 60, child: CircularProgressIndicator(value: progressoGeral, color: Colors.white, backgroundColor: Colors.white24, strokeWidth: 6)),
                          Text("${(progressoGeral * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                        ],
                      ),
                      const SizedBox(width: 20),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Caderneta Digital", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text("Mantenha as vacinas em dia para a saúde do seu bebê.", style: TextStyle(color: Colors.white70, fontSize: 12))
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // LISTA AGRUPADA POR IDADE (TIMELINE)
                ...gruposVacinas.entries.map((entry) {
                  int mes = entry.key;
                  List<Map<String, dynamic>> lista = entry.value;
                  
                  // Verifica se todas deste grupo foram tomadas
                  bool grupoCompleto = lista.every((v) => tomadas.contains(v['id']));
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // COLUNA ESQUERDA (IDADE)
                        SizedBox(
                          width: 50,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: grupoCompleto ? Colors.teal : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: grupoCompleto ? Colors.teal : Colors.grey.shade300, width: 2)
                                ),
                                child: Icon(grupoCompleto ? Icons.check : Icons.calendar_today, size: 16, color: grupoCompleto ? Colors.white : Colors.grey),
                              ),
                              Container(width: 2, height: (lista.length * 70).toDouble(), color: Colors.grey.shade200)
                            ],
                          ),
                        ),
                        
                        // COLUNA DIREITA (CARD)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10, bottom: 10),
                                child: Text(mes == 0 ? "AO NASCER" : "$mes MESES", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                  border: Border.all(color: Colors.grey.shade100)
                                ),
                                child: Column(
                                  children: lista.map((v) {
                                    bool isTomada = tomadas.contains(v['id']);
                                    return _buildItemVacina(v, isTomada, lista.last == v);
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                })
              ],
            );
          }
        );
      }
    );
  }

  Widget _buildItemVacina(Map<String, dynamic> vacina, bool isTomada, bool isLast) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: GestureDetector(
            onTap: () => _toggleVacina(vacina['id'], isTomada),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: isTomada ? Colors.teal : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isTomada ? Colors.teal : Colors.grey.shade300, width: 2)
              ),
              child: isTomada ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ),
          title: Text(
            vacina['nome'], 
            style: TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: isTomada ? Colors.grey.shade400 : const Color(0xFF2D3A3A),
              decoration: isTomada ? TextDecoration.lineThrough : null
            )
          ),
          subtitle: isTomada 
            ? const Text("Vacina tomada", style: TextStyle(fontSize: 10, color: Colors.teal))
            : null,
          trailing: !isTomada
            ? IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.orange),
                onPressed: () => _agendarLembreteVacina(vacina['nome']),
                tooltip: "Agendar Lembrete",
              )
            : null,
        ),
        if (!isLast) Divider(height: 1, indent: 60, endIndent: 20, color: Colors.grey.shade100)
      ],
    );
  }
}