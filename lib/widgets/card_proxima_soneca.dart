import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardProximaSoneca extends StatefulWidget {
  final DateTime? ultimoAcordar;
  final int janelaVigiliaMinutos;
  final bool isDormindo;

  const CardProximaSoneca({
    super.key,
    required this.ultimoAcordar,
    required this.janelaVigiliaMinutos,
    required this.isDormindo,
  });

  @override
  State<CardProximaSoneca> createState() => _CardProximaSonecaState();
}

class _CardProximaSonecaState extends State<CardProximaSoneca> with SingleTickerProviderStateMixin {
  late Timer _timer;
  Duration _tempoRestante = Duration.zero;
  double _progresso = 0.0;
  bool _atrasado = false;

  @override
  void initState() {
    super.initState();
    _atualizarCalculos();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _atualizarCalculos());
  }

  @override
  void didUpdateWidget(covariant CardProximaSoneca oldWidget) {
    super.didUpdateWidget(oldWidget);
    _atualizarCalculos();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _atualizarCalculos() {
    if (widget.isDormindo || widget.ultimoAcordar == null) {
      if (mounted) setState(() {});
      return;
    }

    final agora = DateTime.now();
    final proximaSoneca = widget.ultimoAcordar!.add(Duration(minutes: widget.janelaVigiliaMinutos));
    final diff = proximaSoneca.difference(agora);
    final totalJanela = Duration(minutes: widget.janelaVigiliaMinutos).inSeconds;
    
    // Evitar divisão por zero
    if (totalJanela == 0) return;

    final passado = agora.difference(widget.ultimoAcordar!).inSeconds;
    double progressoCalc = passado / totalJanela;

    if (mounted) {
      setState(() {
        _tempoRestante = diff;
        _atrasado = diff.isNegative;
        _progresso = progressoCalc.clamp(0.0, 1.0);
      });
    }
  }

  Color _getCorStatus() {
    if (_atrasado) return const Color(0xFFEF5350); // Vermelho
    if (_progresso > 0.8) return const Color(0xFFFFA726); // Laranja
    return const Color(0xFF66BB6A); // Verde
  }

  String _formatarDuracao(Duration d) {
    final horas = d.inHours.abs();
    final minutos = d.inMinutes.remainder(60).abs();
    if (horas > 0) return "${horas}h ${minutos}min";
    return "${minutos}min";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDormindo) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFC5CAE9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.nightlight_round, color: Color(0xFF3949AB)),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Modo Soneca Ativo", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
                Text("O bebê está descansando...", style: TextStyle(fontSize: 12, color: Color(0xFF5C6BC0))),
              ],
            ),
          ],
        ),
      );
    }

    if (widget.ultimoAcordar == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_toggle_off_rounded, color: Colors.indigo),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Calculadora de Soneca", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                  SizedBox(height: 2),
                  Text("Registre quando o bebê acordar para ver a previsão.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      );
    }

    final corStatus = _getCorStatus();
    final textoPrincipal = _atrasado ? "Passou da hora!" : "Próxima soneca em";
    final textoTempo = _atrasado ? "+${_formatarDuracao(_tempoRestante)}" : _formatarDuracao(_tempoRestante);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16, color: Colors.grey[400]),
                      const SizedBox(width: 6),
                      Text(
                        "JANELA DE VIGÍLIA",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    textoPrincipal,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    textoTempo,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: corStatus,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              // Circular Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: _progresso,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(corStatus),
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Icon(
                    _atrasado ? Icons.warning_rounded : Icons.bedtime_outlined,
                    color: corStatus,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progresso linear detalhada
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progresso,
              backgroundColor: Colors.grey[100],
              color: corStatus,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Acordou às ${DateFormat('HH:mm').format(widget.ultimoAcordar!)}",
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
              Text(
                "Meta: ${DateFormat('HH:mm').format(widget.ultimoAcordar!.add(Duration(minutes: widget.janelaVigiliaMinutos)))}",
                style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}
