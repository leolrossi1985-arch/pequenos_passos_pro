import 'package:cloud_firestore/cloud_firestore.dart';

class ConteudoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- LEITURA (Usado pela TelaSalto) ---
  static Future<Map<String, dynamic>?> lerSaltoPorSemana(int semana) async {
    try {
      final query = await _firestore.collection('conteudo_saltos')
          .where('semana_inicio', isLessThanOrEqualTo: semana)
          .get();

      for (var doc in query.docs) {
        final dados = doc.data();
        if (dados['semana_fim'] >= semana) {
          return dados; 
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- FUNÇÃO QUE FALTAVA: ATUALIZAÇÃO INTELIGENTE (WIPE & SEED) ---
  // Esta função apaga todos os documentos da coleção e insere a lista nova
  static Future<void> atualizarColecaoCompleta(String colecao, List<Map<String, dynamic>> novosDados) async {
    // 1. Buscar todos os documentos existentes para deletar
    final snapshot = await _firestore.collection(colecao).get();
    
    WriteBatch batch = _firestore.batch();
    int contador = 0;

    // 2. Deletar antigos
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
      contador++;
      
      // O Firestore limita batchs a 500 operações. Se passar, comita e cria outro.
      if (contador >= 450) { 
        await batch.commit();
        batch = _firestore.batch();
        contador = 0;
      }
    }

    // 3. Inserir novos
    for (var item in novosDados) {
      var docRef = _firestore.collection(colecao).doc(); // ID Automático
      
      // Se o item tiver um ID forçado (ex: saltos), usa ele
      if (item.containsKey('id_manual')) {
         docRef = _firestore.collection(colecao).doc(item['id_manual']);
      }
      
      batch.set(docRef, item);
      contador++;

      if (contador >= 450) {
        await batch.commit();
        batch = _firestore.batch();
        contador = 0;
      }
    }

    // Comita o que sobrou
    await batch.commit();
  }
  
  // (Dados de upload de saltos movidos para cá ou arquivo externo, 
  // mas a função genérica acima resolve para qualquer coleção)
  static Future<void> uploadCargaInicial() async {
     // Mantido para compatibilidade se o botão antigo ainda chamar, 
     // mas o ideal é usar o atualizarColecaoCompleta
  }
}