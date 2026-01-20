import 'dart:io';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTS ---
import 'abas_ferramentas/tela_marcos.dart'; 
import 'abas_ferramentas/tela_cursos.dart';
import 'abas_ferramentas/tela_sos.dart';
import 'abas_ferramentas/tela_ruido.dart';
import '../services/bebe_service.dart'; // Importante para dados

class TelaFerramentas extends StatefulWidget {
  const TelaFerramentas({super.key});

  @override
  State<TelaFerramentas> createState() => _TelaFerramentasState();
}

class _TelaFerramentasState extends State<TelaFerramentas> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Variáveis do bebê
  String _nomeBebe = "do Bebê";
  String? _fotoBebe;
  bool _temBebe = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          _temBebe = true;
        });
      }
    }
  }

  ImageProvider? _getImagemPerfil() {
    if (_fotoBebe != null && _fotoBebe!.isNotEmpty) {
      if (kIsWeb) return NetworkImage(_fotoBebe!);
      return FileImage(File(_fotoBebe!));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Altura do Header (170 é o ideal para 2 linhas de texto + avatar + tabs)
    final double headerHeight = MediaQuery.of(context).padding.top + 170;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7), 
      extendBody: true,
      body: Stack(
        children: [
          // 1. CONTEÚDO (Passa por baixo do header)
          TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(padding: EdgeInsets.only(top: headerHeight), child: const TelaMarcos()), 
              Padding(padding: EdgeInsets.only(top: headerHeight), child: const TelaCursos()),
              Padding(padding: EdgeInsets.only(top: headerHeight), child: const TelaSOS()),
              Padding(padding: EdgeInsets.only(top: headerHeight), child: const TelaRuido()),
            ],
          ),

          // 2. HEADER FLUTUANTE COM FOTO
          Positioned(
            top: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.white.withOpacity(0.85),
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
                                // Exibe "Ferramentas de Gabriel"
                                "Ferramentas $_nomeBebe",
                                style: TextStyle(
                                  fontSize: 24, 
                                  fontWeight: FontWeight.w900, 
                                  color: Colors.black.withOpacity(0.85),
                                  letterSpacing: -0.5
                                ),
                              ),
                              Text(
                                "Recursos úteis para você",
                                style: TextStyle(
                                  fontSize: 12, 
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),
                          
                          // Avatar do Bebê
                          Hero(
                            tag: 'perfil_bebe_ferramentas', // Tag única
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
                                color: Colors.black.withOpacity(0.08), 
                                blurRadius: 8, 
                                offset: const Offset(0, 2)
                              )
                            ]
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: const Color(0xFF2D3A3A),
                          unselectedLabelColor: Colors.grey.shade500,
                          
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.emoji_events_rounded, size: 16),
                                  SizedBox(width: 4),
                                  Text("Marcos", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5)),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.school_rounded, size: 16),
                                  SizedBox(width: 4),
                                  Text("Cursos", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5)),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medical_services_rounded, size: 16),
                                  SizedBox(width: 4),
                                  Text("SOS", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5)),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.surround_sound_rounded, size: 16),
                                  SizedBox(width: 4),
                                  Text("Ruídos", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5)),
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