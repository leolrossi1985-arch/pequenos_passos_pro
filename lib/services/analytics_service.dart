import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'bebe_service.dart';

class AnalyticsService {
  static Future<Map<String, dynamic>> carregarDadosSemanais() async {
    final bebeRef = await BebeService.getRefBebeAtivo();
    if (bebeRef == null) return {};

    final hoje = DateTime.now();
    final seteDiasAtras = hoje.subtract(const Duration(days: 7));
    
    // 1. BUSCAR ROTINA (Sono, Fralda, Mamada)
    final snapRotina = await bebeRef.collection('rotina')
        .where('data', isGreaterThan: seteDiasAtras.toIso8601String())
        .get();

    Map<int, double> sonoPorDia = {}; 
    for (int i = 0; i < 7; i++) sonoPorDia[hoje.subtract(Duration(days: i)).weekday] = 0.0;

    int mamaEsq = 0, mamaDir = 0;
    int totalFraldas = 0, xixi = 0, coco = 0;

    for (var doc in snapRotina.docs) {
      final data = doc.data();
      final dia = DateTime.parse(data['data']).weekday;

      if (data['tipo'] == 'sono') {
        sonoPorDia[dia] = (sonoPorDia[dia] ?? 0) + ((data['duracao_segundos'] ?? 0) / 3600.0);
      }
      if (data['tipo'] == 'mamada') {
        if (data['lado'].toString().contains('Esq')) mamaEsq++; else mamaDir++;
      }
      if (data['tipo'] == 'fralda') {
        totalFraldas++;
        if (data['conteudo'].toString().contains('Xixi')) xixi++;
        if (data['conteudo'].toString().contains('Cocô') || data['conteudo'].toString().contains('Ambos')) coco++;
      }
    }

    // 2. BUSCAR NUTRIÇÃO (Macros/Grupos)
    // Vamos contar quantos alimentos PROVADOS existem em cada categoria
    final snapAlim = await bebeRef.collection('alimentacao').where('ja_comeu', isEqualTo: true).get();
    
    // Precisamos cruzar com a biblioteca para saber a categoria, 
    // mas para ser rápido, vamos assumir que salvamos a categoria ou buscar na biblioteca.
    // A melhor forma agora (sem mudar a estrutura de salvamento) é buscar todos os alimentos da biblioteca
    // e cruzar os IDs.
    
    int qtdFruta = 0, qtdLegume = 0, qtdProteina = 0;
    
    // Nota: Isso é uma aproximação baseada nos IDs conhecidos ou lógica de negócio.
    // Se o ID do alimento não tiver a categoria salva no histórico do bebê, 
    // teríamos que fazer uma query complexa. 
    // Vamos Simplificar: Contar o total de registros de experiência.
    
    // *Melhoria:* Vamos fazer uma query na biblioteca para pegar as categorias dos IDs provados.
    List<String> idsProvados = snapAlim.docs.map((e) => e.id).toList();
    
    if (idsProvados.isNotEmpty) {
      // O Firestore não aceita 'whereIn' com mais de 10 itens. Vamos fazer em memória se for pequeno.
      final biblioteca = await FirebaseFirestore.instance.collection('biblioteca_alimentos').get();
      for (var doc in biblioteca.docs) {
        if (idsProvados.contains(doc.id)) {
          String cat = doc.data()['categoria'] ?? '';
          if (cat == 'Fruta') qtdFruta++;
          if (cat == 'Legume') qtdLegume++;
          if (cat == 'Proteína') qtdProteina++;
        }
      }
    }

    // 3. BUSCAR ATIVIDADES REALIZADAS (Semana)
    final snapMetas = await bebeRef.collection('metas_diarias')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(seteDiasAtras))
        .get();
    
    int atividadesFeitas = 0;
    for (var doc in snapMetas.docs) {
      final List concluidas = doc.data()['concluidas'] ?? [];
      atividadesFeitas += concluidas.length;
    }

    return {
      'sono': sonoPorDia,
      'mamada_esq': mamaEsq,
      'mamada_dir': mamaDir,
      'fralda_total': totalFraldas,
      'fralda_xixi': xixi,
      'fralda_coco': coco,
      'nutri_fruta': qtdFruta,
      'nutri_legume': qtdLegume,
      'nutri_prot': qtdProteina,
      'atividades_semana': atividadesFeitas
    };
  }
}