import 'dart:io';
import 'dart:ui'; 
import 'dart:convert'; // Para Base64

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb

import '../services/pdf_service.dart';
import '../services/bebe_service.dart'; // Importante para carregar dados

import 'abas_saude/aba_vacinas.dart';
import 'abas_saude/aba_remedios.dart';
import 'abas_saude/aba_sintomas.dart';
import 'abas_saude/aba_consultas.dart';
import 'abas_saude/aba_crescimento.dart'; 
import 'abas_saude/aba_dentes.dart';      

class TelaSaude extends StatefulWidget {
  const TelaSaude({super.key});

  @override
  State<TelaSaude> createState() => _TelaSaudeState();
}

class _TelaSaudeState extends State<TelaSaude> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Variáveis do bebê
  String _nomeBebe = "do Bebê";
  String? _fotoBebe;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _carregarDadosBebe();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _carregarDadosBebe() async {
    final dados = await BebeService.lerBebeAtivo();
    if (dados != null) {
      if (mounted) {
        setState(() {
          // Pega só o primeiro nome
          String nomeCompleto = dados['nome'];
          _nomeBebe = "de ${nomeCompleto.split(' ')[0]}"; 
          _fotoBebe = dados['fotoUrl'];
        });
      }
    }
  }

  // --- LÓGICA DE IMAGEM HÍBRIDA (IGUAL ÀS OUTRAS TELAS) ---
  // --- LÓGICA DE IMAGEM HÍBRIDA CORRIGIDA ---
  ImageProvider? _getImagemPerfil() {
    if (_fotoBebe == null || _fotoBebe!.isEmpty) return null;

    // 1. Web ou URL (http)
    if (kIsWeb || _fotoBebe!.startsWith('http')) {
      return NetworkImage(_fotoBebe!);
    }

    // 2. Base64 (Texto Longo)
    // Caminhos de arquivo raramente passam de 200 caracteres.
    // Uma foto em Base64 tem milhares. Essa é a melhor forma de distinguir.
    if (_fotoBebe!.length > 200) {
       try {
         Uint8List bytes = base64Decode(_fotoBebe!);
         return MemoryImage(bytes);
       } catch (e) {
         debugPrint("Erro ao decodificar imagem Base64: $e");
       }
    }

    // 3. Arquivo Local (Caminho curto)
    try {
      final file = File(_fotoBebe!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    } catch (e) {
      // Ignora erros de arquivo não encontrado
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Altura segura para o topo (status bar + header)
    final double headerHeight = MediaQuery.of(context).padding.top + 140;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      extendBody: true,
      body: Stack(
        children: [
          // 1. CONTEÚDO
          Padding(
            padding: EdgeInsets.only(top: headerHeight),
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: const [
                AbaVacinas(),
                AbaRemedios(),
                AbaSintomas(),
                AbaConsultas(),
                AbaCrescimento(),
                AbaDentes(),
              ],
            ),
          ),

          // 2. HEADER FLUTUANTE
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.85),
                  padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 10, 0, 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título e Avatar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Saúde $_nomeBebe",
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A), letterSpacing: -0.5),
                                ),
                                const Text(
                                  "Prontuário Digital",
                                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            
                            Row(
                              children: [
                                // Botão PDF (Mantido)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () async { try { await PdfService.gerarRelatorioMedico(); } catch (e) { debugPrint("Erro PDF: $e"); } },
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)]),
                                      child: const Icon(Icons.print_rounded, color: Colors.teal, size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Avatar (Novo)
                                Hero(
                                  tag: 'perfil_bebe_saude',
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.teal.shade200, width: 2)),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.grey[200],
                                      backgroundImage: _getImagemPerfil(),
                                      child: _getImagemPerfil() == null ? const Icon(Icons.face, color: Colors.grey, size: 20) : null,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15),

                      // --- TABBAR OTIMIZADA PARA 6 ITENS ---
                      Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8ECEF), 
                          borderRadius: BorderRadius.circular(25)
                        ),
                        child: TabBar(
                          controller: _tabController,
                          
                          // Configurações para caber tudo numa linha
                          isScrollable: false, 
                          labelPadding: EdgeInsets.zero,
                          
                          indicator: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(21),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: const Color(0xFF2D3A3A),
                          unselectedLabelColor: Colors.grey.shade500,
                          
                          tabs: [
                            _buildCompactTab(Icons.vaccines_rounded, "Vacinas"),
                            _buildCompactTab(Icons.medication_rounded, "Remédios"),
                            _buildCompactTab(Icons.thermostat_rounded, "Sintomas"),
                            _buildCompactTab(Icons.calendar_month_rounded, "Agenda"), 
                            _buildCompactTab(Icons.show_chart_rounded, "Cresc."),
                            _buildCompactTab(Icons.face_retouching_natural_rounded, "Dentes"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper para criar abas que não quebram o layout
  Widget _buildCompactTab(IconData icon, String label) {
    return Tab(
      child: FittedBox( // Reduz o tamanho se necessário para caber
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16), 
            const SizedBox(width: 4), 
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5)), 
          ],
        ),
      ),
    );
  }
}