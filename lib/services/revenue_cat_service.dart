import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // --- CONFIGURAÇÕES ---
  
  // AVISO: Geralmente as chaves de Android e iOS são diferentes no painel do RevenueCat. 
  // Verifique se copiou as chaves "Public API Key" corretas para cada plataforma.
  static const _apiKeyAndroid = 'goog_GSmCgsrasxokUkwfWAHKLDHimlb';
  static const _apiKeyIOS = 'appl_...sua_chave_ios_aqui...';

  // O NOME DO SEU "ENTITLEMENT" (Nível de acesso configurado no RevenueCat)
  // No painel do RC vá em: Products -> Entitlements. O "Identifier" deve ser este:
  static const String entitlementId = 'pro'; 

  // --- MÉTODOS ---

  static Future<void> init() async {
    if (kIsWeb) return; // RevenueCat não suporta Web oficialmente da mesma forma

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKeyAndroid);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyIOS);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      
      // Opcional: Escutar mudanças em tempo real (ex: assinatura expirou com app aberto)
      /* Purchases.addCustomerInfoUpdateListener((customerInfo) {
        // Aqui você pode atualizar um Provider/Bloc global com o novo status
        bool isPremium = _verificarSeEhPremium(customerInfo);
      });
      */
    }
  }

  // Busca as ofertas para exibir na tela de Paywall (Preços, Títulos, etc)
  static Future<Offering?> buscarOfertas() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      // Retorna a oferta marcada como "Current" no painel
      return offerings.current;
    } on PlatformException catch (e) {
      print("Erro ao buscar ofertas: $e");
      return null;
    }
  }

  // Realiza a compra do pacote mensal
  static Future<bool> comprarMensal() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      
      // Verifica se existe uma oferta atual e se o pacote mensal está configurado
      if (offerings.current != null && offerings.current!.monthly != null) {
        // Inicia o fluxo de compra nativo
        CustomerInfo customerInfo = await Purchases.purchasePackage(offerings.current!.monthly!);
        return _verificarSeEhPremium(customerInfo);
      } else {
        print("Pacote mensal não encontrado no painel do RevenueCat.");
        return false;
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Erro na compra: ${e.message}");
      }
      // Se o usuário cancelou, retornamos false sem erro
      return false;
    }
  }

  // Verifica o status SEM tentar comprar (Usar no Splash Screen ou Home)
  static Future<bool> verificarStatusAtual() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return _verificarSeEhPremium(customerInfo);
    } on PlatformException catch (e) {
      print("Erro ao verificar status: $e");
      return false;
    }
  }

  // Restaura compras (Botão obrigatório no iOS)
  static Future<bool> restaurarCompras() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return _verificarSeEhPremium(customerInfo);
    } on PlatformException catch (e) {
      print("Erro ao restaurar: $e");
      return false;
    }
  }

  // Método auxiliar privado para ler o JSON do RevenueCat
  static bool _verificarSeEhPremium(CustomerInfo customerInfo) {
    // Verifica se o entitlement "pro" (ou o nome que você definiu) está ativo
    return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
  }
}