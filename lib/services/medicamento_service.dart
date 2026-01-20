import 'package:cloud_firestore/cloud_firestore.dart';
import 'bebe_service.dart';
import 'notificacao_service.dart';

class MedicamentoService {
  
  // Adiciona um novo tratamento e agenda as notificações com IDs recuperáveis
  static Future<void> adicionarMedicamento({
    required String nome,
    required String dosagem,
    required int intervaloHoras,
    required int diasDuracao,
    required DateTime dataInicio,
    String imagemPath = "", 
  }) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) {
      print("Erro: Nenhum bebê ativo encontrado.");
      return;
    }

    try {
      // 1. Salva no Firebase primeiro para obter o ID único do documento
      DocumentReference docRef = await bebeRef.collection('medicamentos').add({
        'nome': nome,
        'dosagem': dosagem,
        'intervalo': intervaloHoras,
        'diasDuracao': diasDuracao,
        'inicio': dataInicio.toIso8601String(),
        'imagemPath': imagemPath, // Salva o caminho local
        'ativo': true, 
        'criado_em': FieldValue.serverTimestamp(),
      });

      // 2. Agenda Notificações usando o ID do documento como base
      // Isso é crucial para poder cancelar depois.
      await _agendarNotificacoes(
        docId: docRef.id,
        nome: nome,
        dosagem: dosagem,
        inicio: dataInicio,
        intervalo: intervaloHoras,
        dias: diasDuracao
      );

    } catch (e) {
      print("Erro ao salvar medicamento: $e");
      throw e; 
    }
  }

  // Lógica privada para agendar os alarmes
  static Future<void> _agendarNotificacoes({
    required String docId,
    required String nome,
    required String dosagem,
    required DateTime inicio,
    required int intervalo,
    required int dias,
  }) async {
    // Se for uso contínuo (-1), limitamos a 30 dias de agendamento por segurança
    int diasTotal = dias == -1 ? 30 : dias;
    
    DateTime dataAtual = inicio;
    DateTime dataFim = inicio.add(Duration(days: diasTotal));
    
    // O ID Base é o hash do ID do Firebase (transforma texto em número único)
    int idBase = docId.hashCode; 
    int count = 0;

    // Loop para criar os alarmes
    // Limitamos a 55 para não estourar o limite de alarmes do Android/iOS
    while (dataAtual.isBefore(dataFim) && count < 55) {
      
      // Só agenda se for no futuro
      if (dataAtual.isAfter(DateTime.now())) {
        await NotificacaoService.agendarNotificacao(
          id: idBase + count, // Cria IDs sequenciais: 12345, 12346, 12347...
          titulo: "Hora do Remédio: $nome 💊", 
          corpo: "Dose: $dosagem", 
          dataHora: dataAtual
        );
      }
      
      // Avança para o próximo horário
      dataAtual = dataAtual.add(Duration(hours: intervalo));
      count++;
    }
    print("Agendadas $count notificações para o remédio $nome (Base ID: $idBase)");
  }

  // Finaliza o tratamento (apenas atualiza o status no banco)
  // O cancelamento dos alarmes é feito na UI (AbaRemedios) chamando NotificacaoService.cancelarNotificacao
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