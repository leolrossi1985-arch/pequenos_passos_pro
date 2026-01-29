import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'bebe_service.dart';
import 'notificacao_service.dart';

class SincronizacaoService {
  
  static Future<void> reagendarNotificacoesAtivas() async {
    debugPrint("🔄 [Sincronização] Verificando remédios para reagendar...");
    
    final bebeData = await BebeService.lerBebeAtivo();
    if (bebeData == null) return;
    
    final String bebeId = bebeData['id'];
    
    try {
      // --- CORREÇÃO AQUI ---
      // Antes estava 'remedios', agora deve ser 'medicamentos' para bater com o salvamento
      final snapshot = await FirebaseFirestore.instance
          .collection('bebes')
          .doc(bebeId)
          .collection('medicamentos') // <--- NOME CORRIGIDO
          .where('ativo', isEqualTo: true) 
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint("ℹ️ Nenhum remédio ativo encontrado na coleção 'medicamentos'.");
        return;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Verifica validade
        if (data['data_fim'] != null) {
           final dataFim = DateTime.parse(data['data_fim']);
           if (DateTime.now().isAfter(dataFim)) continue; 
        }

        // Tenta pegar os nomes dos campos (com fallback para garantir)
        String nome = data['nome_medicamento'] ?? data['nome'] ?? 'Remédio';
        
        // Garante que as datas e intervalos existam
        if (data['data_inicio'] == null || data['frequencia_horas'] == null) {
           debugPrint("⚠️ Dados incompletos para o remédio: $nome");
           continue;
        }

        DateTime dataInicio = DateTime.parse(data['data_inicio']);
        int intervalo = (data['frequencia_horas'] as num).toInt(); 
        
        // Garante que o ID existe, senão gera um hash do ID do documento
        int idNotificacaoBase;
        if (data['id_notificacao'] != null) {
           idNotificacaoBase = (data['id_notificacao'] as num).toInt();
        } else {
           idNotificacaoBase = doc.id.hashCode;
        }

        // Reagenda +5 dias
        await NotificacaoService.agendarLembretesContinuos(
          idBase: idNotificacaoBase,
          titulo: "Hora do Remédio 💊",
          corpo: "Hora de tomar $nome",
          dataInicioOriginal: dataInicio,
          intervaloHoras: intervalo,
          diasBuffer: 5, 
        );
      }
      debugPrint("✅ [Sincronização] Concluída com sucesso.");
      
    } catch (e) {
      debugPrint("❌ Erro ao sincronizar notificações: $e");
    }
  }
}