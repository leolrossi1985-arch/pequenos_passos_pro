import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

// --- REMOVI O IMPORT DO ARQUIVO APAGADO (conteudo_real.dart) ---
// Agora usamos apenas os novos:
import '../data/conteudo_atividades.dart'; // <--- Agora usa a lista nova
import '../data/conteudo_alimentos.dart'; 
import '../data/conteudo_marcos_completo.dart'; 
import '../data/conteudo_saltos.dart'; 

import '../services/conteudo_service.dart';
import '../services/seeder_service.dart';

class TelaAdmin extends StatefulWidget {
  const TelaAdmin({super.key});

  @override
  State<TelaAdmin> createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
  bool _salvando = false;

  // ===========================================================================
  // 1. ATIVIDADES (IMPORTAR / EXPORTAR)
  // ===========================================================================

  void _atualizarAtividades() async {
    setState(() => _salvando = true);
    try {
      // CORREÇÃO AQUI: Mudamos de 'brincadeirasReais' para 'atividadesLocais'
      await ConteudoService.atualizarColecaoCompleta('atividades', atividadesLocais);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sucesso! Atividades (Locais) enviadas para o BD.")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _exportarAtividadesDoBanco() async {
    setState(() => _salvando = true);
    print("⏳ Iniciando exportação de atividades...");
    
    try {
      final snapshot = await FirebaseFirestore.instance.collection('atividades').get();
      StringBuffer sb = StringBuffer();
      
      sb.writeln('// ATIVIDADES ZELO - VERSÃO LOCAL');
      sb.writeln('final List<Map<String, dynamic>> atividadesLocais = [');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        sb.writeln('  {');
        sb.writeln('    "id": "${doc.id}",'); 
        
        data.forEach((key, value) {
          if (value is String) {
            String valorLimpo = value
                .replaceAll('\n', '\\n')
                .replaceAll('"', '\\"')
                .replaceAll('\$', '\\\$');
            sb.writeln('    "$key": "$valorLimpo",');
          } else if (value is int || value is double || value is bool) {
            sb.writeln('    "$key": $value,');
          }
        });
        sb.writeln('  },');
      }
      sb.writeln('];');

      await Clipboard.setData(ClipboardData(text: sb.toString()));

      if (mounted) {
        showDialog(
          context: context, 
          builder: (ctx) => AlertDialog(
            title: const Text("Sucesso!"),
            content: const Text("Código copiado! Cole no arquivo 'conteudo_atividades.dart'."),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
          )
        );
      }

    } catch (e) {
      print("Erro: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao exportar: $e")));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  // ===========================================================================
  // 2. ALIMENTOS
  // ===========================================================================

  void _atualizarAlimentos() async {
    setState(() => _salvando = true);
    try {
      await ConteudoService.atualizarColecaoCompleta('biblioteca_alimentos', alimentosIniciais);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sucesso! Alimentos enviados para o BD.")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _exportarAlimentosDoBanco() async {
    setState(() => _salvando = true);
    try {
      final snapshot = await FirebaseFirestore.instance.collection('biblioteca_alimentos').get();
      StringBuffer sb = StringBuffer();
      
      sb.writeln('final List<Map<String, dynamic>> alimentosIniciais = [');
      for (var doc in snapshot.docs) {
        final data = doc.data();
        sb.writeln('  {');
        data.forEach((key, value) {
          if (value is String) {
            String valorLimpo = value.replaceAll('\n', '\\n').replaceAll('"', '\\"').replaceAll('\$', '\\\$');
            sb.writeln('    "$key": "$valorLimpo",');
          } else {
            sb.writeln('    "$key": $value,');
          }
        });
        sb.writeln('  },');
      }
      sb.writeln('];');

      await Clipboard.setData(ClipboardData(text: sb.toString()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alimentos copiados! Dê Ctrl+V no arquivo.")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  // ===========================================================================
  // 3. OUTROS
  // ===========================================================================

  void _atualizarMarcos() async {
    setState(() => _salvando = true);
    try {
      await ConteudoService.atualizarColecaoCompleta('marcos_desenvolvimento', marcosCompletos);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sucesso! Marcos atualizados.")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _atualizarSaltos() async {
    setState(() => _salvando = true);
    try {
      await ConteudoService.atualizarColecaoCompleta('saltos_desenvolvimento', saltosDetalhados);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sucesso! Saltos atualizados."), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _gerarBebesFicticios() async {
    setState(() => _salvando = true);
    try {
      await SeederService.povoarBancoCompleto();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sucesso! Bebês criados.")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Admin - ZELO"), 
        backgroundColor: Colors.blueGrey, 
        foregroundColor: Colors.white
      ),
      body: Center(
        child: _salvando 
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Processando... aguarde.")
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("GESTÃO DE CONTEÚDO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 20),

                  // 1. ATIVIDADES
                  Row(
                    children: [
                      Expanded(child: _buildBotao(Icons.upload, "Enviar Ativ.", Colors.teal.shade200, _atualizarAtividades)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildBotao(Icons.copy, "Copiar Ativ. do BD", Colors.teal, _exportarAtividadesDoBanco)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // 2. ALIMENTOS
                  Row(
                    children: [
                      Expanded(child: _buildBotao(Icons.upload, "Enviar Alim.", Colors.green.shade200, _atualizarAlimentos)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildBotao(Icons.copy, "Copiar Alim. do BD", Colors.green, _exportarAlimentosDoBanco)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // 3. OUTROS
                  _buildBotao(Icons.list_alt, "Atualizar Marcos (CDC)", Colors.purple, _atualizarMarcos),
                  const SizedBox(height: 15),

                  _buildBotao(Icons.flash_on, "Atualizar Saltos (WW)", Colors.amber.shade800, _atualizarSaltos),

                  const SizedBox(height: 40),
                  const Divider(),
                  const Text("TESTE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  
                  _buildBotao(Icons.people_alt, "Gerar Bebês Fictícios", Colors.orange, _gerarBebesFicticios),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildBotao(IconData icon, String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, 
          foregroundColor: Colors.white, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }
}