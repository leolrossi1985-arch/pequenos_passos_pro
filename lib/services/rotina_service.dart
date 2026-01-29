import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'bebe_service.dart';

class RotinaService {
  
  // ===========================================================================
  // 1. REGISTRAR EVENTO (Salva e Atualiza Contadores Automaticamente)
  // ===========================================================================
  static Future<void> registrarEvento(String tipo, Map<String, dynamic> detalhes) async {
    debugPrint(">>> [RotinaService] Iniciando registro: $tipo"); // Debug

    final ref = await BebeService.getRefBebeAtivo();
    if (ref == null) return;

    // 1. Define a data correta
    DateTime dataHora;
    if (detalhes['data'] != null) {
      if (detalhes['data'] is String) {
        dataHora = DateTime.parse(detalhes['data']);
      } else {
        dataHora = detalhes['data'];
      }
    } else {
      dataHora = DateTime.now();
    }
    
    final String dataIso = DateFormat('yyyy-MM-dd').format(dataHora);

    try {
      // 2. Salva o evento no histórico (Coleção 'rotina')
      await ref.collection('rotina').add({
        'tipo': tipo,
        'data': dataHora.toIso8601String(),
        ...detalhes, 
        'criado_em': FieldValue.serverTimestamp(),
      });

      // 3. ATUALIZA OS CONTADORES (Logica Centralizada)
      Map<String, dynamic> atualizacoes = {
        'ultima_atualizacao': FieldValue.serverTimestamp(),
      };

      // Define qual campo somar baseado no tipo
      if (tipo == 'fralda') {
        atualizacoes['fraldas'] = FieldValue.increment(1);
      } 
      else if (tipo == 'mamada') {
        atualizacoes['mamadas'] = FieldValue.increment(1);
      }
      else if (tipo == 'mamadeira') {
        atualizacoes['mamadeiras'] = FieldValue.increment(1);
      }
      else if (tipo == 'banho') {
        atualizacoes['banhos'] = FieldValue.increment(1);
      }
      else if (tipo == 'sono') {
        atualizacoes['sonecas'] = FieldValue.increment(1);
        // Se tiver duração, soma os minutos também
        if (detalhes['duracao_segundos'] != null) {
          int minutos = (detalhes['duracao_segundos'] as int) ~/ 60;
          atualizacoes['sono_minutos'] = FieldValue.increment(minutos);
        }
      }
      // Se for introdução alimentar (Nutrição)
      else if (tipo == 'nutricao') {
         String cat = detalhes['categoria'] ?? '';
         if (cat.contains('Fruta')) {
           atualizacoes['nutri_frutas'] = FieldValue.increment(1);
         } else if (cat.contains('Legume')) {
           atualizacoes['nutri_legumes'] = FieldValue.increment(1);
         } else if (cat.contains('Proteína')) {
           atualizacoes['nutri_proteina'] = FieldValue.increment(1);
         } else {
           atualizacoes['nutri_outros'] = FieldValue.increment(1);
         }
      }

      // 4. Executa a atualização no banco (Coleção 'resumos')
      if (atualizacoes.length > 1) { // Tem mais que só a data de atualização
        await ref.collection('resumos').doc(dataIso).set(atualizacoes, SetOptions(merge: true));
        debugPrint(">>> [RotinaService] Contadores atualizados para $tipo no dia $dataIso");
      }

    } catch (e) {
      debugPrint("Erro ao registrar evento: $e");
      rethrow;
    }
  }

  // ===========================================================================
  // 2. REMOVER EVENTO (Apaga e Subtrai Contadores)
  // ===========================================================================
  static Future<void> removerEvento(String idEvento, String tipo, dynamic dadosEvento) async {
    final ref = await BebeService.getRefBebeAtivo();
    if (ref == null) return;

    // Tenta descobrir a data do evento para descontar no dia certo
    DateTime dataOriginal = DateTime.now();
    if (dadosEvento['data'] != null) {
       dataOriginal = DateTime.parse(dadosEvento['data']);
    }

    final String dataIso = DateFormat('yyyy-MM-dd').format(dataOriginal);

    try {
      // 1. Remove do Histórico
      await ref.collection('rotina').doc(idEvento).delete();

      // 2. Prepara a subtração no contador
      Map<String, dynamic> atualizacoes = {};

      if (tipo == 'fralda') {
        atualizacoes['fraldas'] = FieldValue.increment(-1);
      } 
      else if (tipo == 'mamada') {
        atualizacoes['mamadas'] = FieldValue.increment(-1);
      }
      else if (tipo == 'mamadeira') {
        atualizacoes['mamadeiras'] = FieldValue.increment(-1);
      }
      else if (tipo == 'banho') {
        atualizacoes['banhos'] = FieldValue.increment(-1);
      }
      else if (tipo == 'sono') {
        atualizacoes['sonecas'] = FieldValue.increment(-1);
        if (dadosEvento['duracao_segundos'] != null) {
          int minutos = (dadosEvento['duracao_segundos'] as int) ~/ 60;
          atualizacoes['sono_minutos'] = FieldValue.increment(-minutos);
        }
      }

      // 3. Executa a subtração
      if (atualizacoes.isNotEmpty) {
        await ref.collection('resumos').doc(dataIso).set(atualizacoes, SetOptions(merge: true));
        debugPrint(">>> [RotinaService] Contador decrementado para $tipo");
      }

    } catch (e) {
      debugPrint("Erro ao remover evento: $e");
    }
  }

  // 3. LER HISTÓRICO
  static Stream<QuerySnapshot> streamHistorico() async* {
    final ref = await BebeService.getRefBebeAtivo();
    if (ref != null) {
      yield* ref.collection('rotina').orderBy('data', descending: true).limit(30).snapshots();
    }
  }

  // 4. OBTER ÚLTIMO REGISTRO
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