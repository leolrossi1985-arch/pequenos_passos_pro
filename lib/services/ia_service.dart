import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/dados_ia_especialista.dart';
import '../utils/calculadora_sono.dart';

import 'package:intl/intl.dart'; // Para formatar datas

class IAService {
  
  // ⚠️ TODO: Insira sua API Key do Google Gemini aqui para ativar a IA Generativa Real
  // Obtenha gratuitamente em: https://aistudio.google.com/app/apikey
  static const String _apiKey = 'AIzaSyAoMJpGqliILwyU5YNEsdakZPStS6lrVs8'; 

  static bool get isGeminiEnabled => _apiKey.isNotEmpty;

  // Variável para armazenar o chat ativo
  static ChatSession? _chatSession;
  static String? _currentModelName;

  /// Processa a mensagem usando Google Gemini (se disponível) ou Lógica Local (Fallback)
  static Future<String> processarMensagem(
    String mensagem, {
    int? mesesVida, 
    int? semanasVida,
    String? nomeBebe,
    DateTime? dataNascimento,
    DateTime? dpp,
  }) async {
    
    final meses = mesesVida ?? 0;
    final semanas = semanasVida ?? (meses * 4.3).round();
    final janela = CalculadoraSono.getJanelaVigiliaMinutos(meses);
    
    // Formata datas para string amigável
    final dateFormat = DateFormat('dd/MM/yyyy');
    final nascStr = dataNascimento != null ? dateFormat.format(dataNascimento) : "Não informada";
    final dppStr = dpp != null ? dateFormat.format(dpp) : "Não informada";
    final nomeStr = nomeBebe ?? "o bebê";
    final hojeStr = dateFormat.format(DateTime.now());

    // 1. Tenta usar o Gemini se a chave estiver configurada
    if (_apiKey.isNotEmpty) {
      
      // Lista de modelos para tentar (do mais novo/rápido para o mais compatível)
      final modelosParaTentar = [
        'gemini-2.0-flash', 
        'gemini-2.0-flash-001',
        'gemini-exp-1206', 
        'gemini-2.5-flash', 
        'gemini-flash-latest', 
        'gemini-1.5-flash',
        'gemini-pro',
      ];

      // Se já temos um modelo funcionando na sessão, tentamos ele primeiro
      if (_currentModelName != null) {
        modelosParaTentar.insert(0, _currentModelName!);
      }

      String? erroPrioritario;

      for (final nomeModelo in modelosParaTentar) {
        try {
          debugPrint('🔄 Tentando modelo: $nomeModelo ...');
          
          final model = GenerativeModel(
            model: nomeModelo, 
            apiKey: _apiKey,
            generationConfig: GenerationConfig(
              temperature: 0.7,
              maxOutputTokens: 500,
            ),
             safetySettings: [
                 SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
                 SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.none),
                 SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.none),
                 SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
             ],
             // System Instruction agora é suportado nativamente na v0.4.0+
             systemInstruction: Content.system('''
Você é uma Especialista em Desenvolvimento Infantil e Consultora de Sono Pediátrico.
Aja como uma aliada experiente e carinhosa dos pais.

DADOS VITAIS DO BEBÊ (CONSIDERE ISTO COMO VERDADE ABSOLUTA):
- Nome: $nomeStr
- Idade: $meses meses ($semanas semanas)
- Nascimento: $nascStr
- DPP (Parto Previsto): $dppStr
- Janela de vigília ideal: Aprox. $janela minutos.
- Data de Hoje: $hojeStr

DIRETRIZES:
1. Sempre que pertinente, use o nome "$nomeStr" para personalizar.
2. Se a idade for perguntada, calcule com base em $nascStr e hoje ($hojeStr).
3. Se perguntarem sobre saltos, use a DPP ($dppStr) para calcular a idade corrigida.
4. Responda de forma concisa e útil.
''')
          );

          // Inicializa o chat se não existir ou se mudou de modelo (reset simples para garantir consistência)
          if (_chatSession == null || _currentModelName != nomeModelo) {
             _chatSession = model.startChat(history: []);
             _currentModelName = nomeModelo;
          }

          // Injeta o contexto na mensagem para garantir que a IA saiba, mesmo em sessões longas
          String mensagemComContexto = """
[SISTEMA: Lembre-se dos dados atuais]
Bebê: $nomeStr | Idade: $meses m ($semanas sem) | Nasc: $nascStr | DPP: $dppStr
--------------------------------------------------
$mensagem""";

          final response = await _chatSession!.sendMessage(Content.text(mensagemComContexto));
          
          if (response.text != null && response.text!.isNotEmpty) {
            return response.text!;
          }
        } catch (e) {
          final erroStr = e.toString();
          debugPrint('⚠️ Falha no modelo $nomeModelo: $erroStr');
          
          // Se falhar, reseta a sessão para tentar recriar no próximo modelo
          _chatSession = null;
          
          // Se o erro for de Chave Expirada ou Inválida, não adianta tentar outros modelos.
          if (erroStr.contains("API key expired") || 
              erroStr.contains("API key not valid") || 
              erroStr.contains("User has exceeded quotas")) {
            erroPrioritario = erroStr;
            break; // Para o loop imediatamente
          }
          
          // Guarda o último erro caso nenhum modelo funcione, mas prioriza erros não-"Not Found"
          if (erroPrioritario == null || !erroStr.contains("not found")) {
            erroPrioritario = erroStr;
          }
        }
      }

      // Se saiu do loop, todos falharam. Analisa o erro para dar uma dica melhor.
      String mensagemAmigavel = "Verifique sua API Key no Google AI Studio.";
      
      if (erroPrioritario != null) {
        if (erroPrioritario.contains("not found")) {
          mensagemAmigavel = "O modelo não foi encontrado. Isso geralmente significa que a 'Generative Language API' não está ativada no seu projeto do Google Cloud.";
        } else if (erroPrioritario.contains("API key expired")) {
          mensagemAmigavel = "Sua chave de API expirou ou foi deletada.";
        } else if (erroPrioritario.contains("User has exceeded quotas")) {
          mensagemAmigavel = "Você excedeu a cota gratuita de uso da API.";
        }
      }

      return "ERRO DE CONEXÃO COM IA:\n\n$mensagemAmigavel\n\nDetalhe técnico: $erroPrioritario";

    } else {
      // Simula delay apenas se for local (para parecer que está pensando)
      await Future.delayed(const Duration(milliseconds: 600));
    }

    // 2. Fallback: Lógica Local (Regras)
    return _processarLocalmente(mensagem, meses, semanas);
  }

  static String _processarLocalmente(String mensagem, int meses, int semanas) {
    final msg = mensagem.toLowerCase();
    final horaAtual = DateTime.now().hour;

    // --- 1. INTENÇÃO: SONO ---
    if (_contem(msg, ['sono', 'dormir', 'soneca', 'acorda', 'madrugada', 'noite'])) {
      return DadosIAEspecialista.diagnosticarSono(meses, horaAtual);
    }

    // --- 2. INTENÇÃO: ALIMENTAÇÃO ---
    if (_contem(msg, ['fome', 'comer', 'mamada', 'leite', 'peito', 'papinha', 'comida'])) {
      return DadosIAEspecialista.diagnosticarFome(meses, semanas);
    }

    // --- 3. INTENÇÃO: COMPORTAMENTO / SALTO ---
    if (_contem(msg, ['choro', 'chorando', 'irritado', 'bravo', 'grudinho', 'colo'])) {
       // Se fala de choro, verifica primeiro se é Salto
       String respostaSalto = DadosIAEspecialista.diagnosticarComportamento(semanas);
       
       // Se for apenas choro genérico, manda o checklist
       if (msg.contains('choro') || msg.contains('chorando')) {
         return "$respostaSalto\n\n${DadosIAEspecialista.checklistChoro(meses)}";
       }
       return respostaSalto;
    }

    // --- 4. INTENÇÃO: SALTO ESPECÍFICO ---
    if (_contem(msg, ['salto', 'crise', 'desenvolvimento'])) {
      return DadosIAEspecialista.diagnosticarComportamento(semanas);
    }

    // --- 5. SAUDAÇÕES / AJUDA ---
    if (_contem(msg, ['ola', 'oi', 'ajuda', 'socorro', 'bom dia', 'boa tarde', 'boa noite'])) {
      if (isGeminiEnabled) {
        return "Olá! Estou operando em modo de segurança (Sem conexão com o Gemini).\n\n"
               "Ainda posso ajudar com o básico sobre o bebê de $meses meses:\n"
               "• Sono e Janelas\n"
               "• Alimentação\n"
               "• Saltos de Desenvolvimento";
      }
      return "Olá! Sou sua Especialista em Desenvolvimento Infantil (Modo Offline).\n\n"
             "Estou analisando os dados do seu bebê:\n"
             "• Idade: $meses meses ($semanas semanas)\n"
             "• Janela de Sono Ideal: ${CalculadoraSono.getJanelaVigiliaMinutos(meses)} min\n"
             "• Hora Atual: $horaAtual h\n\n"
             "Posso te ajudar a identificar se o choro é sono, fome ou um salto de desenvolvimento. O que está acontecendo agora?";
    }

    // --- DEFAULT ---
    if (isGeminiEnabled) {
         return "Não consegui conectar ao servidor de inteligência (Google Gemini).\n\n"
                "Verifique sua internet ou a API Key.\n\n"
                "Enquanto isso, tente palavras-chave simples como: 'sono', 'fome', 'salto'.";
    }

    return "Entendi. Como estou no modo offline (sem chave de IA configurada), meu entendimento é limitado a tópicos chave.\n\nTente usar palavras como 'sono', 'fome', 'choro' ou 'salto'. \n\nExemplo: 'Por que ele está chorando tanto?' ou 'Qual a janela de sono dele?'";
  }

  static bool _contem(String texto, List<String> palavras) {
    for (var p in palavras) {
      if (texto.contains(p)) return true;
    }
    return false;
  }
}
