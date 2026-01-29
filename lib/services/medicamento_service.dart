import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'bebe_service.dart';

class MedicamentoService {
  
  // Apenas SALVA no banco. O agendamento é feito pela UI ou SincronizacaoService.
  static Future<void> adicionarMedicamento({
    required String nome,
    required String dosagem,
    required int intervaloHoras,
    required int diasDuracao,
    required DateTime dataInicio,
    required String imagemPath,
    required int idNotificacao, // <--- NOVO: Recebe o ID gerado na tela
  }) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) {
      debugPrint("Erro: Nenhum bebê ativo encontrado.");
      return;
    }

    try {
      // Calcula data fim (ou null se for contínuo)
      String? dataFimIso;
      if (diasDuracao > 0) {
         dataFimIso = dataInicio.add(Duration(days: diasDuracao)).toIso8601String();
      }

      // Salva no Firebase com todos os dados necessários para o Sincronizador
      await bebeRef.collection('medicamentos').add({
        'nome': nome, // Para compatibilidade visual
        'nome_medicamento': nome, // Para o SincronizacaoService ler
        'dosagem': dosagem,
        
        // Dados de tempo cruciais
        'intervalo': intervaloHoras, 
        'frequencia_horas': intervaloHoras, // Para o SincronizacaoService
        'diasDuracao': diasDuracao,
        
        // Datas
        'inicio': dataInicio.toIso8601String(),
        'data_inicio': dataInicio.toIso8601String(), // Para o SincronizacaoService
        'data_fim': dataFimIso, 
        
        // Controle
        'imagemPath': imagemPath,
        'id_notificacao': idNotificacao, // <--- Salva o ID base aqui!
        'ativo': true, 
        'uso_continuo': diasDuracao == -1,
        'criado_em': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Medicamento salvo no banco com ID Notificação: $idNotificacao");

    } catch (e) {
      debugPrint("Erro ao salvar medicamento: $e");
      rethrow; 
    }
  }

  // Finaliza o tratamento (apenas atualiza o status no banco)
  static Future<void> finalizarMedicamento(String id) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;
    await bebeRef.collection('medicamentos').doc(id).update({'ativo': false});
  }

  // Apaga do banco de dados
  static Future<void> deletarMedicamento(String id) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;
    await bebeRef.collection('medicamentos').doc(id).delete();
  }
}