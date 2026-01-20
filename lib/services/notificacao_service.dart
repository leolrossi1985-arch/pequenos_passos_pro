import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacaoService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // INICIALIZAÇÃO ROBUSTA
  static Future<void> iniciar() async {
    print("🔷 [NotificacaoService] Inicializando...");

    // 1. Configura Fuso Horário
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print("✅ [NotificacaoService] Fuso horário detectado: $timeZoneName");
    } catch (e) {
      print("⚠️ [NotificacaoService] Falha no fuso horário, usando UTC. Erro: $e");
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

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
        print("👆 [NotificacaoService] Usuário tocou na notificação: ${details.payload}");
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
      print("🔐 [NotificacaoService] Permissão Android: ${concedido == true ? 'CONCEDIDA' : 'NEGADA'}");
    
    } else if (Platform.isIOS) {
      await _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true, badge: true, sound: true,
          );
    }
  }

  // AGENDAR
  static Future<void> agendarNotificacao({
    required int id,
    required String titulo,
    required String corpo,
    required DateTime dataHora,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dataHora, tz.local);

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print("⚠️ [NotificacaoService] Tentativa de agendar no passado ignorada: $dataHora");
      return;
    }

    print("⏰ [NotificacaoService] Agendando ID $id para: $scheduledDate");

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
      print("✅ [NotificacaoService] Agendado com sucesso.");
    } catch (e) {
      print("❌ [NotificacaoService] Erro ao agendar: $e");
    }
  }

  // --- NOVO: CANCELAR NOTIFICAÇÃO ESPECÍFICA ---
  static Future<void> cancelarNotificacao(int id) async {
    try {
      await _notifications.cancel(id);
      print("🗑️ [NotificacaoService] Notificação ID $id cancelada com sucesso.");
    } catch (e) {
      print("❌ [NotificacaoService] Erro ao cancelar notificação $id: $e");
    }
  }

  // TESTE IMEDIATO
  static Future<void> mostrarImediata({required String titulo, required String corpo}) async {
    const androidDetails = AndroidNotificationDetails(
      'canal_zelo_testes',
      'Testes',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    await _notifications.show(
      888, 
      titulo, 
      corpo, 
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> cancelarTodas() async {
    await _notifications.cancelAll();
    print("🗑️ [NotificacaoService] Todas as notificações canceladas.");
  }
}