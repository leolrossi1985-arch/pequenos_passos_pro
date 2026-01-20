import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'bebe_service.dart';

class ResumoService {
  
  // Incrementa (ou decrementa) um contador em uma DATA ESPECÍFICA
  static Future<void> atualizarContador({
    required String campo, 
    required int valor, 
    required DateTime dataEvento // <--- FUNDAMENTAL
  }) async {
    try {
      final ref = await BebeService.getRefBebeAtivo();
      if (ref == null) return;

      // O ID do documento será a data (ex: "2023-10-27")
      // Isso garante que o gráfico saiba exatamente onde plotar
      final String dataId = DateFormat('yyyy-MM-dd').format(dataEvento);
      final docResumo = ref.collection('resumos').doc(dataId);

      await docResumo.set({
        campo: FieldValue.increment(valor),
        'data_ref': dataEvento, // Guarda a data real para ordenação se precisar
        'last_update': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
      
      print(">>> Contador '$campo' atualizado em $valor no dia $dataId");
    } catch (e) {
      print("!!! Erro ResumoService: $e");
    }
  }

  // Atalho para Nutrição
  static Future<void> atualizarNutricao(String categoria, DateTime data) async {
    String campo = "nutri_outros";
    if (categoria.contains('Fruta')) campo = "nutri_frutas";
    else if (categoria.contains('Legume')) campo = "nutri_legumes";
    else if (categoria.contains('Proteína')) campo = "nutri_proteina";
    await atualizarContador(campo: campo, valor: 1, dataEvento: data);
  }

  // Atalho para Sono (Sonecas + Minutos)
  static Future<void> atualizarSono({required int minutos, required DateTime data}) async {
    // Incrementa contagem de sonecas
    await atualizarContador(campo: 'sonecas', valor: 1, dataEvento: data);
    // Soma os minutos
    await atualizarContador(campo: 'sono_minutos', valor: minutos, dataEvento: data);
  }
}