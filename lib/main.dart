import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- NOVOS IMPORTS NECESSÁRIOS PARA NOTIFICAÇÃO ---
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
// --------------------------------------------------

import 'services/revenue_cat_service.dart';
import 'services/bebe_service.dart';
import 'services/notificacao_service.dart';
import 'screens/tela_base.dart';
import 'screens/tela_onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. CONFIGURAR FUSO HORÁRIO
  if (!kIsWeb) {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("Fuso horário configurado: $timeZoneName");
    } catch (e) {
      debugPrint("Erro ao configurar Timezone: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  // 2. DATA
  try {
    await initializeDateFormatting('pt_BR', null);
  } catch (e) {
    debugPrint("Erro datas: $e");
  }

  // 3. NOTIFICAÇÕES
  if (!kIsWeb) {
    try {
      await NotificacaoService.iniciar();
    } catch (e) {
      debugPrint("Erro notificações: $e");
    }
  }

  // 4. REVENUECAT
  if (!kIsWeb) {
    try {
      await RevenueCatService.init();
    } catch (e) {
      debugPrint("Erro RevenueCat: $e");
    }
  }

  // 5. FIREBASE
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBYHX6uFImf0CPfSTOnILSQ6ZPdgXwbPfw",
          appId: "1:85796774768:web:a2525874987d7daaaf65b5",
          messagingSenderId: "85796774768",
          projectId: "pequenos-passos-pro",
          storageBucket: "pequenos-passos-pro.firebasestorage.app",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Erro Firebase: $e");
  }

  runApp(const MeuAppPro());
}

class MeuAppPro extends StatelessWidget {
  const MeuAppPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZELO',
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),

      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // --- CONFIGURAÇÃO DE TEMA (APENAS CLARO) ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6A9C89),
          onPrimary: Colors.white,
          secondary: Color(0xFFE88D67),
          onSecondary: Colors.white,
          error: Color(0xFFBA1A1A),
          onError: Colors.white,
          surface: Color(0xFFFDFDFD),
          onSurface: Color(0xFF1A1C18),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9F9),
        
        // Define a fonte padrão para todo o app
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF2D3A3A),
        ),
      ),

      // --- FORÇA O MODO CLARO ---
      // Mesmo que o celular esteja em modo escuro, o app será claro.
      // Isso evita quebras de layout nas suas telas atuais.
      themeMode: ThemeMode.light, 

      home: const AuthGate(),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF6A9C89))));
        }

        final user = snapshot.data;

        if (user == null) {
          return const TelaOnboarding();
        }

        return FutureBuilder<bool>(
          future: BebeService.temBebesCadastrados(),
          builder: (context, babySnapshot) {
            if (babySnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF6A9C89))));
            }

            final temBebes = babySnapshot.data ?? false;

            if (temBebes) {
              return const TelaBase();
            }

            return const TelaOnboarding();
          },
        );
      },
    );
  }
}