import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'bebe_service.dart';

class RotinaService {
  
  // ===========================================================================
  // 1. REGISTRAR EVENTO (Mantive o mesmo nome para não quebrar suas telas)
  // ===========================================================================
  static Future<void> registrarEvento(String tipo, Map<String, dynamic> detalhes) async {
    final ref = await BebeService.getRefBebeAtivo();
    if (ref == null) return;

    // Se não vier data nos detalhes, usa Agora.
    DateTime dataHora;
    if (detalhes['data'] != null) {
      dataHora = DateTime.parse(detalhes['data']);
    } else {
      dataHora = DateTime.now();
    }
    
    final String dataIso = DateFormat('yyyy-MM-dd').format(dataHora);

    try {
      // A. Salva no Histórico (Como já fazia antes)
      await ref.collection('rotina').add({
        'tipo': tipo,
        'data': dataHora.toIso8601String(),
        ...detalhes, // Espalha os dados (lado, duração, aspecto, etc)
        'criado_em': FieldValue.serverTimestamp(),
      });

      // B. Atualiza o Contador do Painel (A CORREÇÃO ESTÁ AQUI)
      // Sem isso, o número na tela de evolução nunca muda.
      if (tipo == 'mamada' || tipo == 'fralda') {
        String campo = tipo == 'mamada' ? 'mamadas' : 'fraldas';
        
        await ref.collection('resumos').doc(dataIso).set({
          campo: FieldValue.increment(1), // Soma +1
          'ultima_atualizacao': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        print(">>> Sucesso: Contador '$campo' SOMOU +1 no dia $dataIso");
      }

    } catch (e) {
      print("Erro ao registrar evento: $e");
      throw e;
    }
  }

  // ===========================================================================
  // 2. REMOVER EVENTO (Adicione essa função no seu botão de excluir)
  // ===========================================================================
  // Se você já tem um botão de excluir, certifique-se de chamar ESTA função
  // para que o contador diminua corretamente.
  static Future<void> removerEvento(String idEvento, String tipo, DateTime dataOriginal) async {
    final ref = await BebeService.getRefBebeAtivo();
    if (ref == null) return;

    final String dataIso = DateFormat('yyyy-MM-dd').format(dataOriginal);

    try {
      // A. Remove do Histórico
      await ref.collection('rotina').doc(idEvento).delete();

      // B. Atualiza o Contador (Subtrai)
      if (tipo == 'mamada' || tipo == 'fralda') {
        String campo = tipo == 'mamada' ? 'mamadas' : 'fraldas';

        await ref.collection('resumos').doc(dataIso).set({
          campo: FieldValue.increment(-1), // Subtrai -1
        }, SetOptions(merge: true));
        
        print(">>> Sucesso: Contador '$campo' SUBTRAIU -1 no dia $dataIso");
      }

    } catch (e) {
      print("Erro ao remover evento: $e");
    }
  }

  // ===========================================================================
  // 3. LER HISTÓRICO (Mantido igual)
  // ===========================================================================
  static Stream<QuerySnapshot> streamHistorico() async* {
    final ref = await BebeService.getRefBebeAtivo();
    if (ref != null) {
      yield* ref.collection('rotina').orderBy('data', descending: true).limit(30).snapshots();
    }
  }

  // ===========================================================================
  // 4. OBTER ÚLTIMO REGISTRO (Mantido igual)
  // ===========================================================================
  static Future<Map<String, dynamic>?> getUltimoEvento(String tipo) async {
    final ref = await BebeService.getRefBebeAtivo();
    if (ref == null) return null;

    final snap = await ref.collection('rotina')
        .where('tipo', isEqualTo: tipo)
        .orderBy('data', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      return snap.docs.first.data();
    }
    return null;
  }
}