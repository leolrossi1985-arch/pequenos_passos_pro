import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  // Substitua pela sua chave se necessário, ou use a que está no código
  const apiKey = 'AIzaSyAoMJpGqliILwyU5YNEsdakZPStS6lrVs8';

  test('Diagnostico Gemini API', () async {
    print('\n==========================================');
    print('   INICIANDO DIAGNÓSTICO DE CONEXÃO IA    ');
    print('==========================================\n');

    if (apiKey.isEmpty) {
      print('❌ ERRO: API Key não configurada.');
      return;
    }

    print('🔑 Chave em uso: ${apiKey.substring(0, 10)}...');

    // Lista de modelos para testar individualmente
    final modelos = [
    'gemini-2.0-flash',
    'gemini-exp-1206',
    'gemini-2.5-flash',
  ];bool algumFuncionou = false;

    for (final nomeModelo in modelos) {
      print('\n------------------------------------------');
      print('🔄 Testando modelo: $nomeModelo');
      
      try {
        final model = GenerativeModel(
          model: nomeModelo,
          apiKey: apiKey,
        );

        final response = await model.generateContent([
          Content.text('Responda apenas "OK" se estiver me ouvindo.')
        ]);

        if (response.text != null) {
          print('✅ SUCESSO! Resposta recebida: "${response.text?.trim()}"');
          algumFuncionou = true;
          break; // Se um funcionou, ótimo!
        }
      } catch (e) {
        print('❌ FALHA: $e');
        
        // Análise básica do erro
        final erro = e.toString();
        if (erro.contains('API key expired')) {
          print('👉 DIAGNÓSTICO: Chave Expirada. O projeto no Google Cloud pode ter sido deletado.');
        } else if (erro.contains('not found')) {
          print('👉 DIAGNÓSTICO: Modelo não encontrado. Pode faltar ativar a "Generative Language API" no Google Cloud.');
        } else if (erro.contains('IAM')) {
          print('👉 DIAGNÓSTICO: Erro de Permissão. Verifique as restrições da chave.');
        }
      }
    }

    print('\n==========================================');
    if (algumFuncionou) {
      print('✅ DIAGNÓSTICO FINAL: Conexão estabelecida com sucesso!');
    } else {
      print('❌ DIAGNÓSTICO FINAL: Nenhuma conexão funcionou.');
    }
    print('==========================================\n');
  });
}
