import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; 
import 'package:intl/intl.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'tela_login.dart';
import 'tela_base.dart'; 
import '../services/bebe_service.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _notificacoesAtivas = true;

  @override
  void initState() {
    super.initState();
    _carregarPreferencias();
  }

  void _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificacoesAtivas = prefs.getBool('notificacoes_ativas') ?? true;
    });
  }

  void _toggleNotificacoes(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificacoes_ativas', valor);
    setState(() => _notificacoesAtivas = valor);
  }

  // --- AÇÕES DO BEBÊ ---

  void _copiarCodigo(String codigo) {
    Clipboard.setData(ClipboardData(text: codigo));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código copiado para a área de transferência!")),
      );
    }
  }

  Future<void> _trocarBebe(String idBebe, String nome) async {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (c) => const Center(child: CircularProgressIndicator())
    );
    
    await BebeService.definirBebeAtivo(idBebe);
    
    if (mounted) {
      Navigator.pop(context); // Fecha o loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Agora cuidando de $nome!"), backgroundColor: Colors.teal)
      );
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const TelaBase()), 
        (route) => false
      );
    }
  }

  // --- MODAL DE CADASTRO (COM DPP) ---
  void _abrirCadastroNovoBebe() {
    final nomeController = TextEditingController();
    DateTime dataNascimento = DateTime.now();
    DateTime? dataPrevista;
    String sexoSelecionado = 'M';
    bool usarDPP = false;

    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (builderContext, setStateModal) {
          return Padding(
            padding: EdgeInsets.only(
              top: 24, 
              left: 24, 
              right: 24, 
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Novo Bebê", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: nomeController,
                    decoration: InputDecoration(
                      labelText: "Nome do Bebê",
                      prefixIcon: const Icon(Icons.child_care, color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 15),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Data de Nascimento"),
                    subtitle: Text(DateFormat("dd/MM/yyyy").format(dataNascimento), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.calendar_today, color: Colors.teal),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context, 
                        initialDate: dataNascimento, 
                        firstDate: DateTime(2020), 
                        lastDate: DateTime.now()
                      );
                      if (d != null) setStateModal(() => dataNascimento = d);
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text("Informar Data Prevista (DPP)?", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Essencial para prematuros.", style: TextStyle(fontSize: 12)),
                    contentPadding: EdgeInsets.zero,
                    value: usarDPP,
                    activeColor: Colors.teal,
                    onChanged: (val) {
                      setStateModal(() {
                        usarDPP = val;
                        if (!val) dataPrevista = null;
                        else dataPrevista = dataNascimento; 
                      });
                    },
                  ),

                  if (usarDPP)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Data Prevista do Parto"),
                      subtitle: Text(
                        dataPrevista == null ? "Selecione" : DateFormat("dd/MM/yyyy").format(dataPrevista!), 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)
                      ),
                      trailing: const Icon(Icons.event, color: Colors.orange),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context, 
                          initialDate: dataPrevista ?? DateTime.now(), 
                          firstDate: DateTime(2020), 
                          lastDate: DateTime(2030),
                          helpText: "DATA PREVISTA DO PARTO"
                        );
                        if (d != null) setStateModal(() => dataPrevista = d);
                      },
                    ),

                  const Divider(),
                  
                  const Text("Sexo", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile(
                          title: const Text("Menino"),
                          value: 'M',
                          groupValue: sexoSelecionado,
                          activeColor: Colors.teal,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => setStateModal(() => sexoSelecionado = v.toString()),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile(
                          title: const Text("Menina"),
                          value: 'F',
                          groupValue: sexoSelecionado,
                          activeColor: Colors.pink,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => setStateModal(() => sexoSelecionado = v.toString()),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nomeController.text.isEmpty) return;
                        if (usarDPP && dataPrevista == null) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Informe a DPP.")));
                           return;
                        }
                        
                        Navigator.pop(sheetContext); 
                        
                        showDialog(
                          context: context, 
                          barrierDismissible: false, 
                          builder: (c) => const Center(child: CircularProgressIndicator())
                        ); 

                        try {
                          await BebeService.adicionarBebe(
                            nome: nomeController.text.trim(),
                            dataParto: dataNascimento,
                            dataPrevista: usarDPP ? dataPrevista : null,
                            sexo: sexoSelecionado
                          );

                          if (mounted) {
                            Navigator.of(context).pop(); 
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bebê cadastrado com sucesso!"), backgroundColor: Colors.green));
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("CADASTRAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _exibirDialogoEntrar() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Digitar Código"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Insira o código de 6 dígitos gerado no celular do outro responsável:"),
            const SizedBox(height: 15),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Ex: A7X9B2", border: OutlineInputBorder(), filled: true),
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A9C89), foregroundColor: Colors.white),
            onPressed: () async {
              FocusScope.of(context).unfocus(); 
              Navigator.pop(ctx); 
              showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
              try {
                await BebeService.entrarComCodigo(controller.text.trim());
                if (mounted) {
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sucesso! Bebê adicionado."), backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: ${e.toString().replaceAll('Exception:', '')}"), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text("Entrar"),
          )
        ],
      ),
    );
  }

  Future<void> _abrirLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Não foi possível abrir o link.")));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const TelaLogin()), (r) => false);
    }
  }

  Future<void> _excluirConta() async {
    bool confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Conta?"),
        content: const Text("Tem certeza? Isso apagará TODOS os seus dados permanentemente. Essa ação não pode ser desfeita."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("EXCLUIR TUDO", style: TextStyle(color: Colors.white))
          ),
        ],
      )
    ) ?? false;

    if (confirmar) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(_user!.uid).delete();
        await _user!.delete();
        if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const TelaLogin()), (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Conta excluída.")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: Faça login novamente para excluir. ($e)")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F5), 
      appBar: AppBar(
        title: const Text("Configurações"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("CONTA", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.teal.shade50, child: const Icon(Icons.person, color: Colors.teal)),
              title: Text(_user?.email ?? "Usuário"),
              subtitle: const Text("Logado via E-mail"),
            ),
          ),

          const SizedBox(height: 25),

          const Text("GERENCIAMENTO DA FAMÍLIA", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          
          StreamBuilder<QuerySnapshot>(
            // --- AQUI ESTAVA O ERRO ---
            // Antes: collection('users').doc(uid).collection('bebes') <- ERRADO
            // Agora: collection('bebes').where('membros', arrayContains: uid) <- CERTO (Arquitetura compartilhada)
            stream: FirebaseFirestore.instance
                .collection('bebes')
                .where('membros', arrayContains: _user?.uid)
                .orderBy('criado_em', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              
              List<Widget> childrenGerenciamento = [];

              if (snapshot.hasData) {
                final bebes = snapshot.data!.docs;
                
                if (bebes.isEmpty) {
                   childrenGerenciamento.add(const Padding(padding: EdgeInsets.all(15), child: Text("Nenhum bebê cadastrado.")));
                }

                for (var doc in bebes) {
                  final dados = doc.data() as Map<String, dynamic>;
                  final nome = dados['nome'] ?? 'Bebê';
                  final codigo = dados['codigo_acesso'] ?? '---';
                  
                  // Verifica se este é o bebê ativo lendo do SharedPreferences ou apenas visualmente
                  // Como o StreamBuilder rebuilda, podemos checar visualmente se quisermos, 
                  // mas aqui vamos apenas listar. O "ativo" visual pode ser feito se lermos o ID do service.
                  // Para simplificar, vou deixar sem o check verde por enquanto ou você pode carregar o ID ativo no initState.
                  
                  childrenGerenciamento.add(
                    ListTile(
                      leading: const Icon(Icons.child_care, color: Colors.teal),
                      title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      subtitle: Text("Cód: $codigo"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.copy, size: 20, color: Colors.grey), tooltip: "Copiar Código", onPressed: () => _copiarCodigo(codigo)),
                        ],
                      ),
                      onTap: () => _trocarBebe(doc.id, nome),
                    )
                  );
                  childrenGerenciamento.add(const Divider(height: 1));
                }
              } else if (snapshot.hasError) {
                 childrenGerenciamento.add(Padding(padding: const EdgeInsets.all(15), child: Text("Erro ao carregar: ${snapshot.error}")));
              } else {
                 childrenGerenciamento.add(const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())));
              }

              // --- BOTÕES DE ADIÇÃO ---
              
              childrenGerenciamento.add(
                ListTile(
                  leading: const Icon(Icons.add_circle, color: Colors.orange),
                  title: const Text("Cadastrar Novo Bebê"),
                  subtitle: const Text("Adicionar irmão(ã)"),
                  onTap: _abrirCadastroNovoBebe, 
                )
              );
              childrenGerenciamento.add(const Divider(height: 1));

              childrenGerenciamento.add(
                ListTile(
                  leading: const Icon(Icons.group_add, color: Colors.teal),
                  title: const Text("Entrar com Código"),
                  subtitle: const Text("Juntar-se a uma família existente"),
                  onTap: _exibirDialogoEntrar,
                )
              );
              childrenGerenciamento.add(const Divider(height: 1));

              childrenGerenciamento.add(
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active, color: Colors.blue),
                  title: const Text("Notificações"),
                  value: _notificacoesAtivas,
                  activeColor: Colors.teal,
                  onChanged: _toggleNotificacoes,
                )
              );

              return Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(children: childrenGerenciamento),
              );
            },
          ),

          const SizedBox(height: 25),
          
          // --- LEGAL ---
          const Text("SOBRE O APP", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
           const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Colors.grey),
                  title: const Text("Política de Privacidade"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _abrirLink('https://sites.google.com/view/zelo-privacidade'), 
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colors.grey),
                  title: const Text("Termos de Uso"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => _abrirLink('https://sites.google.com/view/zelo-privacidade'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text("Sair da Conta"),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), foregroundColor: Colors.teal),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _excluirConta,
            child: const Text("Excluir minha conta permanentemente", style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}