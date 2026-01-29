import 'dart:io';
import 'dart:convert'; // Para Base64
import 'dart:typed_data'; // Para Uint8List

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // <--- IMPORTANTE

import '../services/bebe_service.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final _nomeController = TextEditingController();
  DateTime? _dataNascimento;
  
  bool _usarDPP = false;
  DateTime? _dataPrevistaParto;

  XFile? _imagemSelecionada;
  String? _imagemUrlAtual; // Pode ser Path (antigo), URL ou Base64
  String? _idBebe;
  String? _codigoAcesso; 
  bool _carregando = true;
  bool _salvando = false; // Novo estado para loading de salvamento

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    final dados = await BebeService.lerBebeAtivo();
    if (dados != null) {
      if (mounted) {
        setState(() {
          _idBebe = dados['id'];
          _nomeController.text = dados['nome'];
          _imagemUrlAtual = dados['fotoUrl'];
          _codigoAcesso = dados['codigo_acesso'];

          if (dados['data_parto'] is Timestamp) {
            _dataNascimento = (dados['data_parto'] as Timestamp).toDate();
          } else {
            _dataNascimento = DateTime.parse(dados['data_parto']);
          }

          if (dados['data_prevista'] != null) {
            _usarDPP = true;
            if (dados['data_prevista'] is Timestamp) {
              _dataPrevistaParto = (dados['data_prevista'] as Timestamp).toDate();
            } else {
              _dataPrevistaParto = DateTime.parse(dados['data_prevista']);
            }
          } else {
            _usarDPP = false;
            _dataPrevistaParto = null;
          }

          _carregando = false;
        });
      }
    }
  }

  Future<void> _alterarFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery); // Removemos imageQuality daqui, faremos no compress
    if (picked != null) {
      setState(() => _imagemSelecionada = picked);
    }
  }

  // --- CONVERSOR INTELIGENTE PARA BASE64 ---
  Future<String?> _converterParaBase64(XFile arquivo) async {
    // 1. WEB: Não precisa comprimir tanto, converte direto
    if (kIsWeb) {
      final bytes = await arquivo.readAsBytes();
      return base64Encode(bytes);
    }

    // 2. MOBILE: Comprime para não estourar o banco (Max 1MB)
    try {
      final File file = File(arquivo.path);
      List<int>? result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: 500, // Reduz resolução
        minHeight: 500,
        quality: 60,   // Reduz qualidade (60% é bom)
      );
      
      if (result != null) {
        return base64Encode(result);
      }
    } catch (e) {
      print("Erro ao comprimir: $e");
    }
    return null;
  }

  // --- VISUALIZADOR DE IMAGEM ---
  ImageProvider? _getImagemProvider() {
    // 1. Se acabou de selecionar uma foto (Preview)
    if (_imagemSelecionada != null) {
      if (kIsWeb) return NetworkImage(_imagemSelecionada!.path);
      return FileImage(File(_imagemSelecionada!.path));
    }

    // 2. Se tem imagem salva (URL, Path ou Base64)
    if (_imagemUrlAtual != null && _imagemUrlAtual!.isNotEmpty) {
      try {
        // Tenta decodificar Base64
        if (!_imagemUrlAtual!.startsWith('/') && !_imagemUrlAtual!.startsWith('http')) {
           Uint8List bytes = base64Decode(_imagemUrlAtual!);
           return MemoryImage(bytes);
        }
      } catch (e) {}

      // Web/URL
      if (kIsWeb || _imagemUrlAtual!.startsWith('http')) {
        return NetworkImage(_imagemUrlAtual!);
      }

      // Arquivo Local (Legado - com proteção)
      try {
        final file = File(_imagemUrlAtual!);
        if (file.existsSync()) return FileImage(file);
      } catch (e) {}
    }
    return null;
  }

  Future<void> _selecionarData({required bool isNascimento}) async {
    final dataInicial = isNascimento ? _dataNascimento : _dataPrevistaParto;
    final data = await showDatePicker(
      context: context,
      initialDate: dataInicial ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      helpText: isNascimento ? "DATA DE NASCIMENTO" : "DATA PREVISTA (DPP)",
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.teal)), child: child!),
    );
    
    if (data != null) {
      setState(() {
        if (isNascimento) {
          _dataNascimento = data;
        } else {
          _dataPrevistaParto = data;
        }
      });
    }
  }

  void _salvar() async {
    if (_idBebe == null || _nomeController.text.isEmpty || _dataNascimento == null) return;

    if (_usarDPP && _dataPrevistaParto == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor, informe a Data Prevista.")));
      return;
    }

    setState(() => _salvando = true); // Bloqueia botão e mostra loading

    Map<String, dynamic> updateData = {
      'nome': _nomeController.text,
      'data_parto': _dataNascimento!.toIso8601String(),
      'data_prevista': _usarDPP ? _dataPrevistaParto!.toIso8601String() : null,
    };

    // --- CONVERSÃO E SALVAMENTO DA FOTO ---
    if (_imagemSelecionada != null) {
      String? base64Foto = await _converterParaBase64(_imagemSelecionada!);
      if (base64Foto != null) {
        updateData['fotoUrl'] = base64Foto; // Salva o TEXTO da imagem no banco
      }
    }

    await BebeService.atualizarBebe(_idBebe!, updateData);
    
    if (mounted) {
      setState(() => _salvando = false);
      Navigator.pop(context, true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Perfil do Bebê"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _carregando 
        ? const Center(child: CircularProgressIndicator(color: Colors.teal))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // --- FOTO ---
                GestureDetector(
                  onTap: _alterarFoto,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _getImagemProvider(),
                        child: _getImagemProvider() == null 
                            ? const Icon(Icons.face, size: 60, color: Colors.grey) 
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                // --- NOME ---
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: "Nome do Bebê",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.child_care)
                  ),
                ),
                
                const SizedBox(height: 20),

                // --- DATA DE NASCIMENTO ---
                InkWell(
                  onTap: () => _selecionarData(isNascimento: true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Data de Nascimento",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake)
                    ),
                    child: Text(DateFormat('dd/MM/yyyy').format(_dataNascimento!)),
                  ),
                ),

                const SizedBox(height: 30),

                // --- SWITCH DPP ---
                SwitchListTile(
                  title: const Text("Informar Data Prevista do Parto?", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A))),
                  subtitle: const Text("Ative se o bebê nasceu antes ou depois de 40 semanas.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  value: _usarDPP,
                  activeThumbColor: Colors.teal,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() {
                      _usarDPP = val;
                      if (!val) _dataPrevistaParto = null;
                    });
                  },
                ),

                if (_usarDPP) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _selecionarData(isNascimento: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _dataPrevistaParto!=null ? Colors.orange : Colors.orange.shade200)
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event, color: Colors.orange),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Data Prevista (40 Semanas)", style: TextStyle(fontSize: 12, color: Colors.orange.shade800)),
                                const SizedBox(height: 4),
                                Text(
                                  _dataPrevistaParto == null 
                                    ? "Toque para selecionar" 
                                    : DateFormat('dd/MM/yyyy').format(_dataPrevistaParto!),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade900)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // --- CÓDIGO CONVITE ---
                if (_codigoAcesso != null)
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("CÓDIGO DE CONVITE", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(_codigoAcesso!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.teal)),
                          ],
                        ),
                        const Icon(Icons.share, color: Colors.teal),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                // --- BOTÃO SALVAR ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _salvando ? null : _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: _salvando 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SALVAR ALTERAÇÕES", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
    );
  }
}