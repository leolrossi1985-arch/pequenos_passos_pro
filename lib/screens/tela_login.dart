import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'tela_base.dart'; 
import 'tela_onboarding.dart'; // Importante para mandar quem não tem conta

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

  // --- TRAVA DE SEGURANÇA: E-MAIL VERIFICADO ---
  Future<bool> _checarEmailVerificado(User user) async {
    // Atualiza o status do usuário (caso ele tenha acabado de clicar no link)
    await user.reload();
    final updatedUser = FirebaseAuth.instance.currentUser;

    if (updatedUser != null && !updatedUser.emailVerified) {
      await FirebaseAuth.instance.signOut(); // Desloga imediatamente
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("E-mail não verificado"),
            content: Text("Para sua segurança, você precisa confirmar o e-mail enviado para:\n\n${updatedUser.email}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), 
                child: const Text("OK")
              ),
              TextButton(
                onPressed: () async {
                  await updatedUser.sendEmailVerification();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link reenviado! Verifique seu e-mail.")));
                }, 
                child: const Text("Reenviar E-mail")
              )
            ],
          )
        );
      }
      return false; // Bloqueado
    }
    return true; // Liberado
  }

  Future<void> _autenticarEmail() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // Tenta logar
      UserCredential cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      // Se logou, checa se o e-mail é real
      if (cred.user != null) {
        bool liberado = await _checarEmailVerificado(cred.user!);
        if (liberado) {
          _irParaHome(); 
        }
      }

    } on FirebaseAuthException catch (e) {
      String msg = "Erro ao fazer login.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = "E-mail ou senha incorretos.";
      } else if (e.code == 'invalid-email') {
        msg = "Formato de e-mail inválido.";
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _autenticarGoogle() async {
    setState(() => _isLoading = true);
    try {
      // 1. FLUXO WEB (Pop-up nativo do Firebase)
      if (kIsWeb) {
        UserCredential cred = await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
        if (cred.user != null) {
          _irParaHome();
        }
        return;
      }

      // 2. FLUXO MOBILE (Google Sign In Plugin)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, 
        idToken: googleAuth.idToken,
      );
      
      UserCredential cred = await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Google geralmente já verifica o e-mail, mas é bom garantir
      if (cred.user != null) {
         _irParaHome();
      }

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro Google: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _irParaCadastro() {
    // Redireciona para o Onboarding ou Registro, pois o registro requer dados do bebê
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TelaOnboarding()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A9C89),
        elevation: 0,
        // Removemos o botão de voltar se for a tela inicial, ou mantemos se veio do Paywall
        leading: Navigator.canPop(context) 
          ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop())
          : null,
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
                // Ícone/Logo
                Image.asset(
                  'assets/icon.png', 
                  height: 100,      
                  fit: BoxFit.contain,
                  errorBuilder: (c,e,s) => const Icon(Icons.baby_changing_station, size: 80, color: Colors.white), // Fallback
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
                      const Text(
                        "Fazer Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3A3A)),
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
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            if (_emailController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Digite seu e-mail para recuperar a senha.")));
                              return;
                            }
                            try {
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("E-mail de recuperação enviado!")));
                            } catch(e) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao enviar e-mail.")));
                            }
                          },
                          child: const Text("Esqueci minha senha", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ),

                      const SizedBox(height: 10),

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
                                child: const Text("ENTRAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                icon: Image.network('https://img.icons8.com/color/48/google-logo.png', height: 24, errorBuilder: (c,e,s) => const Icon(Icons.g_mobiledata)),
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
                      
                      // BOTÃO PARA IR PARA O CADASTRO (ONBOARDING)
                      TextButton(
                        onPressed: _irParaCadastro,
                        child: RichText(
                          text: const TextSpan(
                            text: "Não tem conta? ",
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: "Começar Agora",
                                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
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