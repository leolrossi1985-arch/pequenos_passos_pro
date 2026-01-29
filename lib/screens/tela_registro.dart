import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/bebe_service.dart';
import 'tela_login.dart'; // Precisa importar a TelaLogin para redirecionar

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

  // Função auxiliar para validar e-mail básico
  bool _emailValido(String email) {
    return email.contains('@') && email.contains('.') && email.length > 5;
  }

  Future<void> _criarConta() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    // 1. Validação local (Nível 1)
    if (!_emailValido(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, digite um e-mail válido."))
      );
      return;
    }

    if (senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A senha deve ter pelo menos 6 caracteres."))
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 2. Cria a conta no Firebase
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      // 3. Salva os dados do bebê no banco
      await BebeService.adicionarBebe(
        nome: widget.nomeBebe,
        dataParto: widget.nascimentoBebe,
        dataPrevista: widget.dataPrevista,
        sexo: widget.sexo,
      );

      // 4. Envia e-mail de verificação (Nível 2)
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        
        if (mounted) {
          // Exibe alerta e manda para Login
          showDialog(
            context: context,
            barrierDismissible: false, // Obriga a clicar no botão
            builder: (ctx) => AlertDialog(
              title: const Text("Verifique seu E-mail"),
              content: Text("Conta criada com sucesso!\n\nEnviamos um link de confirmação para $email.\n\nPor favor, confirme seu e-mail antes de fazer login."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Fecha Dialog
                    // Redireciona para Tela de Login (para forçar o login após verificar)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const TelaLogin()), 
                      (route) => false
                    );
                  },
                  child: const Text("Entendi, ir para Login"),
                )
              ],
            )
          );
        }
      } else {
        // Caso raro onde não precisa verificar (ex: auth social), entra direto (se quiser)
        // Mas por segurança, melhor mandar pro login sempre nesse fluxo pago.
        if (mounted) {
           Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const TelaLogin()), 
            (route) => false
          );
        }
      }

    } on FirebaseAuthException catch (e) {
      String msg = "Erro ao criar conta.";
      if (e.code == 'email-already-in-use') {
        msg = "Este e-mail já está cadastrado.";
      } else if (e.code == 'invalid-email') {
        msg = "E-mail inválido.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                prefixIcon: Icon(Icons.email_outlined),
                hintText: "exemplo@email.com"
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