import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
  
  // --- DADOS COLETADOS ---
  final TextEditingController _nomeController = TextEditingController();
  DateTime? _dataNascimento;
  DateTime? _dataPrevistaParto; 
  String _sexo = ""; 
  String _alimentacao = ""; 
  bool _usarDPP = false; 

  final Set<String> _doresSono = {}; 
  final Set<String> _objetivosRotina = {}; 

  // --- OPÇÕES ---
  final List<Map<String, dynamic>> _opcoesAlimentacao = [
    {"label": "Leite Materno (Peito)", "icon": Icons.favorite, "color": Colors.pink},
    {"label": "Fórmula / Misto", "icon": Icons.local_drink, "color": Colors.orange},
    {"label": "Já come papinha (IA)", "icon": Icons.restaurant, "color": Colors.green},
  ];

  final List<Map<String, dynamic>> _opcoesSono = [
    {"label": "Acorda de hora em hora", "desc": "Despertares noturnos frequentes", "icon": Icons.access_time},
    {"label": "Só dorme no colo/peito", "desc": "Associação de sono forte", "icon": Icons.child_care},
    {"label": "Sonecas curtas (30min)", "desc": "Efeito vulcânico / não descansa", "icon": Icons.timer_off},
    {"label": "Briga com o sono", "desc": "Choro intenso para adormecer", "icon": Icons.warning_amber},
    {"label": "Troca o dia pela noite", "desc": "Ciclo circadiano invertido", "icon": Icons.nights_stay},
  ];

  final List<Map<String, dynamic>> _opcoesRotina = [
    {"label": "Organizar horários", "desc": "Saber a hora certa da soneca", "icon": Icons.schedule},
    {"label": "Lembrete de Remédios", "desc": "Nunca mais esquecer a dose", "icon": Icons.medication},
    {"label": "Histórico Médico", "desc": "Guardar vacinas e consultas", "icon": Icons.medical_services},
    {"label": "Catálogo de Atividades", "desc": "O que brincar nessa idade?", "icon": Icons.extension},
    {"label": "Diário de Mamadas", "desc": "Controlar peito/mamadeira", "icon": Icons.water_drop},
  ];

  // --- LÓGICA DE NAVEGAÇÃO ---

  void _proximaPagina() {
    if (_paginaAtual == 1 && _nomeController.text.trim().isEmpty) return;
    if (_paginaAtual == 2 && _sexo.isEmpty) return;
    
    if (_paginaAtual == 3) {
      if (_dataNascimento == null) return;
      if (_usarDPP && _dataPrevistaParto == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor, informe a Data Prevista.")));
        return;
      }
    }

    if (_paginaAtual == 4 && _alimentacao.isEmpty) return;
    if (_paginaAtual == 5 && _doresSono.isEmpty) return; 
    if (_paginaAtual == 6 && _objetivosRotina.isEmpty) return;

    if (_paginaAtual < 7) {
      _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuart);
    } else {
      _processarIA();
    }
  }

  Future<void> _processarIA() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _TelaAnaliseIA(),
    );

    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      Navigator.pop(context); 
      
      String dorPrincipal = _doresSono.isNotEmpty ? _doresSono.first : "Melhorar o Sono";

      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => TelaPaywall(
          nomeBebe: _nomeController.text.trim(),
          nascimentoBebe: _dataNascimento!,
          dataPrevista: _usarDPP ? _dataPrevistaParto : null, 
          sexo: _sexo,
          dorPrincipal: dorPrincipal,
        ),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ));
    }
  }

  Future<void> _selecionarData({required bool isNascimento}) async {
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime.now(), 
      firstDate: DateTime(2015), 
      lastDate: DateTime(2030), 
      helpText: isNascimento ? "DATA DE NASCIMENTO" : "DATA PREVISTA DO PARTO (DPP)",
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF6A9C89))), child: child!),
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
    double progresso = (_paginaAtual + 1) / 8;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  if (_paginaAtual > 0)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.grey),
                      onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease)
                    ),
                  if (_paginaAtual > 0) const SizedBox(width: 15),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progresso,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF6A9C89)),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _paginaAtual = p),
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

            _buildBotaoAcao(),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoAcao() {
    bool enable = true;
    if (_paginaAtual == 1 && _nomeController.text.isEmpty) enable = false;
    if (_paginaAtual == 2 && _sexo.isEmpty) enable = false;
    
    if (_paginaAtual == 3) {
      if (_dataNascimento == null) enable = false;
      if (_usarDPP && _dataPrevistaParto == null) enable = false;
    }

    if (_paginaAtual == 4 && _alimentacao.isEmpty) enable = false;
    if (_paginaAtual == 5 && _doresSono.isEmpty) enable = false;
    if (_paginaAtual == 6 && _objetivosRotina.isEmpty) enable = false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: enable ? _proximaPagina : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A9C89),
            disabledBackgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: enable ? 5 : 0,
          ),
          child: Text(
            _paginaAtual == 7 ? "GERAR MEU PLANO" : "CONTINUAR",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: enable ? Colors.white : Colors.grey.shade400, letterSpacing: 1),
          ),
        ),
      ),
    );
  }

  // --- PÁGINAS CORRIGIDAS (COM SINGLECHILDSCROLLVIEW) ---

  Widget _pagBoasVindas() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 250,
              child: Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_xyadoh9h.json',
                errorBuilder: (_,__,___) => const Icon(Icons.favorite, size: 100, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Bem-vindo ao Zelo", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A))),
            const SizedBox(height: 15),
            Text("O assistente completo que organiza o sono, a saúde e o desenvolvimento do seu bebê.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey.shade600, height: 1.5)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TelaLogin())
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF6A9C89), width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "JÁ TENHO UMA CONTA",
                  style: TextStyle(color: Color(0xFF6A9C89), fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pagNome() {
    return _buildInputPage("Como o bebê se chama?", "Vamos personalizar o app para...", 
      TextField(
        controller: _nomeController, 
        onChanged: (v) => setState((){}), 
        textAlign: TextAlign.center, 
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF6A9C89)), 
        decoration: InputDecoration(hintText: "Digite o nome", border: InputBorder.none, filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.all(20)), 
        textCapitalization: TextCapitalization.words
      )
    );
  }

  Widget _pagSexo() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("É menino ou menina?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: _cardSexo("Menino", "M", Icons.boy)),
                const SizedBox(width: 20),
                Expanded(child: _cardSexo("Menina", "F", Icons.girl)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _cardSexo(String label, String valor, IconData icon) {
    bool selecionado = _sexo == valor;
    return GestureDetector(
      onTap: () => setState(() => _sexo = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 150,
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFF6A9C89) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selecionado ? Colors.transparent : Colors.grey.shade200, width: 2),
          boxShadow: [if(!selecionado) BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: selecionado ? Colors.white : Colors.grey),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: selecionado ? Colors.white : Colors.grey.shade700))
          ],
        ),
      ),
    );
  }

  Widget _pagData() {
    // CORREÇÃO: Center + SingleChildScrollView evita overflow
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Data de Nascimento", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
            const SizedBox(height: 30),
            
            GestureDetector(
              onTap: () => _selecionarData(isNascimento: true),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _dataNascimento!=null ? const Color(0xFF6A9C89) : Colors.grey.shade300), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.calendar_month, color: _dataNascimento!=null ? const Color(0xFF6A9C89) : Colors.grey),
                  const SizedBox(width: 15),
                  Text(_dataNascimento==null ? "Selecionar Nascimento" : DateFormat('dd/MM/yyyy').format(_dataNascimento!), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _dataNascimento!=null ? const Color(0xFF6A9C89) : Colors.grey))
                ]),
              ),
            ),
            
            const SizedBox(height: 40),
            
            SwitchListTile(
              title: const Text("Informar Data Prevista do Parto?", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
              subtitle: const Text("Essencial para calcular os saltos de desenvolvimento com precisão exata.", style: TextStyle(color: Colors.grey)),
              value: _usarDPP,
              activeColor: const Color(0xFF6A9C89),
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  _usarDPP = val;
                  if (!val) _dataPrevistaParto = null;
                });
              },
            ),

            if (_usarDPP) ...[
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () => _selecionarData(isNascimento: false),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50, 
                    borderRadius: BorderRadius.circular(20), 
                    border: Border.all(color: _dataPrevistaParto!=null ? Colors.orange : Colors.orange.shade200)
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.event, color: Colors.orange.shade700),
                    const SizedBox(width: 15),
                    Text(
                      _dataPrevistaParto==null ? "Selecionar Data Prevista" : "DPP: ${DateFormat('dd/MM/yyyy').format(_dataPrevistaParto!)}", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange.shade800)
                    )
                  ]),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _pagAlimentacao() => _buildSelectionList("Como é a alimentação?", "Isso define os alertas de rotina.", _opcoesAlimentacao, _alimentacao, (v) => setState(() => _alimentacao = v));
  Widget _pagSono() => _buildMultiSelectionList("Quais os desafios de sono?", "Marque todas as opções que se aplicam.", _opcoesSono, _doresSono);
  Widget _pagRotina() => _buildMultiSelectionList("Como podemos te ajudar?", "Selecione as ferramentas que você quer usar.", _opcoesRotina, _objetivosRotina);

  Widget _pagFinal() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.verified, size: 90, color: Color(0xFF6A9C89)),
          const SizedBox(height: 30),
          const Text("Plano 100% Pronto!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
          const SizedBox(height: 20),
          Text("Consideramos a idade corrigida, a alimentação e selecionamos ${_objetivosRotina.length + 1} ferramentas para resolver o sono de ${_nomeController.text}.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey.shade600, height: 1.5)),
        ]),
      ),
    );
  }

  // --- TEMPLATES ATUALIZADOS ---
  
  Widget _buildInputPage(String t, String s, Widget w) {
    // CORREÇÃO: Center + SingleChildScrollView
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Text(t, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)), textAlign: TextAlign.center), 
            const SizedBox(height: 15), 
            Text(s, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)), 
            const SizedBox(height: 40), 
            w
          ]
        ),
      ),
    );
  }

  Widget _buildSelectionList(String t, String s, List<Map<String, dynamic>> opts, String val, Function(String) onSet) {
    return SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(children: [Text(t, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)), textAlign: TextAlign.center), const SizedBox(height: 10), Text(s, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)), const SizedBox(height: 30), ...opts.map((op) { bool sel = val == op['label']; return Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(onTap: () => onSet(op['label']), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: sel ? const Color(0xFF6A9C89).withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? const Color(0xFF6A9C89) : Colors.grey.shade200, width: 2)), child: Row(children: [Icon(op['icon'], color: sel ? const Color(0xFF6A9C89) : Colors.grey, size: 28), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(op['label'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sel ? const Color(0xFF6A9C89) : Colors.grey.shade800)), if (op.containsKey('desc')) Text(op['desc'], style: TextStyle(fontSize: 12, color: Colors.grey.shade500))])), if (sel) const Icon(Icons.radio_button_checked, color: Color(0xFF6A9C89)) else const Icon(Icons.radio_button_unchecked, color: Colors.grey)]))));}).toList()]));
  }

  Widget _buildMultiSelectionList(String t, String s, List<Map<String, dynamic>> opts, Set<String> selecionados) {
    return SingleChildScrollView(padding: const EdgeInsets.all(25), child: Column(children: [Text(t, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)), textAlign: TextAlign.center), const SizedBox(height: 10), Text(s, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey.shade600)), const SizedBox(height: 30), ...opts.map((op) { bool sel = selecionados.contains(op['label']); return Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(onTap: () => _toggleSelection(selecionados, op['label']), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: sel ? const Color(0xFF6A9C89).withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? const Color(0xFF6A9C89) : Colors.grey.shade200, width: 2)), child: Row(children: [Icon(op['icon'], color: sel ? const Color(0xFF6A9C89) : Colors.grey, size: 28), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(op['label'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: sel ? const Color(0xFF6A9C89) : Colors.grey.shade800)), if (op.containsKey('desc')) Text(op['desc'], style: TextStyle(fontSize: 12, color: Colors.grey.shade500))])), Icon(sel ? Icons.check_box : Icons.check_box_outline_blank, color: sel ? const Color(0xFF6A9C89) : Colors.grey)]))));}).toList()]));
  }
}

class _TelaAnaliseIA extends StatelessWidget {
  const _TelaAnaliseIA();
  @override
  Widget build(BuildContext context) {
    return Dialog(backgroundColor: Colors.transparent, elevation: 0, child: Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(color: Color(0xFF6A9C89)), const SizedBox(height: 25), const Text("Montando sua rotina...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const SizedBox(height: 10), Text("Selecionando ferramentas de saúde, sono e desenvolvimento.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600))])));
  }
}