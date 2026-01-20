import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bebe_service.dart'; 

class SonoGlobalService {
  static final SonoGlobalService _instance = SonoGlobalService._internal();
  factory SonoGlobalService() => _instance;
  
  SonoGlobalService._internal() {
    _recuperarEstado();
  }

  // =================================================================
  // 🎵 ÁUDIO (PLAYER) COM TIMER AUTOMÁTICO
  // =================================================================
  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> tocandoNotifier = ValueNotifier(false);
  final ValueNotifier<String?> somAtivoIdNotifier = ValueNotifier(null);
  final ValueNotifier<String?> timerDesligamentoNotifier = ValueNotifier(null);
  Timer? _timerAudio;
  int _minutosEscolhidos = 0;

  void definirTempoDesligamento(int minutos) {
    _minutosEscolhidos = minutos;
    if (tocandoNotifier.value) {
       _iniciarContagemRegressiva();
    }
  }

  Future<void> toggleSom(String id, String arquivo, double volume) async {
    try {
      if (somAtivoIdNotifier.value == id && tocandoNotifier.value) {
        await pararSom();
      } else {
        await _player.stop();
        somAtivoIdNotifier.value = id;
        tocandoNotifier.value = true;
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.setVolume(volume);
        try {
          await _player.play(AssetSource('sounds/$arquivo'));
          _iniciarContagemRegressiva();
        } catch (e) {
          print("Erro player: $e");
        }
      }
    } catch (e) {
      print("Erro geral áudio: $e");
    }
  }

  Future<void> pararSom() async {
    await _player.stop();
    tocandoNotifier.value = false;
    somAtivoIdNotifier.value = null;
    _cancelarTimerAudio();
  }

  void setVolume(double vol) {
    _player.setVolume(vol);
  }

  void _iniciarContagemRegressiva() {
    _cancelarTimerAudio();
    if (_minutosEscolhidos <= 0) {
      timerDesligamentoNotifier.value = null;
      return; 
    }
    int segundosRestantes = _minutosEscolhidos * 60;
    timerDesligamentoNotifier.value = _formatarTempoSimples(segundosRestantes);
    _timerAudio = Timer.periodic(const Duration(seconds: 1), (timer) async {
      segundosRestantes--;
      if (segundosRestantes <= 0) {
        await pararSom();
      } else {
        timerDesligamentoNotifier.value = _formatarTempoSimples(segundosRestantes);
      }
    });
  }

  void _cancelarTimerAudio() {
    _timerAudio?.cancel();
    _timerAudio = null;
    timerDesligamentoNotifier.value = null;
  }

  String _formatarTempoSimples(int segundos) {
    int m = segundos ~/ 60;
    int s = segundos % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  // =================================================================
  // 💤 SONO (REGISTRO DE ROTINA)
  // =================================================================
  final ValueNotifier<bool> dormindoNotifier = ValueNotifier(false);
  final ValueNotifier<String> tempoSonoNotifier = ValueNotifier("00:00");
  DateTime? _inicioSono;
  Timer? _timerSono;

  // --- NOVO MÉTODO PARA A TIMELINE VISUAL ---
  DateTime? getInicioSonoAtual() {
    return _inicioSono;
  }
  // ------------------------------------------

  Future<void> iniciarSono() async {
    if (dormindoNotifier.value || amamentandoNotifier.value) return;
    _inicioSono = DateTime.now();
    dormindoNotifier.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('inicio_sono', _inicioSono!.toIso8601String());
    _iniciarTickerSono();
  }

  Future<void> pararSono() async {
    if (!dormindoNotifier.value || _inicioSono == null) return;
    _timerSono?.cancel();
    final fim = DateTime.now();
    final diferenca = fim.difference(_inicioSono!);
    
    if (diferenca.inSeconds > 0) { 
      String duracao = _formatarDiferenca(diferenca);
      final ref = await BebeService.getRefBebeAtivo();
      if (ref != null) {
        await ref.collection('rotina').add({
          'tipo': 'sono',
          'duracao_segundos': diferenca.inSeconds,
          'duracao_fmt': duracao,
          'data': _inicioSono!.toIso8601String(),
          'fim': fim.toIso8601String(),
          'criado_em': FieldValue.serverTimestamp()
        });
      }
    }

    _inicioSono = null;
    dormindoNotifier.value = false;
    tempoSonoNotifier.value = "00:00";
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('inicio_sono');
  }

  void _iniciarTickerSono() {
    _timerSono?.cancel();
    _timerSono = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_inicioSono != null) {
        final agora = DateTime.now();
        tempoSonoNotifier.value = _formatarDiferenca(agora.difference(_inicioSono!));
      }
    });
  }

  // =================================================================
  // 🤱 AMAMENTAÇÃO
  // =================================================================
  final ValueNotifier<bool> amamentandoNotifier = ValueNotifier(false);
  final ValueNotifier<String> ladoMamadaNotifier = ValueNotifier('E');
  final ValueNotifier<String> tempoMamadaNotifier = ValueNotifier("00:00");
  DateTime? _inicioMamada;
  Timer? _timerMamada;

  Future<void> iniciarMamada(String lado) async {
    if (dormindoNotifier.value) return;
    if (amamentandoNotifier.value) await pararMamada(); 
    _inicioMamada = DateTime.now();
    amamentandoNotifier.value = true;
    ladoMamadaNotifier.value = lado;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('inicio_mamada', _inicioMamada!.toIso8601String());
    await prefs.setString('lado_mamada', lado);
    _iniciarTickerMamada();
  }

  Future<void> pararMamada() async {
    if (!amamentandoNotifier.value || _inicioMamada == null) return;
    _timerMamada?.cancel();
    final fim = DateTime.now();
    final diferenca = fim.difference(_inicioMamada!);

    if (diferenca.inSeconds > 0) {
      String duracao = _formatarDiferenca(diferenca);
      String ladoTexto = ladoMamadaNotifier.value == 'E' ? 'Esquerdo' : 'Direito';
      final ref = await BebeService.getRefBebeAtivo();
      if (ref != null) {
        await ref.collection('rotina').add({
          'tipo': 'mamada',
          'lado': ladoTexto,
          'duracao_segundos': diferenca.inSeconds,
          'duracao_fmt': duracao,
          'data': _inicioMamada!.toIso8601String(),
          'fim': fim.toIso8601String(),
          'criado_em': FieldValue.serverTimestamp()
        });
      }
    }

    _inicioMamada = null;
    amamentandoNotifier.value = false;
    tempoMamadaNotifier.value = "00:00";
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('inicio_mamada');
    await prefs.remove('lado_mamada');
  }

  void _iniciarTickerMamada() {
    _timerMamada?.cancel();
    _timerMamada = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_inicioMamada != null) {
        final agora = DateTime.now();
        tempoMamadaNotifier.value = _formatarDiferenca(agora.difference(_inicioMamada!));
      }
    });
  }

  Future<void> _recuperarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('inicio_sono')) {
      final String? isoDate = prefs.getString('inicio_sono');
      if (isoDate != null) {
        _inicioSono = DateTime.parse(isoDate);
        dormindoNotifier.value = true;
        _iniciarTickerSono(); 
      }
    }
    if (prefs.containsKey('inicio_mamada')) {
      final String? isoDate = prefs.getString('inicio_mamada');
      final String? lado = prefs.getString('lado_mamada');
      if (isoDate != null) {
        _inicioMamada = DateTime.parse(isoDate);
        ladoMamadaNotifier.value = lado ?? 'E';
        amamentandoNotifier.value = true;
        _iniciarTickerMamada();
      }
    }
  }

  String _formatarDiferenca(Duration d) {
    String h = (d.inHours % 24).toString().padLeft(2, '0');
    String m = (d.inMinutes % 60).toString().padLeft(2, '0');
    String s = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (d.inHours > 0) return "$h:$m:$s";
    return "$m:$s";
  }
}