import 'package:flutter/material.dart';

class Atividade {
  final String id;
  final String titulo;
  final String idadeAlvo;
  final String categoria;
  final String descricaoCurta;
  final String instrucoesCompletas;
  final String imagemUrl;
  final Color cor;
  final String tempo; // <--- CAMPO NOVO!

  Atividade({
    required this.id,
    required this.titulo,
    required this.idadeAlvo,
    required this.categoria,
    required this.descricaoCurta,
    required this.instrucoesCompletas,
    required this.imagemUrl,
    required this.cor,
    required this.tempo, // <--- OBRIGATÓRIO AGORA
  });

  factory Atividade.fromMap(String id, Map<String, dynamic> map) {
    return Atividade(
      id: id,
      titulo: map['titulo'] ?? '',
      idadeAlvo: map['idadeAlvo'] ?? '',
      categoria: map['categoria'] ?? '',
      descricaoCurta: map['descricaoCurta'] ?? '',
      instrucoesCompletas: map['instrucoesCompletas'] ?? '',
      imagemUrl: map['imagemUrl'] ?? '',
      // Se a cor vier como String (hex), converte. Se não, usa padrão.
      cor: Color(map['corHex'] ?? 0xFF009688),
      // Se não tiver tempo cadastrado, coloca um padrão para não quebrar
      tempo: map['tempo'] ?? 'Livre', 
    );
  }
}