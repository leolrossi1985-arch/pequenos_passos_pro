import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/revenue_cat_service.dart';
import 'tela_registro.dart'; 

class TelaPaywall extends StatefulWidget {
  final String nomeBebe;
  final DateTime nascimentoBebe;
  final DateTime? dataPrevista;
  final String sexo;
  final String dorPrincipal;

  const TelaPaywall({
    super.key,
    required this.nomeBebe,
    required this.nascimentoBebe,
    this.dataPrevista,
    required this.sexo,
    required this.dorPrincipal,
  });

  @override
  State<TelaPaywall> createState() => _TelaPaywallState();
}

class _TelaPaywallState extends State<TelaPaywall> {
  bool _isLoading = false;
  String _precoDisplay = "R\$ 29,90"; 

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _buscarPrecoReal();
    }
  }

  Future<void> _buscarPrecoReal() async {
    try {
      var oferta = await RevenueCatService.buscarOfertas();
      if (oferta != null && oferta.monthly != null) {
        if (mounted) {
          setState(() {
            _precoDisplay = oferta.monthly!.storeProduct.priceString;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar preço: $e");
    }
  }

  Future<void> _realizarCompra() async {
    setState(() => _isLoading = true);
    bool sucesso = false;

    if (kIsWeb || kDebugMode) {
      await Future.delayed(const Duration(seconds: 1));
      sucesso = true; 
    } else {
      try {
        sucesso = await RevenueCatService.comprarMensal();
      } catch (e) {
        sucesso = false;
      }
    }

    if (mounted) setState(() => _isLoading = false);

    if (sucesso) {
      _avancarParaRegistro();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A compra não foi concluída.")));
      }
    }
  }

  Future<void> _restaurar() async {
    if (kIsWeb) return; 
    setState(() => _isLoading = true);
    bool sucesso = await RevenueCatService.restaurarCompras();
    if (mounted) setState(() => _isLoading = false);
    
    if (sucesso) {
      _avancarParaRegistro();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nenhuma assinatura encontrada.")));
      }
    }
  }

  void _avancarParaRegistro() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TelaRegistro(
        nomeBebe: widget.nomeBebe, 
        nascimentoBebe: widget.nascimentoBebe,
        dataPrevista: widget.dataPrevista, 
        sexo: widget.sexo
      )
    ));
  }

  Future<void> _abrirLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir: $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CORREÇÃO: SingleChildScrollView envolve tudo
      body: SingleChildScrollView(
        child: Container(
          // CORREÇÃO: Garante que o fundo ocupe PELO MENOS a altura da tela, 
          // mas estica se o conteúdo for maior.
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2E20), Color(0xFF1A4D2E)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: _avancarParaRegistro, 
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, size: 50, color: Color(0xFFFFD700))),
                      const SizedBox(height: 25),
                      Text("Plano para ${widget.nomeBebe}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                      const SizedBox(height: 40),
                      
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.2))),
                        child: Column(
                          children: [
                            Text("SEU OBJETIVO:".toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text("Resolver: \"${widget.dorPrincipal}\"", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const Divider(color: Colors.white24, height: 30),
                            Text("NOSSA SOLUÇÃO:".toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            const Text("Método Zelo: Rotina guiada + IA.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFA5D6A7), fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _itemCheck("Cronograma diário ajustado"),
                      _itemCheck("Monitor de Sono Inteligente"),
                      _itemCheck("Acesso Ilimitado aos Cursos"),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                  child: Column(
                    children: [
                      const Text("7 DIAS GRÁTIS", style: TextStyle(color: Color(0xFF1A4D2E), fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 5),
                      Text("Depois $_precoDisplay / mês", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity, height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _realizarCompra,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A4D2E), foregroundColor: Colors.white, elevation: 0),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("COMEÇAR AGORA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: _isLoading ? null : _restaurar,
                        child: const Text("Restaurar Compra", style: TextStyle(color: Colors.grey, fontSize: 12, decoration: TextDecoration.underline)),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _abrirLink('https://sites.google.com/view/zelo-privacidade'), 
                            child: const Text("Termos de Uso", style: TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.underline)),
                          ),
                          const Text("  |  ", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          GestureDetector(
                            onTap: () => _abrirLink('https://sites.google.com/view/zelo-privacidade'), 
                            child: const Text("Política de Privacidade", style: TextStyle(color: Colors.grey, fontSize: 10, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemCheck(String texto) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check, color: Color(0xFFA5D6A7), size: 20), const SizedBox(width: 10), Text(texto, style: const TextStyle(color: Colors.white, fontSize: 15))]));
}