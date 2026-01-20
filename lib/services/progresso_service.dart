import 'package:cloud_firestore/cloud_firestore.dart';
import 'bebe_service.dart'; // Importa o serviço que sabe qual bebê está ativo

class ProgressoService {
  // Salva dentro de: users/{uid}/bebes/{id_bebe}/progresso/{tipo_semana}
  
  static Future<void> alternarItem(String tipo, int semana, String item) async {
    // 1. Pega a referência do bebê atual
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return; // Segurança

    final docRef = bebeRef.collection('progresso').doc('${tipo}_$semana');

    try {
      final doc = await docRef.get();
      List<String> lista = [];
      if (doc.exists && doc.data() != null) {
        lista = List<String>.from(doc.data()!['itens'] ?? []);
      }

      if (lista.contains(item)) {
        lista.remove(item);
      } else {
        lista.add(item);
      }

      await docRef.set({'itens': lista}, SetOptions(merge: true));
    } catch (e) {
      print("Erro ao salvar progresso: $e");
    }
  }

  static Future<List<String>> lerItens(String tipo, int semana) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return [];

    try {
      final doc = await bebeRef.collection('progresso').doc('${tipo}_$semana').get();
      if (doc.exists && doc.data() != null) {
        return List<String>.from(doc.data()!['itens'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}