import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para copiar código
import '../services/bebe_service.dart';
import 'tela_cadastro_bebe.dart';
import 'tela_base.dart';

class TelaSelecao extends StatefulWidget {
  const TelaSelecao({super.key});

  @override
  State<TelaSelecao> createState() => _TelaSelecaoState();
}

class _TelaSelecaoState extends State<TelaSelecao> {
  
  // --- MODAL PARA DIGITAR CÓDIGO ---
  void _abrirEntradaCodigo() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Entrar com Código"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Peça o código de convite para quem cadastrou o bebê."),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Código (ex: A7X2P9)",
                border: OutlineInputBorder()
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              try {
                await BebeService.entrarComCodigo(controller.text.trim());
                if (!ctx.mounted) return;
                
                Navigator.pop(ctx);
                
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const TelaBase()), 
                  (r) => false
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bebê vinculado com sucesso!")));
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text("Entrar")
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Bebês"), 
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // LISTA DE BEBÊS
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: BebeService.listarBebes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.teal));
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.child_care, size: 60, color: Colors.grey[300]), const Text("Nenhum bebê encontrado.")]));
                }

                final bebes = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bebes.length,
                  separatorBuilder: (_,__) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bebe = bebes[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.teal.shade50,
                          backgroundImage: bebe['fotoUrl'] != null ? NetworkImage(bebe['fotoUrl']) : null,
                          child: bebe['fotoUrl'] == null ? const Icon(Icons.face, color: Colors.teal) : null,
                        ),
                        title: Text(bebe['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text("Código: ${bebe['codigo_convite'] ?? '...'}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 20, color: Colors.teal),
                          tooltip: "Copiar Código",
                          onPressed: () {
                             Clipboard.setData(ClipboardData(text: bebe['codigo_convite']));
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Código copiado! Envie para o pai/mãe.")));
                          },
                        ),
                        onTap: () async {
                          try {
                            await BebeService.definirBebeAtivo(bebe['id']);
                            if (!context.mounted) return;

                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const TelaBase()),
                                (r) => false);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Erro: $e"),
                                  backgroundColor: Colors.red));
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // BOTÕES DE AÇÃO
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaCadastroBebe())),
                    icon: const Icon(Icons.add),
                    label: const Text("Cadastrar Novo Bebê"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _abrirEntradaCodigo,
                    icon: const Icon(Icons.group_add),
                    label: const Text("Entrar com Código de Convite"),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.teal, side: const BorderSide(color: Colors.teal)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}