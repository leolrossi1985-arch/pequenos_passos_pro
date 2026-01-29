import 'package:flutter/material.dart';
import 'screens/tela_base.dart';
import 'screens/tela_paywall.dart';
import 'services/revenue_cat_service.dart';

class PremiumGate extends StatefulWidget {
  const PremiumGate({super.key});

  @override
  State<PremiumGate> createState() => _PremiumGateState();
}

class _PremiumGateState extends State<PremiumGate> {
  bool _isLoading = true;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _verificarStatus();
  }

  Future<void> _verificarStatus() async {
    // 1. Verifica no RevenueCat se o usuário tem o entitlement "pro"
    bool status = await RevenueCatService.verificarStatusAtual();
    
    if (mounted) {
      setState(() {
        _isPremium = status;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6A9C89))),
      );
    }

    if (_isPremium) {
      // ✅ Usuário PAGOU: Deixa entrar no app
      return const TelaBase();
    } else {
      // ⛔ Usuário NÃO PAGOU: Manda pro Paywall
      // Precisamos passar os dados do bebê para o Paywall?
      // Se o usuário já cadastrou o bebê mas não pagou, talvez precisemos
      // adaptar o Paywall para não pedir dados de novo, ou apenas bloquear.
      
      // Neste exemplo simples, estou mandando para o Paywall.
      // Você precisará ajustar os parâmetros 'nomeBebe', etc, 
      // ou criar uma versão do Paywall que só peça pagamento.
      return TelaPaywall(
          nomeBebe: "Seu Bebê", // Placeholder ou buscar do banco
          nascimentoBebe: DateTime.now(), // Placeholder
          sexo: "M", 
          dorPrincipal: "Rotina"
      );
    }
  }
}