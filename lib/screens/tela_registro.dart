import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/bebe_service.dart';
import 'tela_base.dart'; 

class TelaRegistro extends StatefulWidget {
  final String nomeBebe;
  final DateTime nascimentoBebe;
  final DateTime? dataPrevista;
  final String sexo;

  const TelaRegistro({
    super.key,
    required this.nomeBebe,
    required this.nascimentoBebe,
    this.dataPrevista,
    required this.sexo,
  });

  @override
  State<TelaRegistro> createState() => _TelaRegistroState();
}

class _TelaRegistroState extends State<TelaRegistro> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _criarConta() async {
    if (_emailController.text.isEmpty || _senhaController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("E-mail inválido ou senha curta (mín 6).")));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
      
      await BebeService.adicionarBebe(
        nome: widget.nomeBebe,
        dataParto: widget.nascimentoBebe,
        dataPrevista: widget.dataPrevista,
        sexo: widget.sexo,
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TelaBase()), 
          (route) => false
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Conta"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6A9C89),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      // CORREÇÃO: SingleChildScrollView para evitar overflow com teclado
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(Icons.lock_outline, size: 60, color: Color(0xFF6A9C89)),
            const SizedBox(height: 20),
            
            Text(
              "Para salvar a rotina de ${widget.nomeBebe}, crie sua conta segura.", 
              style: const TextStyle(fontSize: 16, color: Colors.grey), 
              textAlign: TextAlign.center
            ),
            
            const SizedBox(height: 40),
            
            TextField(
              controller: _emailController, 
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "E-mail", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined)
              )
            ),
            
            const SizedBox(height: 20),
            
            TextField(
              controller: _senhaController, 
              obscureText: true, 
              decoration: const InputDecoration(
                labelText: "Senha (mín 6 dígitos)", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key)
              )
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity, 
              height: 55, 
              child: ElevatedButton(
                onPressed: _isLoading ? null : _criarConta, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A9C89), 
                  foregroundColor: Colors.white,
                  elevation: 5
                ), 
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("FINALIZAR CADASTRO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
              )
            ),
          ],
        ),
      ),
    );
  }
}