import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeederService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  static Future<void> povoarBancoCompleto() async {
    if (_uid == null) return;

    // 1. Bebê de 3 Meses (Recém-nascido saindo da extero-gestação)
    await _criarBebeFull(
      nome: "Miguel (3 Meses)",
      dataNascimento: DateTime.now().subtract(const Duration(days: 90)),
      sexo: "M",
      pesoNas: 3.2,
      alturaNas: 49,
      fase: "rn"
    );

    // 2. Bebê de 9 Meses (Introdução Alimentar e Engatinhar)
    await _criarBebeFull(
      nome: "Alice (9 Meses)",
      dataNascimento: DateTime.now().subtract(const Duration(days: 270)),
      sexo: "F",
      pesoNas: 3.0,
      alturaNas: 48,
      fase: "ia"
    );

    // 3. Bebê de 1 ano e 6 meses (Andando, Falando e Comendo tudo)
    await _criarBebeFull(
      nome: "Arthur (1a 6m)",
      dataNascimento: DateTime.now().subtract(const Duration(days: 540)),
      sexo: "M",
      pesoNas: 3.5,
      alturaNas: 50,
      fase: "toddler"
    );
  }

  static Future<void> _criarBebeFull({
    required String nome,
    required DateTime dataNascimento,
    required String sexo,
    required double pesoNas,
    required double alturaNas,
    required String fase, // 'rn', 'ia', 'toddler'
  }) async {
    // 1. Cria o Bebê
    String codigo = "TEST${Random().nextInt(9999)}";
    // CORREÇÃO: Usar coleção 'bebes' para bater com o BebeService
    DocumentReference bebeRef = await _db.collection('bebes').add({
      'nome': nome,
      'data_parto': dataNascimento.toIso8601String(),
      'sexo': sexo,
      'membros': [_uid], // Campo padrão do BebeService
      'admins': [_uid],  // Campo padrão do BebeService
      'criado_por': _uid,
      'cuidadores': [_uid],
      'codigo_convite': codigo,
      'codigo_acesso': codigo, // Alias para compatibilidade
      'fotoUrl': '', // Sem foto por enquanto
      'criado_em': FieldValue.serverTimestamp(),
    });

    // Vincula ao usuário
    await _db.collection('users').doc(_uid).collection('bebes_vinculados').doc(bebeRef.id).set({
      'id_bebe': bebeRef.id,
      'nome_cache': nome,
      'vinculado_em': DateTime.now().toIso8601String()
    });

    // 2. Gera Histórico de Crescimento (Mensal)
    int mesesVida = DateTime.now().difference(dataNascimento).inDays ~/ 30;
    for (int i = 0; i <= mesesVida; i++) {
      // Simulação de crescimento saudável
      double peso = pesoNas + (i * (i < 6 ? 0.8 : 0.4)); 
      double altura = alturaNas + (i * (i < 6 ? 2.5 : 1.0));
      
      await bebeRef.collection('medidas').add({
        'data': dataNascimento.add(Duration(days: i * 30)).toIso8601String(),
        'peso': double.parse(peso.toStringAsFixed(2)),
        'altura': double.parse(altura.toStringAsFixed(1)),
        'perimetro': 34 + (i * 0.5),
      });
    }

    // 3. Gera Vacinas (Lógica simplificada de calendário)
    List<String> vacinasTomadas = [];
    if (mesesVida >= 0) vacinasTomadas.addAll(['vac_bcr', 'vac_hep_b']); // Ao nascer
    if (mesesVida >= 2) vacinasTomadas.addAll(['vac_penta_1', 'vac_vip_1', 'vac_pneumo_1', 'vac_rota_1']);
    if (mesesVida >= 3) vacinasTomadas.addAll(['vac_meningo_c_1']);
    if (mesesVida >= 4) vacinasTomadas.addAll(['vac_penta_2', 'vac_vip_2', 'vac_pneumo_2', 'vac_rota_2']);
    if (mesesVida >= 6) vacinasTomadas.addAll(['vac_penta_3', 'vac_vip_3']);
    if (mesesVida >= 9) vacinasTomadas.addAll(['vac_febre_amarela']);
    if (mesesVida >= 12) vacinasTomadas.addAll(['vac_triplice_1', 'vac_pneumo_ref']);
    if (mesesVida >= 15) vacinasTomadas.addAll(['vac_hep_a', 'vac_tetra', 'vac_vop_1']);

    for (var v in vacinasTomadas) {
      await bebeRef.collection('vacinas').doc(v).set({
        'id': v,
        'tomadaEm': dataNascimento.add(const Duration(days: 60)).toIso8601String() // Data fictícia
      });
    }

    // 4. Rotina de Ontem (Para o Dashboard ficar bonito)
    DateTime ontem = DateTime.now().subtract(const Duration(days: 1));
    
    // Fraldas
    int qtdFraldas = fase == 'rn' ? 8 : (fase == 'ia' ? 6 : 4);
    for(int i=0; i<qtdFraldas; i++) {
      await bebeRef.collection('rotina').add({
        'tipo': 'fralda',
        'conteudo': i % 3 == 0 ? 'Coco' : 'Xixi',
        'data': ontem.add(Duration(hours: 8 + (i*2))).toIso8601String(),
      });
    }

    // Sono
    int sonecas = fase == 'rn' ? 4 : (fase == 'ia' ? 2 : 1);
    for(int i=0; i<sonecas; i++) {
      await bebeRef.collection('rotina').add({
        'tipo': 'sono',
        'duracao_segundos': fase == 'rn' ? 3600 : 5400, // 1h ou 1.5h
        'data': ontem.add(Duration(hours: 10 + (i*4))).toIso8601String(),
      });
    }

    // Alimentação (Se aplicável)
    if (fase != 'rn') {
      List<String> alimentos = ['Banana', 'Ovo', 'Brócolis', 'Carne Moída', 'Feijão'];
      for (var comida in alimentos) {
        await bebeRef.collection('alimentacao').add({
          'nome': comida,
          'categoria': 'Teste',
          'reacao': 'gostou',
          'ja_comeu': true,
          'data': ontem.toIso8601String()
        });
      }
    }

    // 5. Dentes (Se aplicável)
    if (fase == 'ia' || fase == 'toddler') {
      await bebeRef.collection('dentes').doc('i_central_esq').set({'data_nascimento': ontem.toIso8601String()});
      await bebeRef.collection('dentes').doc('i_central_dir').set({'data_nascimento': ontem.toIso8601String()});
    }
    if (fase == 'toddler') {
      await bebeRef.collection('dentes').doc('s_central_esq').set({'data_nascimento': ontem.toIso8601String()});
      await bebeRef.collection('dentes').doc('s_central_dir').set({'data_nascimento': ontem.toIso8601String()});
      await bebeRef.collection('dentes').doc('s_lateral_esq').set({'data_nascimento': ontem.toIso8601String()});
    }

    // 6. Diário
    await bebeRef.collection('diario').add({
      'texto': "Hoje foi um dia incrível! O desenvolvimento está a todo vapor.",
      'data': DateTime.now().toIso8601String(),
      'imagem': ''
    });
  }
}