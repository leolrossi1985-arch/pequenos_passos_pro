import 'dart:io';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/bebe_service.dart';
import '../utils/image_helper.dart'; 

class TelaDiario extends StatefulWidget {
  const TelaDiario({super.key});

  @override
  State<TelaDiario> createState() => _TelaDiarioState();
}

class _TelaDiarioState extends State<TelaDiario> {
  
  void _novoPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: const _ModalNovoPost(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      // AppBar removida pois o header flutuante da RotinaHub já faz esse papel
      
      // --- CORREÇÃO AQUI: POSIÇÃO DO BOTÃO ---
      // Aumentado para 140 para flutuar acima da barra de navegação da TelaBase
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 140), 
        child: FloatingActionButton.extended(
          onPressed: _novoPost,
          backgroundColor: const Color(0xFFE88D67),
          elevation: 4,
          icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
          label: const Text("Registrar Momento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
      ),
      
      body: FutureBuilder<DocumentReference?>(
        future: BebeService.getRefBebeAtivo(),
        builder: (context, snapshotRef) {
          if (snapshotRef.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          
          final bebeRef = snapshotRef.data;

          if (bebeRef == null) {
             return const Center(child: Text("Nenhum bebê selecionado."));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: bebeRef.collection('diario').orderBy('data', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                 return const Center(child: CircularProgressIndicator(color: Colors.teal));
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              // LISTA COM TIMELINE
              return ListView.builder(
                // Padding inferior generoso para o último item não ficar escondido
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 160),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final dataMap = doc.data() as Map<String, dynamic>;
                  final isLast = index == snapshot.data!.docs.length - 1;
                  
                  return _buildTimelineItem(doc.id, dataMap, isLast);
                },
              );
            },
          );
        }
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
            child: Icon(Icons.auto_stories_rounded, size: 60, color: Colors.teal.shade100),
          ),
          const SizedBox(height: 20),
          const Text("O diário está esperando...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("Registre o primeiro sorriso!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // --- ITEM DA TIMELINE (DESIGN PREMIUM) ---
  Widget _buildTimelineItem(String id, Map<String, dynamic> dados, bool isLast) {
    final DateTime data = DateTime.parse(dados['data']);
    final String texto = dados['texto'] ?? "";
    
    // Tratamento de Imagem
    String? base64Img = dados['imagemBase64'];
    String? localPath = dados['imagem']; 
    ImageProvider? imageProvider;
    
    if (base64Img != null && base64Img.isNotEmpty) {
      try { imageProvider = ImageHelper.base64ToImage(base64Img); } catch (e) { print("Erro imagem: $e"); }
    } else if (localPath != null && localPath.isNotEmpty) {
      if (kIsWeb) {
        imageProvider = NetworkImage(localPath);
      } else if (File(localPath).existsSync()) imageProvider = FileImage(File(localPath));
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // COLUNA DA DATA (ESQUERDA)
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(DateFormat("dd").format(data), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A))),
                Text(DateFormat("MMM").format(data).toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.withOpacity(0.2)))
              ],
            ),
          ),
          
          // CONTEÚDO (DIREITA)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CABEÇALHO DO POST
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat("HH:mm").format(data), style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
                          PopupMenuButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.more_horiz, color: Colors.grey.shade400),
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, color: Colors.red, size: 20), SizedBox(width: 10), Text("Excluir")]))
                            ],
                            onSelected: (v) async {
                              if(v == 'delete') {
                                 final ref = await BebeService.getRefBebeAtivo();
                                 ref?.collection('diario').doc(id).delete();
                              }
                            },
                          )
                        ],
                      ),
                    ),

                    // IMAGEM (HERO)
                    if (imageProvider != null)
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _TelaImagemFull(imagem: imageProvider!))),
                        child: Container(
                          width: double.infinity,
                          height: 220, // Altura fixa elegante
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),

                    // LEGENDA
                    if (texto.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(texto, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF455A64))),
                      ),
                      
                    if ((imageProvider == null) && texto.isEmpty)
                       const Padding(padding: EdgeInsets.all(20), child: Text("...", style: TextStyle(color: Colors.grey))),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ModalNovoPost extends StatefulWidget {
  const _ModalNovoPost();
  @override
  State<_ModalNovoPost> createState() => _ModalNovoPostState();
}

class _ModalNovoPostState extends State<_ModalNovoPost> {
  final _textoController = TextEditingController();
  XFile? _imagem;
  bool _salvando = false;

  Future<void> _tirarFoto(bool camera) async {
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery, 
        imageQuality: 30, // Compressão para performance
        maxWidth: 1024, 
      );
      if (!mounted) return;
      if (picked != null) setState(() => _imagem = picked);
    } catch (e) {}
  }

  void _salvar() async {
    if (_textoController.text.isEmpty && _imagem == null) return;
    setState(() => _salvando = true);

    try {
      final ref = await BebeService.getRefBebeAtivo();
      if (ref != null) {
        String base64String = "";
        if (_imagem != null) {
           final bytes = await _imagem!.readAsBytes();
           base64String = base64Encode(bytes);
        }

        await ref.collection('diario').add({
          'texto': _textoController.text,
          'imagemBase64': base64String,
          'data': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar. Tente uma imagem menor.")));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Novo Momento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D3A3A))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey))
              ],
            ),
            const SizedBox(height: 20),
            
            // ÁREA DE IMAGEM
            GestureDetector(
              onTap: () {
                 if (_imagem == null) _tirarFoto(false); // Abre galeria se vazio
              },
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: _imagem == null ? Border.all(color: Colors.grey.shade300, style: BorderStyle.solid) : null,
                  image: _imagem != null ? DecorationImage(image: kIsWeb ? NetworkImage(_imagem!.path) : FileImage(File(_imagem!.path)) as ImageProvider, fit: BoxFit.cover) : null
                ),
                child: _imagem == null 
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text("Adicionar Foto", style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold))
                      ],
                    )
                  : null,
              ),
            ),
            
            if (_imagem != null)
               Padding(
                 padding: const EdgeInsets.only(top: 10),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     TextButton.icon(onPressed: () => _tirarFoto(true), icon: const Icon(Icons.camera_alt, size: 16), label: const Text("Câmera")),
                     TextButton.icon(onPressed: () => _tirarFoto(false), icon: const Icon(Icons.photo_library, size: 16), label: const Text("Trocar")),
                   ],
                 ),
               ),

            const SizedBox(height: 20),
            
            TextField(
              controller: _textoController,
              decoration: InputDecoration(
                hintText: "Como foi esse momento especial?",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            
            const SizedBox(height: 24),
            
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3A3A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: _salvando ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("SALVAR NO DIÁRIO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _TelaImagemFull extends StatelessWidget {
  final ImageProvider imagem;
  const _TelaImagemFull({required this.imagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, 
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, 
          minScale: 0.5,
          maxScale: 4.0, 
          child: Image(image: imagem),
        ),
      ),
    );
  }
}