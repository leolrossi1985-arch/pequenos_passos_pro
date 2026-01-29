import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // --- CONFIGURAÇÕES ---
  static const _apiKeyAndroid = 'goog_lCcTuQCtZQmpYZkEsopSpNAEzGu';
  static const _apiKeyIOS = 'appl_...sua_chave_ios_aqui...';
  static const String entitlementId = 'pro'; 

  // --- MÉTODOS ---

  static Future<void> init() async {
    // 1. BLINDAGEM WEB: Não inicializa nada se for Web
    if (kIsWeb) {
      debugPrint(">>> [RevenueCat] Modo Web detectado: Plugin desativado.");
      return; 
    }

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKeyAndroid);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyIOS);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  // Busca as ofertas
  static Future<Offering?> buscarOfertas() async {
    // 2. BLINDAGEM WEB: Retorna nulo na Web (vai cair no seu fallback de UI)
    if (kIsWeb) {
      return null; 
    }

    try {
      Offerings offerings = await Purchases.getOfferings();
      return offerings.current;
    } on PlatformException catch (e) {
      debugPrint("Erro ao buscar ofertas: $e");
      return null;
    }
  }

  // Realiza a compra
  static Future<bool> comprarMensal() async {
    // 3. BLINDAGEM WEB: Simula uma compra com sucesso após 2 segundos
    if (kIsWeb) {
      debugPrint(">>> [RevenueCat] Web: Simulando compra...");
      await Future.delayed(const Duration(seconds: 2));
      return true; // Retorna TRUE para você testar o fluxo de sucesso
    }

    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.monthly != null) {
        CustomerInfo customerInfo = await Purchases.purchasePackage(offerings.current!.monthly!);
        return _verificarSeEhPremium(customerInfo);
      } else {
        debugPrint("Pacote mensal não encontrado.");
        return false;
      }
    } on PlatformException {
      // ... tratamento de erro ...
      return false;
    }
  }

  // Verifica o status
  static Future<bool> verificarStatusAtual() async {
    // 4. BLINDAGEM WEB: Decide se você quer ser Premium ou não na Web
    if (kIsWeb) {
      // Retorna true para permitir o acesso na Web (evita Paywall bloqueado)
      return true; 
    }

    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return _verificarSeEhPremium(customerInfo);
    } on PlatformException catch (e) {
      debugPrint("Erro ao verificar status: $e");
      return false;
    }
  }

  // Restaura compras
  static Future<bool> restaurarCompras() async {
    // 5. BLINDAGEM WEB: Evita o crash do 'restorePurchases'
    if (kIsWeb) {
      debugPrint(">>> [RevenueCat] Web: Simulando restauração...");
      await Future.delayed(const Duration(seconds: 1));
      return true; // Simula que restaurou
    }

    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return _verificarSeEhPremium(customerInfo);
    } on PlatformException catch (e) {
      debugPrint("Erro ao restaurar: $e");
      return false;
    }
  }

  static bool _verificarSeEhPremium(CustomerInfo customerInfo) {
    return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
  }
}