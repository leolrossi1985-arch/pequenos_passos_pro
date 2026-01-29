import 'dart:io';
import 'dart:ui'; // Necessário para o efeito de vidro (Blur)
import 'dart:convert'; // Para Base64

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb

// --- IMPORTS DAS TELAS INTERNAS ---
import 'tela_rotina_geral.dart';
import 'tela_alimentacao.dart';
import 'tela_diario.dart'; 
import '../services/bebe_service.dart'; 

class TelaRotinaHub extends StatefulWidget {
  const TelaRotinaHub({super.key});

  @override
  State<TelaRotinaHub> createState() => _TelaRotinaHubState();
}

class _TelaRotinaHubState extends State<TelaRotinaHub> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Variáveis para os dados do bebê
  String _nomeBebe = "Carregando...";
  String? _fotoBebe;
  bool _temBebe = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          // Pegamos apenas o primeiro nome para não ficar muito longo no título
          String nomeCompleto = dados['nome'];
          _nomeBebe = nomeCompleto.split(' ')[0]; 
          _fotoBebe = dados['fotoUrl'];
          _temBebe = true;
        });
      }
    }
  }

  // --- LÓGICA DE IMAGEM HÍBRIDA (IGUAL TELA PRINCIPAL) ---
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
    // Altura dinâmica
    final double headerHeight = MediaQuery.of(context).padding.top + 170;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), 
      extendBody: true, 
      body: Stack(
        children: [
          // 1. CONTEÚDO DAS ABAS
          TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(), 
            children: [
              Padding(
                padding: EdgeInsets.only(top: headerHeight), 
                child: const TelaRotinaGeral() 
              ),
              Padding(
                padding: EdgeInsets.only(top: headerHeight), 
                child: const TelaAlimentacao() 
              ),
              Padding(
                padding: EdgeInsets.only(top: headerHeight), 
                child: const TelaDiario() 
              ),
            ],
          ),

          // 2. CABEÇALHO FLUTUANTE COM FOTO
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.85),
                  padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 10, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título e Avatar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // Exibe "Rotina de [Nome]"
                                _temBebe ? "Rotina de $_nomeBebe" : "Rotina do Bebê",
                                style: TextStyle(
                                  fontSize: 24, 
                                  fontWeight: FontWeight.w900, 
                                  color: Colors.black.withValues(alpha: 0.85),
                                  letterSpacing: -0.5
                                ),
                              ),
                              Text(
                                "Acompanhamento Diário",
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                          
                          // Avatar com Foto Real
                          Hero(
                            tag: 'perfil_bebe_rotina', 
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.teal.shade200, width: 2)
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _getImagemPerfil(),
                                child: _getImagemPerfil() == null 
                                  ? const Icon(Icons.face, color: Colors.grey) 
                                  : null,
                              ),
                            ),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 15),

                      // TabBar "Ilha Flutuante"
                      Container(
                        height: 50, 
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8ECEF), 
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(21),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08), 
                                blurRadius: 8, 
                                offset: const Offset(0, 2)
                              )
                            ]
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: const Color(0xFF2D3A3A),
                          unselectedLabelColor: Colors.grey.shade500,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.dashboard_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text("Geral"),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.restaurant_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text("Comer"),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text("Diário"),
                                ],
                              ),
                            ),
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
}