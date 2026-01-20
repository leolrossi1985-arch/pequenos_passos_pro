import 'package:cloud_firestore/cloud_firestore.dart';
import 'bebe_service.dart';

class AlimentacaoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. USO DO USUÁRIO (REGISTRAR EXPERIÊNCIA) ---
  // ATUALIZADO: Agora recebe 'dadosAlimento' para salvar Categoria e Nome (Vital para o Gráfico)
  static Future<void> registrarExperiencia(String idAlimento, String reacao, String notas, Map<String, dynamic> dadosAlimento) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;

    await bebeRef.collection('alimentacao').doc(idAlimento).set({
      'id_alimento': idAlimento,
      'reacao': reacao, // 'gostou', 'rejeitou', 'alergia'
      'notas': notas,
      'data': DateTime.now().toIso8601String(),
      'ja_comeu': true,
      
      // --- NOVOS CAMPOS (Para o Gráfico e Histórico) ---
      'nome': dadosAlimento['nome'],
      'categoria': dadosAlimento['categoria'], // Fundamental para as cores do gráfico
      'imagemUrl': dadosAlimento['imagemUrl'],
    }, SetOptions(merge: true));
  }

  // --- 2. USO DO APP (BUSCAR RECEITAS/SUGESTÕES) ---
  // MANTIDO
  static Stream<QuerySnapshot> streamReceitas(int mesesIdade) {
    int fase = 1;
    if (mesesIdade >= 9 && mesesIdade < 12) fase = 2;
    if (mesesIdade >= 12) fase = 3;

    return _firestore
        .collection('biblioteca_receitas')
        .where('fase', isEqualTo: fase)
        .snapshots();
  }

  // --- 3. USO DO ADMIN (UPLOAD DA BASE DE DADOS) ---
  // MANTIDO
  
  // Upload dos Alimentos (Enciclopédia)
  static Future<void> uploadAlimentosIniciais(List<Map<String, dynamic>> lista) async {
    final batch = _firestore.batch();
    final col = _firestore.collection('biblioteca_alimentos');
    
    for (var item in lista) {
      // Cria um novo documento para cada alimento
      var doc = col.doc(); 
      batch.set(doc, item);
    }
    await batch.commit();
  }

  // Upload das Receitas
  static Future<void> uploadReceitas(List<Map<String, dynamic>> lista) async {
    final batch = _firestore.batch();
    final col = _firestore.collection('biblioteca_receitas');
    
    for (var item in lista) {
      var doc = col.doc();
      batch.set(doc, item);
    }
    await batch.commit();
  }
}