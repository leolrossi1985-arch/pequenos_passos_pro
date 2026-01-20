import 'package:shared_preferences/shared_preferences.dart';

class FavoritosService {
  // Salva ou Remove um ID da lista
  static Future<void> alternarFavorito(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final listaAtual = prefs.getStringList('meus_favoritos') ?? [];

    if (listaAtual.contains(id)) {
      listaAtual.remove(id); // Se já tem, remove
    } else {
      listaAtual.add(id); // Se não tem, adiciona
    }

    await prefs.setStringList('meus_favoritos', listaAtual);
  }

  // Verifica se um ID específico é favorito
  static Future<bool> isFavorito(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final listaAtual = prefs.getStringList('meus_favoritos') ?? [];
    return listaAtual.contains(id);
  }

  // Retorna a lista completa de IDs favoritos
  static Future<List<String>> lerFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('meus_favoritos') ?? [];
  }
}