import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback (vibração)
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:async'; 
import 'package:google_fonts/google_fonts.dart';

// Seus imports de telas
import 'tela_paywall.dart';
import 'tela_login.dart';

class TelaOnboarding extends StatefulWidget {
  const TelaOnboarding({super.key});

  @override
  State<TelaOnboarding> createState() => _TelaOnboardingState();
}

class _TelaOnboardingState extends State<TelaOnboarding> {
  final PageController _pageController = PageController();
  int _paginaAtual = 0;
  
  // --- CORES & ESTILO (Design System) ---
  final Color _corPrimaria = const Color(0xFF6A9C89);
  final Color _corFundo = const Color(0xFFFAFAFA); 
  final Color _corTexto = const Color(0xFF2D3A3A);
  
  // --- DADOS DO BEBÊ ---
  final TextEditingController _nomeController = TextEditingController();
  DateTime? _dataNascimento;
  DateTime? _dataPrevistaParto; 
  String _sexo = ""; 
  String _alimentacao = ""; 
  bool _usarDPP = false; 
  
  final Set<String> _doresSono = {}; 
  final Set<String> _objetivosRotina = {}; 

  // --- OPÇÕES DE CONTEÚDO ---
  final List<Map<String, dynamic>> _opcoesAlimentacao = [
    {"label": "Leite Materno", "sub": "Aleitamento exclusivo/predominante", "icon": Icons.favorite_rounded, "color": Colors.pinkAccent},
    {"label": "Fórmula / Misto", "sub": "Complemento ou exclusivo", "icon": Icons.local_drink_rounded, "color": Colors.orangeAccent},
    {"label": "Introdução Alimentar", "sub": "Já iniciou papinhas/BLW", "icon": Icons.restaurant_rounded, "color": Colors.green},
  ];

  final List<Map<String, dynamic>> _opcoesSono = [
    {"label": "Despertares frequentes", "desc": "Acorda de hora em hora", "icon": Icons.access_time_rounded},
    {"label": "Associação de sono", "desc": "Só dorme no colo ou peito", "icon": Icons.child_care_rounded},
    {"label": "Sonecas curtas", "desc": "Efeito vulcânico (menos de 30min)", "icon": Icons.timer_off_rounded},
    {"label": "Luta contra o sono", "desc": "Choro intenso para adormecer", "icon": Icons.warning_amber_rounded},
    {"label": "Dia pela noite", "desc": "Madrugadas em claro", "icon": Icons.nights_stay_rounded},
  ];

  // --- MELHORIA: Textos de Venda Mais Completos ---
  final List<Map<String, dynamic>> _opcoesRotina = [
    {"label": "Rotina Completa", "desc": "Gerenciar sono, mamadas, fraldas e banhos", "icon": Icons.schedule_rounded},
    {"label": "Saúde & Histórico", "desc": "Vacinas, remédios, sintomas e PDF para o médico", "icon": Icons.medical_services_rounded},
    {"label": "Desenvolvimento", "desc": "Acompanhar marcos, saltos e dentição", "icon": Icons.trending_up_rounded},
    {"label": "Ferramentas Extras", "desc": "Ruído branco, cursos e dicas diárias", "icon": Icons.extension_rounded},
  ];

  // --- LÓGICA DE NAVEGAÇÃO ---

  void _proximaPagina() {
    HapticFeedback.lightImpact(); // Feedback tátil leve

    // Validações por página
    if (_paginaAtual == 1 && _nomeController.text.trim().isEmpty) {
      return _shakeErro("Como o bebê se chama?");
    }
    
    if (_paginaAtual == 2 && _sexo.isEmpty) {
      return _shakeErro("Selecione o sexo do bebê.");
    }
    
    if (_paginaAtual == 3) {
      if (_dataNascimento == null) return _shakeErro("Informe a data de nascimento.");
      if (_usarDPP && _dataPrevistaParto == null) {
        return _shakeErro("Informe a Data Prevista (DPP).");
      }
    }

    if (_paginaAtual == 4 && _alimentacao.isEmpty) {
      return _shakeErro("Selecione o tipo de alimentação.");
    }
    
    if (_paginaAtual == 5 && _doresSono.isEmpty) {
      return _shakeErro("Selecione pelo menos um desafio.");
    } 
    
    if (_paginaAtual == 6 && _objetivosRotina.isEmpty) {
      return _shakeErro("Selecione seus objetivos.");
    }

    // Se passou na validação, avança
    if (_paginaAtual < 7) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600), 
        curve: Curves.easeOutQuart
      );
    } else {
      // Última página: Processa e vai para Paywall
      _processarIA();
    }
  }

  void _shakeErro(String mensagem) {
    HapticFeedback.heavyImpact(); // Vibração de erro
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove anteriores
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensagem, style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white)), 
      backgroundColor: Colors.red.shade400,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _processarIA() async {
    // Abre o Dialog de "Processamento"
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _TelaAnaliseIADinamica(),
    );

    // Simula tempo de processamento (para valorizar o produto)
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      Navigator.pop(context); // Fecha o dialog

      // Define a dor principal (fallback seguro)
      String dorPrincipal = "Organizar a Rotina";
      if (_doresSono.isNotEmpty) {
        dorPrincipal = _doresSono.first;
      }

      // Vai para o Paywall
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => TelaPaywall(
            nomeBebe: _nomeController.text.trim(),
            nascimentoBebe: _dataNascimento!,
            dataPrevista: _usarDPP ? _dataPrevistaParto : null, 
            sexo: _sexo,
            dorPrincipal: dorPrincipal,
          ),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
        (route) => false, // Limpa o histórico
      );
    }
  }

  Future<void> _selecionarData({required bool isNascimento}) async {
    HapticFeedback.selectionClick();
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime(2018), 
      lastDate: DateTime(2030), 
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: _corPrimaria, onPrimary: Colors.white, surface: Colors.white, onSurface: _corTexto),
          textTheme: GoogleFonts.nunitoTextTheme(), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
        ), 
        child: child!
      ),
    );
    
    if (picked != null) {
      setState(() {
        if (isNascimento) {
          _dataNascimento = picked;
        } else {
          _dataPrevistaParto = picked;
        }
      });
    }
  }

  void _toggleSelection(Set<String> conjunto, String valor) {
    HapticFeedback.selectionClick();
    setState(() {
      if (conjunto.contains(valor)) {
        conjunto.remove(valor);
      } else {
        conjunto.add(valor);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cálculo do progresso (0.0 a 1.0)
    double progresso = (_paginaAtual + 1) / 8;

    return Scaffold(
      backgroundColor: _corFundo,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Barra de Progresso) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  if (_paginaAtual > 0)
                    GestureDetector(
                      onTap: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.grey),
                      ),
                    )
                  else
                    const SizedBox(width: 40), // Espaço para manter alinhamento
                  
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progresso,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(_corPrimaria),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Indicador numérico (ex: 1/8)
                  Text("${_paginaAtual + 1}/8", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
            ),

            // --- CORPO (PAGE VIEW) ---
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Impede deslizar com o dedo (obriga usar botão)
                // CORREÇÃO DO PROGRESSO: Atualiza o estado quando a página muda
                onPageChanged: (pagina) {
                  setState(() {
                    _paginaAtual = pagina;
                  });
                },
                children: [
                  _pagBoasVindas(),
                  _pagNome(),
                  _pagSexo(),
                  _pagData(),
                  _pagAlimentacao(),
                  _pagSono(),
                  _pagRotina(),
                  _pagFinal(),
                ],
              ),
            ),

            // --- RODAPÉ (BOTÃO) ---
            _buildBotaoAcao(),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO DE PÁGINA ---

  Widget _buildBotaoAcao() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Sombra bonita apenas no botão
          boxShadow: [BoxShadow(color: _corPrimaria.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: ElevatedButton(
          // CORREÇÃO: Botão sempre ativo para dar feedback de erro se necessário
          onPressed: _proximaPagina,
          style: ElevatedButton.styleFrom(
            backgroundColor: _corPrimaria,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Text(
            _paginaAtual == 7 ? "GERAR MEU PLANO" : "CONTINUAR",
            style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  // 1. BOAS VINDAS
  Widget _pagBoasVindas() {
    return _animacaoEntrada(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.teal.shade50, Colors.white], radius: 0.7),
                ),
                child: Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_xyadoh9h.json',
                  errorBuilder: (_,__,___) => Icon(Icons.favorite, size: 100, color: _corPrimaria),
                ),
              ),
              const SizedBox(height: 20),
              Text("Bem-vindo ao Zelo", style: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.w600, color: _corTexto, letterSpacing: -0.5), textAlign: TextAlign.center),
              const SizedBox(height: 15),
              Text("O assistente inteligente que organiza o sono, a saúde e o desenvolvimento do seu bebê.", textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey.shade600, height: 1.5)),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TelaLogin())),
                child: Text("Já tenho uma conta", style: GoogleFonts.nunito(color: _corPrimaria, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. NOME
  Widget _pagNome() {
    return _animacaoEntrada(
      child: _buildInputPage(
        "Como o bebê se chama?", 
        "Vamos criar um plano personalizado para...", 
        TextField(
          controller: _nomeController, 
          onChanged: (v) => setState((){}), 
          textAlign: TextAlign.center, 
          style: GoogleFonts.fredoka(fontSize: 32, fontWeight: FontWeight.w500, color: _corPrimaria), 
          decoration: InputDecoration(
            hintText: "Digite o nome aqui", 
            hintStyle: GoogleFonts.nunito(color: Colors.grey.shade300),
            border: InputBorder.none, 
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _corPrimaria, width: 2)),
            contentPadding: const EdgeInsets.all(20)
          ), 
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        )
      )
    );
  }

  // 3. SEXO
  Widget _pagSexo() {
    return _animacaoEntrada(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("É menino ou menina?", style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w500, color: _corTexto)),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: _cardSexo("Menino", "M", Icons.boy_rounded, Colors.blue)),
                const SizedBox(width: 20),
                Expanded(child: _cardSexo("Menina", "F", Icons.girl_rounded, Colors.pink)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _cardSexo(String label, String valor, IconData icon, Color corIcon) {
    bool selecionado = _sexo == valor;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _sexo = valor);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 160,
        decoration: BoxDecoration(
          color: selecionado ? corIcon.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selecionado ? corIcon : Colors.grey.shade200, width: selecionado ? 2 : 1),
          boxShadow: [if(!selecionado) BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: selecionado ? corIcon : Colors.grey.shade50, shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: selecionado ? Colors.white : Colors.grey.shade400),
            ),
            const SizedBox(height: 15),
            Text(label, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: selecionado ? corIcon : Colors.grey.shade600))
          ],
        ),
      ),
    );
  }

  // 4. DATA (CORRIGIDA)
  Widget _pagData() {
    return _animacaoEntrada(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Quando ${_nomeController.text} nasceu?", textAlign: TextAlign.center, style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w500, color: _corTexto)),
            const SizedBox(height: 40),
            
            _buildDateSelector(
              label: "Data de Nascimento",
              date: _dataNascimento,
              onTap: () => _selecionarData(isNascimento: true),
              primary: true
            ),
            
            const SizedBox(height: 40),
            
            // LÓGICA ATUALIZADA: Pergunta se quer usar DPP, não se é prematuro.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: SwitchListTile(
                title: Text("Definir Data Prevista (DPP)?", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: _corTexto, fontSize: 16)),
                subtitle: Text("Importante para calcular os saltos de desenvolvimento corretamente.", style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey)),
                value: _usarDPP,
                activeThumbColor: _corPrimaria,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _usarDPP = val;
                    if (!val) _dataPrevistaParto = null;
                  });
                },
              ),
            ),

            if (_usarDPP) ...[
              const SizedBox(height: 20),
              _buildDateSelector(
                label: "Data Prevista do Parto (DPP)",
                date: _dataPrevistaParto,
                onTap: () => _selecionarData(isNascimento: false),
                primary: false
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({required String label, required DateTime? date, required VoidCallback onTap, required bool primary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: date != null ? (primary ? _corPrimaria.withOpacity(0.1) : Colors.orange.withOpacity(0.1)) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: date != null ? (primary ? _corPrimaria : Colors.orange) : Colors.grey.shade300, width: date != null ? 2 : 1),
          boxShadow: [if(date==null) BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,5))]
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.calendar_today_rounded, color: date != null ? (primary ? _corPrimaria : Colors.orange) : Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.bold, color: date!=null ? (primary ? _corPrimaria : Colors.orange) : Colors.grey)),
              Text(date == null ? "Toque para selecionar" : DateFormat('dd/MM/yyyy').format(date), style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: date!=null ? Colors.black87 : Colors.grey)),
            ],
          )
        ]),
      ),
    );
  }

  // 5. ALIMENTAÇÃO
  Widget _pagAlimentacao() => _animacaoEntrada(
    child: _buildSelectionList(
      "Como é a alimentação?", 
      "Personalizamos os alertas de rotina com base nisso.", 
      _opcoesAlimentacao, 
      _alimentacao, 
      (v) {
        HapticFeedback.selectionClick();
        setState(() => _alimentacao = v);
      }
    )
  );

  // 6. SONO
  Widget _pagSono() => _animacaoEntrada(
    child: _buildMultiSelectionList(
      "O que mais te preocupa no sono?", 
      "Selecione todas as opções que se aplicam.", 
      _opcoesSono, 
      _doresSono
    )
  );

  // 7. ROTINA
  Widget _pagRotina() => _animacaoEntrada(
    child: _buildMultiSelectionList(
      "Qual seu objetivo principal?", 
      "Vamos montar a caixa de ferramentas ideal.", 
      _opcoesRotina, 
      _objetivosRotina
    )
  );

  // 8. FINAL (MELHORADA)
  Widget _pagFinal() {
    return _animacaoEntrada(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: _corPrimaria.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.verified_rounded, size: 80, color: _corPrimaria),
            ),
            const SizedBox(height: 30),
            Text("Plano 100% Pronto!", style: GoogleFonts.fredoka(fontSize: 30, fontWeight: FontWeight.w600, color: const Color(0xFF2D3A3A))),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey.shade600, height: 1.5),
                children: [
                  const TextSpan(text: "Analisamos a idade de "),
                  TextSpan(text: _nomeController.text, style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: _corTexto)),
                  const TextSpan(text: " e criamos a rotina ideal para organizar o "),
                  // --- TEXTO FINAL VENDEDOR ---
                  TextSpan(text: "sono, saúde e desenvolvimento", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  const TextSpan(text: " com base no que você precisa."),
                ]
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // --- TEMPLATES REUTILIZÁVEIS ---

  Widget _animacaoEntrada({required Widget child}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      builder: (context, double val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(offset: Offset(0, 20 * (1 - val)), child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildInputPage(String t, String s, Widget w) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Text(t, style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.w500, color: _corTexto), textAlign: TextAlign.center), 
            const SizedBox(height: 15), 
            Text(s, textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey.shade500)), 
            const SizedBox(height: 40), 
            w
          ]
        ),
      ),
    );
  }

  Widget _buildSelectionList(String t, String s, List<Map<String, dynamic>> opts, String val, Function(String) onSet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25), 
      child: Column(
        children: [
          Text(t, style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w500, color: _corTexto), textAlign: TextAlign.center), 
          const SizedBox(height: 10), 
          Text(s, textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600)), 
          const SizedBox(height: 30), 
          ...opts.map((op) { 
            bool sel = val == op['label']; 
            return Padding(
              padding: const EdgeInsets.only(bottom: 15), 
              child: GestureDetector(
                onTap: () => onSet(op['label']), 
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200), 
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
                  decoration: BoxDecoration(
                    color: sel ? op['color'].withOpacity(0.1) : Colors.white, 
                    borderRadius: BorderRadius.circular(20), 
                    border: Border.all(color: sel ? op['color'] : Colors.grey.shade200, width: 2),
                    boxShadow: [if(!sel) BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))]
                  ), 
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: sel ? op['color'] : Colors.grey.shade100, shape: BoxShape.circle),
                      child: Icon(op['icon'], color: sel ? Colors.white : Colors.grey, size: 24)
                    ),
                    const SizedBox(width: 15), 
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(op['label'], style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: sel ? Colors.black87 : Colors.grey.shade800)), 
                      if (op.containsKey('sub')) Text(op['sub'], style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade500))
                    ])), 
                    if (sel) Icon(Icons.check_circle, color: op['color'])
                  ])
                )
              )
            );
          })
        ]
      )
    );
  }

  Widget _buildMultiSelectionList(String t, String s, List<Map<String, dynamic>> opts, Set<String> selecionados) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25), 
      child: Column(
        children: [
          Text(t, style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w500, color: _corTexto), textAlign: TextAlign.center), 
          const SizedBox(height: 10), 
          Text(s, textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade600)), 
          const SizedBox(height: 30), 
          ...opts.map((op) { 
            bool sel = selecionados.contains(op['label']); 
            return Padding(
              padding: const EdgeInsets.only(bottom: 12), 
              child: GestureDetector(
                onTap: () => _toggleSelection(selecionados, op['label']), 
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200), 
                  padding: const EdgeInsets.all(16), 
                  decoration: BoxDecoration(
                    color: sel ? _corPrimaria.withOpacity(0.08) : Colors.white, 
                    borderRadius: BorderRadius.circular(16), 
                    border: Border.all(color: sel ? _corPrimaria : Colors.grey.shade200, width: 2),
                    boxShadow: [if(!sel) BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))]
                  ), 
                  child: Row(children: [
                    Icon(op['icon'], color: sel ? _corPrimaria : Colors.grey, size: 28), 
                    const SizedBox(width: 15), 
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(op['label'], style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: sel ? _corPrimaria : Colors.grey.shade800)), 
                      if (op.containsKey('desc')) Text(op['desc'], style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade500))
                    ])), 
                    Icon(sel ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: sel ? _corPrimaria : Colors.grey.shade400)
                  ])
                )
              )
            );
          })
        ]
      )
    );
  }
}

// --- TELA DE ANÁLISE "IA" (AGORA DINÂMICA) ---
class _TelaAnaliseIADinamica extends StatefulWidget {
  const _TelaAnaliseIADinamica();

  @override
  State<_TelaAnaliseIADinamica> createState() => _TelaAnaliseIADinamicaState();
}

class _TelaAnaliseIADinamicaState extends State<_TelaAnaliseIADinamica> {
  final List<String> _mensagens = [
    "Conectando à base de dados...",
    "Analisando padrões de sono...",
    "Calculando saltos de desenvolvimento...",
    "Verificando janelas de vigília...",
    "Gerando plano personalizado..."
  ];
  int _indexMsg = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (_indexMsg < _mensagens.length - 1) {
        setState(() => _indexMsg++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const SizedBox(
              height: 60, width: 60,
              child: CircularProgressIndicator(color: Color(0xFF6A9C89), strokeWidth: 5),
            ),
            const SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _mensagens[_indexMsg],
                key: ValueKey<int>(_indexMsg),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2D3A3A)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${((_indexMsg + 1) / _mensagens.length * 100).toInt()}%", 
              style: GoogleFonts.nunito(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 12)
            )
          ],
        ),
      ),
    );
  }
}