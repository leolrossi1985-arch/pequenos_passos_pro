import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- ESTE IMPORT FALTAVA
import '../services/revenue_cat_service.dart';
import '../services/bebe_service.dart';
import 'tela_base.dart';
import 'tela_paywall.dart';

class PremiumGate extends StatefulWidget {
  const PremiumGate({super.key});

  @override
  State<PremiumGate> createState() => _PremiumGateState();
}

class _PremiumGateState extends State<PremiumGate> {
  bool _isLoading = true;
  bool _isPremium = false;
  Map<String, dynamic>? _dadosBebe;

  @override
  void initState() {
    super.initState();
    _verificarAcesso();
  }

  Future<void> _verificarAcesso() async {
    // 1. Verifica status no RevenueCat
    bool status = await RevenueCatService.verificarStatusAtual();
    
    // 2. Se não for premium, precisamos dos dados do bebê para preencher a TelaPaywall
    if (!status) {
      _dadosBebe = await BebeService.lerBebeAtivo();
    }

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
        backgroundColor: Color(0xFFF7F9F9),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF6A9C89))),
      );
    }

    // ✅ CAMINHO LIVRE: Pagou, entra.
    if (_isPremium) {
      return const TelaBase();
    } 
    
    // ⛔ PARE: Não pagou, mostra Paywall (Modo Bloqueio).
    else {
      // Recupera dados para personalizar o texto da venda
      String nome = _dadosBebe?['nome'] ?? "Seu Bebê";
      DateTime nasc = DateTime.now();
      
      if (_dadosBebe?['data_nascimento'] != null) {
         var d = _dadosBebe?['data_nascimento'];
         // Agora o 'Timestamp' vai funcionar porque importamos o pacote lá em cima
         if (d is String) {
           nasc = DateTime.parse(d);
         } else if (d is Timestamp) {
           nasc = d.toDate(); 
         }
      }
      
      String sexo = _dadosBebe?['sexo'] ?? "M";
      // Tenta pegar a dor, se não tiver, usa genérico
      String dor = _dadosBebe?['dor_principal'] ?? "Rotina"; 

      return TelaPaywall(
        isBloqueio: true, // Ativa o modo que redireciona para TelaBase após pagar
        nomeBebe: nome,
        nascimentoBebe: nasc,
        sexo: sexo,
        dorPrincipal: dor,
      );
    }
  }
}