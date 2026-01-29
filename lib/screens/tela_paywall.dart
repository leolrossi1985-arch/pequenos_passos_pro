import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import necessário para tratar Timestamp
import '../services/revenue_cat_service.dart';
import '../services/bebe_service.dart'; // Para ler dados no modo bloqueio
import 'tela_registro.dart'; 
import 'tela_login.dart';
import 'tela_base.dart'; // Import necessário para ir para a Home

class TelaPaywall extends StatefulWidget {
  final String nomeBebe;
  final DateTime nascimentoBebe;
  final DateTime? dataPrevista;
  final String sexo;
  final String dorPrincipal;
  
  // NOVO: Define se é modo "Bloqueio" (usuário antigo) ou "Cadastro" (novo)
  final bool isBloqueio; 

  const TelaPaywall({
    super.key,
    required this.nomeBebe,
    required this.nascimentoBebe,
    this.dataPrevista,
    required this.sexo,
    required this.dorPrincipal,
    this.isBloqueio = false, // Padrão é false (fluxo de cadastro)
  });

  @override
  State<TelaPaywall> createState() => _TelaPaywallState();
}

class _TelaPaywallState extends State<TelaPaywall> {
  bool _isLoading = false;
  
  // Variáveis de Planos
  List<Package> _packages = [];
  Package? _selectedPackage; // O plano que o usuário clicou

  // Cores Premium Dark & Gold
  final Color _corFundoDark = const Color(0xFF051810); // Verde Quase Preto
  final Color _corCard = const Color(0xFF0F2E20);
  final Color _corDourada = const Color(0xFFFFD700);
  final Color _corPrimaria = const Color(0xFF00C853);

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _buscarOfertas();
    }
  }

  Future<void> _buscarOfertas() async {
    try {
      var offering = await RevenueCatService.buscarOfertas();
      
      if (offering != null && offering.availablePackages.isNotEmpty) {
        if (mounted) {
          setState(() {
            _packages = offering.availablePackages;
            
            // Tenta selecionar o ANUAL por padrão
            _selectedPackage = _packages.firstWhere(
              (p) => p.packageType == PackageType.annual, 
              orElse: () => _packages.first
            );
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar ofertas: $e");
    }
  }

  Future<void> _realizarCompra() async {
    if (_selectedPackage == null) return;

    setState(() => _isLoading = true);
    bool sucesso = false;

    if (kIsWeb || kDebugMode) {
      await Future.delayed(const Duration(seconds: 2));
      sucesso = true; 
    } else {
      try {
        CustomerInfo customerInfo = await Purchases.purchasePackage(_selectedPackage!);
        sucesso = customerInfo.entitlements.all["pro"]?.isActive ?? false; 
      } catch (e) {
        sucesso = false;
      }
    }

    if (mounted) setState(() => _isLoading = false);

    if (sucesso) {
      _avancarAposCompra();
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A compra não foi concluída.")));
    }
  }

  void _irParaLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TelaLogin()));
  }

  // Lógica inteligente de navegação pós-compra
  void _avancarAposCompra() {
    // SE FOR MODO BLOQUEIO (Usuário antigo que perdeu acesso) -> Vai direto pra Home
    if (widget.isBloqueio) {
       Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const TelaBase()),
        (route) => false
      );
    } 
    // SE FOR MODO CADASTRO (Usuário novo) -> Continua o fluxo de onboarding
    else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => TelaRegistro(
            nomeBebe: widget.nomeBebe, 
            nascimentoBebe: widget.nascimentoBebe,
            dataPrevista: widget.dataPrevista, 
            sexo: widget.sexo
          )
        ),
        (route) => false
      );
    }
  }

  Future<void> _restaurar() async {
    setState(() => _isLoading = true);
    bool sucesso = await RevenueCatService.restaurarCompras();
    if (mounted) setState(() => _isLoading = false);
    
    if (sucesso) {
      _avancarAposCompra(); // Reusa a lógica inteligente
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nenhuma assinatura encontrada.")));
    }
  }

  Future<void> _abrirLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) throw 'Erro';
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    // Texto Dinâmico da Meta
    String textoMeta = "Transformar o Caos em Rotina";
    String textoSubMeta = "Saber exatamente o que fazer o dia todo.";
    
    if (widget.dorPrincipal.toLowerCase().contains("sono")) {
      textoMeta = "Noites Inteiras de Sono";
      textoSubMeta = "O fim das madrugadas em claro.";
    } else if (widget.dorPrincipal.toLowerCase().contains("dia pela noite")) {
      textoMeta = "Regular o Relógio Biológico";
      textoSubMeta = "Ensinar o bebê que a noite é para dormir.";
    }

    return Scaffold(
      backgroundColor: _corFundoDark,
      body: Stack(
        children: [
          // Fundo Texturizado
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.network("https://images.unsplash.com/photo-1615486511484-92e5724d1bd2?q=80&w=1000&auto=format&fit=crop", fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: _corFundoDark)),
            ),
          ),
          
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Column(
                  children: [
                    // Botão Fechar (Só aparece se for fluxo de cadastro, no bloqueio é obrigatório pagar)
                    if (!widget.isBloqueio)
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(onPressed: _avancarAposCompra, icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.5), size: 30)),
                      )
                    else 
                      const SizedBox(height: 40), // Espaço se não tiver botão fechar

                    // Título Personalizado
                    Text(
                      "Plano Personalizado para\n${widget.nomeBebe}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2),
                    ),

                    const SizedBox(height: 25),

                    // --- META & TRANSFORMAÇÃO ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [_corCard, _corCard.withOpacity(0.5)]),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))]
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flag_rounded, color: Color(0xFFA5D6A7)),
                              const SizedBox(width: 8),
                              Text("SUA META PRINCIPAL", style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFFA5D6A7), letterSpacing: 1.5)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(textoMeta, textAlign: TextAlign.center, style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white)),
                          const SizedBox(height: 5),
                          Text(textoSubMeta, textAlign: TextAlign.center, style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- DESCRIÇÃO DE VALOR ---
                    Column(
                      children: [
                        _buildBenefitItem(Icons.verified_user_rounded, "Cronograma Diário Inteligente", "Saiba a hora exata da soneca, banho e comida."),
                        _buildBenefitItem(Icons.bar_chart_rounded, "Previsão de Saltos e Crises", "Entenda o choro antes dele acontecer."),
                        _buildBenefitItem(Icons.medical_services_rounded, "Controle Total de Saúde", "Vacinas, sintomas, dentes e relatórios PDF."),
                        _buildBenefitItem(Icons.school_rounded, "Cursos Rápidos & Práticos", "Aprenda a fazer o bebê dormir no berço."),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // --- SELETOR DE PLANOS ---
                    if (_packages.isEmpty && !kDebugMode) 
                      const CircularProgressIndicator(color: Colors.white)
                    else 
                      Column(
                        children: [
                          if (_getPackageByType(PackageType.annual) != null)
                            _buildPlanCard(_getPackageByType(PackageType.annual)!, isBestValue: true),
                          
                          const SizedBox(height: 15),
                          
                          if (_getPackageByType(PackageType.monthly) != null)
                            _buildPlanCard(_getPackageByType(PackageType.monthly)!, isBestValue: false),
                        ],
                      ),

                    // Fallback para debug se não carregar pacotes (Visualização apenas)
                    if (_packages.isEmpty && kDebugMode) ...[
                        _buildFakePlanCard("Anual", "R\$ 149,90", "R\$ 12,49", true),
                        const SizedBox(height: 15),
                        _buildFakePlanCard("Mensal", "R\$ 29,90", "R\$ 29,90", false),
                    ],

                    const SizedBox(height: 30),

                    // Botão de Ação
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _realizarCompra,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _corPrimaria,
                          foregroundColor: Colors.black,
                          elevation: 10,
                          shadowColor: _corPrimaria.withOpacity(0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              _selectedPackage?.packageType == PackageType.annual 
                                ? "TESTAR 7 DIAS GRÁTIS" 
                                : "ASSINAR AGORA",
                              style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                      ),
                    ),
                    
                    if (_selectedPackage?.packageType == PackageType.annual)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text("Depois ${_selectedPackage?.storeProduct.priceString}/ano. Cancele quando quiser.", style: GoogleFonts.nunito(color: Colors.white54, fontSize: 12)),
                      ),

                    const SizedBox(height: 30),
                    
                    // Botão de Restaurar (Importante para iOS e re-instalações)
                    GestureDetector(onTap: _restaurar, child: Text("Já sou assinante? Restaurar Compra", style: GoogleFonts.nunito(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))),
                    
                    const SizedBox(height: 10),

                    if (!widget.isBloqueio)
                       GestureDetector(onTap: _irParaLogin, child: Text("Fazer Login em outra conta", style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12))),

                    const SizedBox(height: 40),
                    Wrap(alignment: WrapAlignment.center, spacing: 20, children: [_linkPequeno("Termos de Uso", "https://sites.google.com/view/zelo-termos"), _linkPequeno("Privacidade", "https://sites.google.com/view/zelo-privacidade")]),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para buscar pacote
  Package? _getPackageByType(PackageType type) {
    try {
      return _packages.firstWhere((p) => p.packageType == type);
    } catch (e) {
      return null;
    }
  }

  // --- WIDGETS DE DESIGN ---

  Widget _buildPlanCard(Package package, {required bool isBestValue}) {
    bool isSelected = _selectedPackage == package;
    String preco = package.storeProduct.priceString;
    String titulo = isBestValue ? "Anual (Economize 50%)" : "Mensal";
    String subtexto = isBestValue 
      ? "Equivalente a ${(package.storeProduct.price / 12).toStringAsFixed(2)} por mês" 
      : "Cobrado mensalmente";

    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? _corPrimaria.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _corPrimaria : Colors.white10, 
            width: isSelected ? 2 : 1
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? _corPrimaria : Colors.grey,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBestValue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(color: _corDourada, borderRadius: BorderRadius.circular(4)),
                      child: Text("MELHOR VALOR", style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black)),
                    ),
                  Text(titulo, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(subtexto, style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
            Text(preco, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildFakePlanCard(String title, String price, String sub, bool best) {
    bool isSelected = (best && _selectedPackage == null) || (_selectedPackage != null); 
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: best ? _corPrimaria.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: best ? _corPrimaria : Colors.white10, width: 1),
      ),
      child: Row(
        children: [
          Icon(best ? Icons.radio_button_checked : Icons.radio_button_off, color: best ? _corPrimaria : Colors.grey),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if(best) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _corDourada, borderRadius: BorderRadius.circular(4)), child: Text("RECOMENDADO", style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.bold))),
            Text(title, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(sub, style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70)),
          ])),
          Text(price, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _corPrimaria, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.nunito(fontSize: 13, color: Colors.white70, height: 1.3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _linkPequeno(String text, String url) {
    return GestureDetector(
      onTap: () => _abrirLink(url),
      child: Text(text, style: GoogleFonts.nunito(fontSize: 11, color: Colors.white30, decoration: TextDecoration.underline)),
    );
  }
}