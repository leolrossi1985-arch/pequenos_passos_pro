
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ia_service.dart';
import '../services/bebe_service.dart';

class TelaAssistente extends StatefulWidget {
  const TelaAssistente({super.key});

  @override
  State<TelaAssistente> createState() => _TelaAssistenteState();
}

class _TelaAssistenteState extends State<TelaAssistente> {
  // --- VARIÁVEIS DE ESTADO ---
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _mensagens = [];
  bool _isTyping = false;
  
  // Contexto do Bebê
  int? _mesesVida;
  String _nomeBebe = "Bebê";
  DateTime? _dataNascimento;
  DateTime? _dpp;

  @override
  void initState() {
    super.initState();
    _carregarDadosContexto();
    // Mensagem de boas-vindas "Humanizada"
    String saudacao = IAService.isGeminiEnabled
        ? "Olá! Sou a Assistente Inteligente (Powered by Gemini). 🧠\n\nPosso conversar sobre qualquer assunto relacionado ao seu bebê.\n\nComo posso ajudar?"
        : "Olá! Sou a Assistente do Zelo. 🤖\n\nSou uma Inteligência Local e 100% gratuita. Posso ajudar com dúvidas sobre sono, alimentação, saltos e desenvolvimento.\n\nComo posso ajudar hoje?";
    _adicionarMensagem(saudacao, false);
  }

  Future<void> _carregarDadosContexto() async {
    try {
      final dados = await BebeService.lerBebeAtivo();
      if (dados != null && mounted) {
        
        debugPrint("AUDITORIA IA - DADOS BRUTOS: $dados");

        // 1. DATA DE NASCIMENTO (Campo 'data_parto' no Firestore)
        DateTime nascimento;
        if (dados['data_parto'] != null) {
          if (dados['data_parto'] is Timestamp) {
            nascimento = (dados['data_parto'] as Timestamp).toDate();
          } else {
            nascimento = DateTime.parse(dados['data_parto']);
          }
        } else {
          // Fallback se algo muito estranho acontecer
          nascimento = DateTime.now(); 
        }
        _dataNascimento = nascimento;

        // 2. DPP (Campo 'data_prevista' no Firestore)
        if (dados['data_prevista'] != null) {
           if (dados['data_prevista'] is Timestamp) {
            _dpp = (dados['data_prevista'] as Timestamp).toDate();
          } else {
            _dpp = DateTime.parse(dados['data_prevista']);
          }
        } else {
          // Se não tiver DPP, assume que nasceu na DPP (ou usa nascimento)
          _dpp = nascimento;
        }
        
        final hoje = DateTime.now();
        
        setState(() {
          _mesesVida = hoje.difference(nascimento).inDays ~/ 30; // Usa nascimento real para idade cronológica
          _nomeBebe = dados['nome'] ?? "Bebê";
          
          debugPrint("AUDITORIA IA - CONTEXTO CARREGADO:");
          debugPrint("Nome: $_nomeBebe");
          debugPrint("Nascimento: $_dataNascimento");
          debugPrint("DPP: $_dpp");

          // Atualiza a mensagem inicial com o nome do bebê
          String saudacao = IAService.isGeminiEnabled
               ? "Olá! Sou a Assistente Inteligente. Estou pronta para ajudar você e o $_nomeBebe com todo o poder da IA do Google.\n\nPergunte o que quiser!"
               : "Olá! Sou a Assistente do Zelo. 🤖\n\nSou uma Inteligência Local e 100% gratuita. Estou aqui para ajudar você e o $_nomeBebe com dúvidas sobre sono, alimentação e desenvolvimento.\n\nComo posso ajudar hoje?";
          _mensagens[0]['texto'] = saudacao;
        });
      }
    } catch (e) {
      debugPrint("ERRO CRÍTICO AO CARREGAR CONTEXTO DO BEBÊ: $e");
    }
  }

  void _adicionarMensagem(String texto, bool isUser) {
    if (!mounted) return;
    setState(() {
      _mensagens.add({
        'texto': texto,
        'isUser': isUser,
        'time': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  void _enviarMensagem([String? textoPronto]) async {
    final texto = textoPronto ?? _controller.text.trim();
    if (texto.isEmpty) return;

    _controller.clear();
    _adicionarMensagem(texto, true);

    setState(() => _isTyping = true);
    _scrollToBottom();

    try {
      // Calcula semanas aproximadas para o serviço de IA
      int semanas = ((_mesesVida ?? 0) * 4.3).round();

      final resposta = await IAService.processarMensagem(
        texto, 
        mesesVida: _mesesVida,
        semanasVida: semanas,
        nomeBebe: _nomeBebe,
        dataNascimento: _dataNascimento,
        dpp: _dpp,
      );

      if (mounted) {
        setState(() => _isTyping = false);
        _adicionarMensagem(resposta, false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        _adicionarMensagem("Desculpe, tive um pequeno erro de processamento. Tente novamente.", false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate-50
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF0F172A), // Slate-900
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF), // Indigo-50
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.support_agent, color: Color(0xFF4F46E5), size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Assistente IA",
                  style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold), // Slate-900
                ),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      "Online",
                      style: TextStyle(color: Colors.green[700], fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1), // Slate-200
        ),
      ),
      body: Column(
        children: [
          // ÁREA DE CHAT
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: _mensagens.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _mensagens.length) {
                  return _buildTypingIndicator();
                }
                final msg = _mensagens[index];
                return _buildMessageBubble(msg['texto'], msg['isUser']);
              },
            ),
          ),
          
          // SUGESTÕES RÁPIDAS (Se o chat estiver curto ou vazio)
          if (_mensagens.length <= 2)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  _buildQuickChip("😴 Como está o sono?"),
                  _buildQuickChip("🍼 Fome ou Sede?"),
                  _buildQuickChip("🚀 Próximo salto"),
                  _buildQuickChip("😭 Por que chora?"),
                ],
              ),
            ),

          // INPUT AREA
          Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))), // Slate-200
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  offset: const Offset(0, -4),
                  blurRadius: 16,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9), // Slate-100
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)), // Slate-200
                    ),
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                      decoration: const InputDecoration(
                        hintText: "Pergunte sobre sono, alimentação...",
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14), // Slate-400
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _enviarMensagem(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _enviarMensagem(),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48, height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F46E5), // Indigo-600
                      shape: BoxShape.circle,
                      boxShadow: [
                         BoxShadow(
                           color: Color(0x404F46E5),
                           blurRadius: 8,
                           offset: Offset(0, 4)
                         )
                      ]
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        elevation: 1,
        labelStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
        onPressed: () => _enviarMensagem(label),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildMessageBubble(String texto, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.80),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF4F46E5) : Colors.white, // Indigo-600 vs White
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: isUser ? [
            const BoxShadow(color: Color(0x334F46E5), blurRadius: 8, offset: Offset(0, 4))
          ] : [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
          border: isUser ? null : Border.all(color: const Color(0xFFE2E8F0)), // Slate-200
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texto,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF334155), // Slate-700
                fontSize: 15,
                height: 1.5,
              ),
            ),
            if (!isUser) ...[
               const SizedBox(height: 6),
               const Text("IA Local", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(0),
            const SizedBox(width: 4),
            _dot(1),
            const SizedBox(width: 4),
            _dot(2),
          ],
        ),
      ),
    );
  }

  Widget _dot(int index) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFF94A3B8), // Slate-400
        shape: BoxShape.circle,
      ),
    );
  }
}
