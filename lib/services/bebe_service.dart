import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class BebeService {
  
  // Referência para a coleção raiz 'bebes'
  static final CollectionReference _bebesRef = FirebaseFirestore.instance.collection('bebes');

  // ===========================================================================
  // 1. CRIAR BEBÊ (Com suporte a DPP e Sync)
  // ===========================================================================
  static Future<void> adicionarBebe({
    required String nome,
    required DateTime dataParto,
    required String sexo,
    DateTime? dataPrevista,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuário não logado");

    String codigo = _gerarCodigoUnico();

    // Cria o documento na raiz
    DocumentReference docRef = await _bebesRef.add({
      'nome': nome,
      'data_parto': dataParto.toIso8601String(),
      'data_prevista': dataPrevista?.toIso8601String(), // Salva a DPP
      'sexo': sexo,
      'codigo_acesso': codigo,
      'criado_em': FieldValue.serverTimestamp(),
      'membros': [user.uid], 
      'admins': [user.uid],
    });

    // Define este como o bebê ativo localmente
    await setBebeAtivoLocal(docRef.id);
  }

  // ===========================================================================
  // 2. LISTAR (Busca onde sou membro)
  // ===========================================================================
  static Future<List<Map<String, dynamic>>> listarBebes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      // Busca oficial: Traz apenas os bebês onde sou membro
      final snapshot = await _bebesRef
          .where('membros', arrayContains: user.uid)
          .get();

      var lista = snapshot.docs.map((d) {
        var map = d.data() as Map<String, dynamic>;
        map['id'] = d.id;
        return map;
      }).toList();

      // Ordenação em memória (descendente)
      lista.sort((a, b) {
        var tA = a['criado_em'];
        var tB = b['criado_em'];
        DateTime dA = (tA is Timestamp) ? tA.toDate() : DateTime.now();
        DateTime dB = (tB is Timestamp) ? tB.toDate() : DateTime.now();
        return dB.compareTo(dA);
      });

      return lista;
    } catch (e) {
      debugPrint("Erro ao listar bebês: $e");
      return [];
    }
  }

  // ===========================================================================
  // 3. ENTRAR COM CÓDIGO (Sincronização Real)
  // ===========================================================================
  static Future<void> entrarComCodigo(String codigo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String codigoLimpo = codigo.trim().toUpperCase();

    final querySnapshot = await _bebesRef
        .where('codigo_acesso', isEqualTo: codigoLimpo)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception("Código inválido. Verifique se digitou corretamente.");
    }

    DocumentSnapshot docBebes = querySnapshot.docs.first;
    List<dynamic> membrosAtuais = docBebes['membros'] ?? [];

    if (membrosAtuais.contains(user.uid)) {
      await setBebeAtivoLocal(docBebes.id);
      return;
    }

    await _bebesRef.doc(docBebes.id).update({
      'membros': FieldValue.arrayUnion([user.uid])
    });

    await setBebeAtivoLocal(docBebes.id);
  }

  // ===========================================================================
  // 4. GESTÃO DO BEBÊ ATIVO (Localmente)
  // ===========================================================================
  
  static Future<void> setBebeAtivoLocal(String idBebe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ultimo_bebe_id', idBebe);
  }

  // Retorna a Referência (Para Streams e Gravações)
  static Future<DocumentReference?> getRefBebeAtivo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final prefs = await SharedPreferences.getInstance();
    String? idAtivo = prefs.getString('ultimo_bebe_id');

    // Tenta pegar o salvo localmente
    if (idAtivo != null) {
      try {
        // Verifica se ainda sou membro deste bebê (caso tenha sido removido)
        // Se der permissão negada aqui, assumimos que não podemos ler este doc específico
        final doc = await _bebesRef.doc(idAtivo).get();
        if (doc.exists) {
          List membros = doc['membros'] ?? [];
          // Fallback para 'criado_por' se 'membros' não existir
          if (membros.isEmpty && doc['criado_por'] == user.uid) {
             membros = [user.uid];
          }
          
          if (membros.contains(user.uid)) {
            return _bebesRef.doc(idAtivo);
          }
        }
      } catch (e) {
        debugPrint("⚠️ Erro ao verificar bebê ativo ($idAtivo): $e");
        // Se falhar a leitura direta (permissão), deixamos cair para o listarBebes
        // que agora tem lógica de fallback mais robusta.
      }
    }

    // Se não tem ou não sou mais membro, pega o primeiro da lista
    final lista = await listarBebes();
    if (lista.isNotEmpty) {
      String primeiroId = lista.first['id'];
      await setBebeAtivoLocal(primeiroId);
      return _bebesRef.doc(primeiroId);
    }

    return null;
  }
  
  static Future<bool> temBebesCadastrados() async {
    final lista = await listarBebes();
    return lista.isNotEmpty;
  }

  // ===========================================================================
  // 5. MÉTODOS DE COMPATIBILIDADE (PARA CORRIGIR OS ERROS)
  // ===========================================================================
  
  // Retorna os DADOS (Map) do bebê ativo (usado na TelaPrincipal e Perfil)
  static Future<Map<String, dynamic>?> lerBebeAtivo() async {
    final ref = await getRefBebeAtivo();
    if (ref == null) return null;

    final snapshot = await ref.get();
    if (snapshot.exists) {
      var dados = snapshot.data() as Map<String, dynamic>;
      dados['id'] = snapshot.id;
      return dados;
    }
    return null;
  }

  // Atualiza dados do bebê (usado na TelaPerfil)
  static Future<void> atualizarBebe(String idBebe, Map<String, dynamic> dados) async {
    await _bebesRef.doc(idBebe).update(dados);
  }

  // Alias para setBebeAtivoLocal (usado na TelaSelecao)
  static Future<void> definirBebeAtivo(String idBebe) async {
    await setBebeAtivoLocal(idBebe);
  }

  // ===========================================================================
  // 6. AUXILIARES
  // ===========================================================================
  
  static String _gerarCodigoUnico() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }
}