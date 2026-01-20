import 'package:cloud_firestore/cloud_firestore.dart';
import 'bebe_service.dart';

class DentesService {
  // Marca um dente como nascido (salva a data)
  static Future<void> marcarDente(String idDente, String nomeDente) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;

    await bebeRef.collection('dentes').doc(idDente).set({
      'id': idDente,
      'nome': nomeDente,
      'data_nascimento': DateTime.now().toIso8601String(),
    });
  }

  // Remove (caso tenha marcado errado)
  static Future<void> desmarcarDente(String idDente) async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return;
    await bebeRef.collection('dentes').doc(idDente).delete();
  }

  // Escuta os dentes em tempo real
  static Stream<QuerySnapshot> streamDentes() async* {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef != null) {
      yield* bebeRef.collection('dentes').snapshots();
    }
  }
}