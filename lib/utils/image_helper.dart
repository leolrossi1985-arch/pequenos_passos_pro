import 'dart:convert';
import 'package:flutter/material.dart';

class ImageHelper {
  // Converte a String Base64 vinda do banco em uma Imagem visível
  static ImageProvider base64ToImage(String base64String) {
    try {
      // Remove cabeçalhos de data URI se existirem (ex: "data:image/png;base64,")
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      return MemoryImage(base64Decode(base64String));
    } catch (e) {
      // Se der erro, retorna uma imagem transparente ou placeholder
      return const NetworkImage("https://placehold.co/400x400?text=Erro+Imagem");
    }
  }
}