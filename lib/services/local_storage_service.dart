import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

class LocalStorageService {
  
  // Salva a imagem do Picker para a pasta do App
  static Future<String> salvarImagemLocalmente(XFile imagem) async {
    try {
      // 1. Pega o diretório de documentos do app (seguro)
      final directory = await getApplicationDocumentsDirectory();
      
      // 2. Cria um nome único
      final String nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imagem.path)}';
      
      // 3. Define o novo caminho
      final String novoCaminho = path.join(directory.path, nomeArquivo);
      
      // 4. Copia a imagem para lá
      await imagem.saveTo(novoCaminho);
      
      return novoCaminho; // Retorna o caminho local permanente
    } catch (e) {
      print("Erro ao salvar imagem local: $e");
      return "";
    }
  }
}