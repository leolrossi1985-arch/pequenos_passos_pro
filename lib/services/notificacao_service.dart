import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacaoService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false; // Flag de controle

  // INICIALIZAÇÃO ROBUSTA
  static Future<void> iniciar() async {
    if (_isInitialized) return; // Evita re-inicialização
    
    debugPrint("🔷 [NotificacaoService] Inicializando...");

    // 1. Configura Fuso Horário
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint("✅ [NotificacaoService] Fuso horário detectado: $timeZoneName");
    } catch (e) {
      debugPrint("⚠️ [NotificacaoService] Falha no fuso horário, usando UTC. Erro: $e");
      try {
         tz.initializeTimeZones(); // Tenta inicializar de novo caso tenha falhado
         tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
    
    _isInitialized = true;

    // 2. Configurações Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // 3. Configurações iOS
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings, 
      iOS: iosSettings
    );

    // 4. Inicializa o Plugin
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint("👆 [NotificacaoService] Usuário tocou na notificação: ${details.payload}");
      },
    );

    // 5. Solicita Permissão
    await _pedirPermissao();
  }

  static Future<void> _pedirPermissao() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      final bool? concedido = await androidImplementation?.requestNotificationsPermission();
      debugPrint("🔐 [NotificacaoService] Permissão Android: ${concedido == true ? 'CONCEDIDA' : 'NEGADA'}");
    
    } else if (Platform.isIOS) {
      await _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true, badge: true, sound: true,
          );
    }
  }

  // AGENDAR (Única)
  static Future<void> agendarNotificacao({
    required int id,
    required String titulo,
    required String corpo,
    required DateTime dataHora,
  }) async {
    // Garante inicialização antes de agendar
    if (!_isInitialized) await iniciar();

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dataHora, tz.local);

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      // Ignora silenciosamente se for passado muito antigo, ou loga aviso
      return;
    }

    // Configuração do Canal
    const androidDetails = AndroidNotificationDetails(
      'canal_zelo_medicamentos', 
      'Lembretes de Saúde',
      channelDescription: 'Lembretes de vacinas e remédios',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const detalhes = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notifications.zonedSchedule(
        id,
        titulo,
        corpo,
        scheduledDate,
        detalhes,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("⏰ [Agendado] ID $id para: $scheduledDate");
    } catch (e) {
      debugPrint("❌ [NotificacaoService] Erro ao agendar: $e");
    }
  }

  // --- O NOVO MÉTODO DA JANELA DESLIZANTE ---
  static Future<void> agendarLembretesContinuos({
    required int idBase, // Hash do ID do remédio
    required String titulo,
    required String corpo,
    required DateTime dataInicioOriginal, // Quando o usuário COMEÇOU o remédio
    required int intervaloHoras,
    int diasBuffer = 5, // Janela de agendamento (recomendado 5 dias)
  }) async {
    // Garante inicialização antes de agendar
    if (!_isInitialized) await iniciar();
    
    // 1. Definições de Tempo
    final agora = tz.TZDateTime.now(tz.local);
    final dataInicioTZ = tz.TZDateTime.from(dataInicioOriginal, tz.local);
    final limiteFuturo = agora.add(Duration(days: diasBuffer));

    // 2. Matemática para achar a PRÓXIMA dose a partir de AGORA
    // Ex: Começou dia 01 às 8h (6/6h). Agora é dia 05 às 15h.
    // O código abaixo "pula" as doses do passado matematicamente.
    
    tz.TZDateTime proximaDose = dataInicioTZ;
    
    if (proximaDose.isBefore(agora)) {
      final diferencaSegundos = agora.difference(proximaDose).inSeconds;
      final intervaloSegundos = intervaloHoras * 3600;
      
      // Quantos ciclos já passaram?
      final ciclosPassados = (diferencaSegundos / intervaloSegundos).ceil();
      
      // Avança a data para o próximo ciclo futuro
      proximaDose = proximaDose.add(Duration(seconds: ciclosPassados * intervaloSegundos));
    }

    // 3. Loop de Agendamento (Só até o limite do buffer)
    int contador = 0;
    
    // Enquanto a próxima dose for antes do limite (daqui a 5 dias)
    while (proximaDose.isBefore(limiteFuturo)) {
      // Gera um ID único e determinístico para essa dose
      // Usamos o idBase + um deslocamento calculado pelo tempo para garantir que
      // se a função rodar de novo, o ID será o mesmo (sobrescreve em vez de duplicar)
      final notificationId = idBase + (proximaDose.millisecondsSinceEpoch % 100000); 

      // Chama o agendamento simples
      await agendarNotificacao(
        id: notificationId,
        titulo: titulo,
        corpo: corpo,
        dataHora: proximaDose,
      );

      // Avança para a próxima dose
      proximaDose = proximaDose.add(Duration(hours: intervaloHoras));
      contador++;
      
      // Trava de segurança para loops infinitos
      if (contador > 100) break; 
    }
    
    debugPrint("✅ [Janela Deslizante] Total de $contador notificações agendadas para os próximos $diasBuffer dias.");
  }

  // CANCELAR NOTIFICAÇÃO
  static Future<void> cancelarNotificacao(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint("🗑️ [Cancelado] ID $id");
    } catch (e) {
      debugPrint("❌ Erro ao cancelar $id: $e");
    }
  }

  static Future<void> cancelarTodas() async {
    await _notifications.cancelAll();
    debugPrint("🗑️ Todas as notificações canceladas.");
  }
}