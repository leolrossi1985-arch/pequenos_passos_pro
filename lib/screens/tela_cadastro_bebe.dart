import 'package:flutter/material.dart';
import '../services/bebe_service.dart';
import 'tela_base.dart';
import 'package:intl/intl.dart';

class TelaCadastroBebe extends StatefulWidget {
  const TelaCadastroBebe({super.key});

  @override
  State<TelaCadastroBebe> createState() => _TelaCadastroBebeState();
}

class _TelaCadastroBebeState extends State<TelaCadastroBebe> {
  final _nomeController = TextEditingController();
  
  // Dados principais
  DateTime? _dataNascimento;
  String _sexo = 'M'; // Padrão Masculino (M/F)
  
  // Lógica de Prematuridade
  bool _isPrematuro = false;
  DateTime? _dataPrevistaParto; // DPP (Só se for prematuro)

  bool _isLoading = false;

  // --- SELETOR DE DATAS ---
  Future<void> _selecionarData({required bool isNascimento}) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: isNascimento ? "DATA DE NASCIMENTO" : "DATA PREVISTA DO PARTO (DPP)",
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

  // --- FUNÇÃO 1: CRIAR DO ZERO ---
  void _salvar() async {
    if (_nomeController.text.isEmpty || _dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha o nome e a data de nascimento!")));
      return;
    }

    // Validação da DPP se for prematuro
    if (_isPrematuro && _dataPrevistaParto == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Informe a Data Prevista do Parto para o cálculo correto dos saltos.")));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Prepara os dados para enviar ao Service
      // Se NÃO for prematuro, a DPP é nula (ou igual ao nascimento, depende da sua lógica, mas nulo economiza espaço)
      final dppFinal = _isPrematuro ? _dataPrevistaParto : null;

      await BebeService.adicionarBebe(
        nome: _nomeController.text,
        dataParto: _dataNascimento!, // Data Real
        sexo: _sexo, 
        dataPrevista: dppFinal // <--- Novo campo enviado
      );
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const TelaBase()), 
          (route) => false
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
      setState(() => _isLoading = false);
    }
  }

  // --- FUNÇÃO 2: ENTRAR COM CÓDIGO ---
  void _entrarComCodigo() {
    final codigoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Vincular Bebê"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Digite o código de 6 letras fornecido pelo pai/mãe que criou o cadastro."),
            const SizedBox(height: 15),
            TextField(
              controller: codigoController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: "Código (ex: A7X2P9)",
                border: OutlineInputBorder(),
                counterText: "",
              ),
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            onPressed: () async {
              if (codigoController.text.length < 6) return;
              
              try {
                await BebeService.entrarComCodigo(codigoController.text.trim());
                if (mounted) {
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (_) => const TelaBase()), 
                    (r) => false
                  );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bebê vinculado com sucesso!")));
                }
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
              }
            },
            child: const Text("ENTRAR"),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Novo Bebê"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.child_friendly, size: 50, color: Colors.teal),
                ),
                const SizedBox(height: 30),
                
                // Nome
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: "Nome do Bebê",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.face),
                  ),
                ),
                const SizedBox(height: 15),

                // Sexo
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Menino"),
                        value: "M",
                        groupValue: _sexo,
                        activeColor: Colors.teal,
                        onChanged: (val) => setState(() => _sexo = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Menina"),
                        value: "F",
                        groupValue: _sexo,
                        activeColor: Colors.pink,
                        onChanged: (val) => setState(() => _sexo = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Data de Nascimento
                InkWell(
                  onTap: () => _selecionarData(isNascimento: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake, color: Colors.teal), // Ícone bolo
                        const SizedBox(width: 10),
                        Text(
                          _dataNascimento == null 
                              ? "Data de Nascimento" 
                              : DateFormat('dd/MM/yyyy').format(_dataNascimento!),
                          style: TextStyle(color: _dataNascimento == null ? Colors.grey[700] : Colors.black87, fontSize: 16)
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Switch Prematuro
                SwitchListTile(
                  title: const Text("Nasceu Prematuro?", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Importante para corrigir os saltos de desenvolvimento."),
                  value: _isPrematuro,
                  activeThumbColor: Colors.teal,
                  onChanged: (val) {
                    setState(() {
                      _isPrematuro = val;
                      if (!val) _dataPrevistaParto = null; // Limpa se desligar
                    });
                  },
                ),

                // Data Prevista (Só aparece se for prematuro)
                if (_isPrematuro)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      onTap: () => _selecionarData(isNascimento: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange.shade300), // Cor diferente para destacar
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.orange.shade50,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event, color: Colors.orange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _dataPrevistaParto == null 
                                    ? "Qual era a Data Prevista do Parto?" 
                                    : "Previsão era: ${DateFormat('dd/MM/yyyy').format(_dataPrevistaParto!)}",
                                style: TextStyle(color: _dataPrevistaParto == null ? Colors.orange[800] : Colors.black87, fontSize: 16)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 30),

                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _salvar,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, elevation: 5),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("CADASTRAR BEBÊ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 25),
                const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OU")), Expanded(child: Divider())]),
                const SizedBox(height: 25),

                // Botão Código
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: _entrarComCodigo,
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Tenho um Código de Convite"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}