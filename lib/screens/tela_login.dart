import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'tela_base.dart'; 

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '85796774768-q6bchg7eheg6un9bn7rgek2fvtm9ogmk.apps.googleusercontent.com' : null, 
    scopes: ['email'],
  );
  
  bool _isLogin = true; 
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _irParaHome() {
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const TelaBase()),
        (route) => false,
      );
    }
  }

  Future<void> _autenticarEmail() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text.trim(),
        );
      }
      _irParaHome(); 
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: ${e.message}"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _autenticarGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (kIsWeb && googleAuth.idToken == null) {
          throw FirebaseAuthException(code: 'token-null', message: "Erro de configuração Web.");
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, 
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _irParaHome();

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro Google: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A9C89),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A9C89), Color(0xFF4E8D7C)], 
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- AQUI ESTÁ A MUDANÇA PARA O SEU ÍCONE ---
                Image.asset(
                  'assets/icon.png', // Caminho exato
                  height: 100,       // Tamanho do ícone
                  fit: BoxFit.contain,
                ),
                
                const SizedBox(height: 10),
                const Text(
                  "ZELO",
                  style: TextStyle(
                    fontSize: 48, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white, 
                    letterSpacing: 5,
                    fontFamily: 'Nunito' 
                  ),
                ),
                const Text(
                  "Cuidado que transforma",
                  style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2),
                ),
                
                const SizedBox(height: 40),

                // --- CARD DO FORMULÁRIO ---
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isLogin ? "Bem-vindo(a)!" : "Criar Família",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)),
                      ),
                      const SizedBox(height: 30),
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.teal),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _senhaController,
                        decoration: InputDecoration(
                          labelText: "Senha",
                          prefixIcon: const Icon(Icons.lock_outlined, color: Colors.teal),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                        obscureText: true,
                      ),
                      
                      const SizedBox(height: 25),

                      if (_isLoading) 
                        const Center(child: CircularProgressIndicator(color: Colors.teal)) 
                      else 
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _autenticarEmail,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A9C89),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                                child: Text(_isLogin ? "ENTRAR" : "CADASTRAR", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OU", style: TextStyle(color: Colors.grey, fontSize: 12))), Expanded(child: Divider())]),
                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _autenticarGoogle,
                                icon: Image.network('https://img.icons8.com/color/48/google-logo.png', height: 24),
                                label: const Text("Entrar com Google"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                      
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: RichText(
                          text: TextSpan(
                            text: _isLogin ? "Não tem conta? " : "Já tem conta? ",
                            style: const TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: _isLogin ? "Cadastre-se" : "Faça Login",
                                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                              )
                            ]
                          ),
                        ),
                      )
                    ],
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