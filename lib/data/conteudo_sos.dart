import 'package:flutter/material.dart';

final List<Map<String, dynamic>> guiasSOS = [
  {
    "titulo": "Engasgo (Bebê Consciente)",
    "icone": Icons.no_food,
    "cor": Colors.red,
    "passos": [
      "1. Ligue imediatamente para 192 (SAMU).",
      "2. Apoie o bebê de bruços no seu antebraço, com a cabeça mais baixa que o corpo.",
      "3. Segure a mandíbula com a mão (sem tapar a boca).",
      "4. Dê 5 tapas firmes nas costas (entre as escápulas) com a base da outra mão.",
      "5. Vire o bebê de barriga para cima e verifique a boca.",
      "6. Se não saiu, faça 5 compressões no peito (com 2 dedos).",
      "7. Repita até desengasgar ou o socorro chegar."
    ]
  },
  {
    "titulo": "Febre Alta",
    "icone": Icons.thermostat,
    "cor": Colors.orange,
    "passos": [
      "1. Bebês < 3 meses: Qualquer febre (≥ 37,8°C) é emergência. Vá ao hospital.",
      "2. Bebês > 3 meses: Observe o estado geral. Se estiver ativo e mamando, medique conforme pediatra.",
      "3. Dê um banho morno (não frio) para ajudar a baixar.",
      "4. Ofereça muito líquido (leite materno ou água se > 6 meses).",
      "5. Sinais de alerta: Manchas na pele, dificuldade de respirar ou pescoço rígido -> Hospital."
    ]
  },
  {
    "titulo": "Quedas e Batidas",
    "icone": Icons.medical_services,
    "cor": Colors.purple,
    "passos": [
      "1. Observe: O bebê chorou logo? Isso é bom sinal.",
      "2. Galo: Coloque gelo enrolado em pano por 15 min.",
      "3. Vômito: Se vomitar logo após ou horas depois -> Hospital.",
      "4. Sonolência fora do normal ou desmaio -> Hospital.",
      "5. Sangramento no nariz ou ouvido -> Hospital.",
      "6. Em dúvida, não deixe dormir nas primeiras 2 horas para observar comportamento."
    ]
  },
  {
    "titulo": "Queimadura",
    "icone": Icons.local_fire_department,
    "cor": Colors.deepOrange,
    "passos": [
      "1. Coloque a área afetada sob água corrente fria (torneira) por 10 a 15 minutos.",
      "2. NÃO passe pasta de dente, manteiga ou gelo direto.",
      "3. Se formar bolha, não estoure.",
      "4. Cubra com pano limpo e úmido.",
      "5. Procure atendimento médico se a área for grande ou no rosto/mãos."
    ]
  },
];