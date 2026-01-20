import 'package:flutter/material.dart';

// BASE DE DADOS DE MARCOS DO DESENVOLVIMENTO
// Fontes: CDC (Learn the Signs. Act Early) 2023 & SBP.
// Ajustado para o percentil 75% (o que a maioria das crianças faz naquela idade).

final List<Map<String, dynamic>> marcosCompletos = [
  // =======================================================
  // 2 MESES
  // =======================================================
  {
    'meses': 2,
    'categoria': 'Social / Emocional',
    'descricao': 'O primeiro sorriso social.',
    'sub_marcos': [
      {'id': 'm2_soc_1', 'texto': 'Sorri quando você sorri para ele'},
      {'id': 'm2_soc_2', 'texto': 'Olha para o rosto dos pais'},
      {'id': 'm2_soc_3', 'texto': 'Se acalma (para de chorar) quando é pego no colo ou ouve voz familiar'},
    ]
  },
  {
    'meses': 2,
    'categoria': 'Linguagem',
    'descricao': 'Gorgeios.',
    'sub_marcos': [
      {'id': 'm2_com_1', 'texto': 'Faz sons curtos ("agu", "eh")'},
      {'id': 'm2_com_2', 'texto': 'Reage a sons altos (pisca ou assusta)'},
    ]
  },
  {
    'meses': 2,
    'categoria': 'Cognitivo / Visual',
    'descricao': 'Atenção visual.',
    'sub_marcos': [
      {'id': 'm2_cog_1', 'texto': 'Observa o rosto das pessoas atentamente'},
      {'id': 'm2_cog_2', 'texto': 'Segue um objeto com o olhar (acompanha o movimento)'},
    ]
  },
  {
    'meses': 2,
    'categoria': 'Motor',
    'descricao': 'Controle de cabeça.',
    'sub_marcos': [
      {'id': 'm2_mot_1', 'texto': 'Levanta a cabeça quando está de bruços (Tummy Time)'},
      {'id': 'm2_mot_2', 'texto': 'Move braços e pernas de forma igual (sem rigidez excessiva)'},
    ]
  },

  // =======================================================
  // 4 MESES
  // =======================================================
  {
    'meses': 4,
    'categoria': 'Social / Emocional',
    'descricao': 'Interação e risadas.',
    'sub_marcos': [
      {'id': 'm4_soc_1', 'texto': 'Sorri espontaneamente para chamar atenção'},
      {'id': 'm4_soc_2', 'texto': 'Dá risadas altas (gargalhadas)'},
      {'id': 'm4_soc_3', 'texto': 'Tenta copiar algumas expressões faciais (como sorrir)'},
    ]
  },
  {
    'meses': 4,
    'categoria': 'Linguagem',
    'descricao': 'Sons vocais.',
    'sub_marcos': [
      {'id': 'm4_com_1', 'texto': 'Faz sons como "ooh", "aah" (ainda não fala sílabas)'},
      {'id': 'm4_com_2', 'texto': 'Chora de maneiras diferentes para fome, dor ou cansaço'},
    ]
  },
  {
    'meses': 4,
    'categoria': 'Motor',
    'descricao': 'Mãos e pescoço.',
    'sub_marcos': [
      {'id': 'm4_mot_1', 'texto': 'Mantém a cabeça firme sem apoio quando segurado'},
      {'id': 'm4_mot_2', 'texto': 'Leva as mãos à boca com frequência'},
      {'id': 'm4_mot_3', 'texto': 'Segura um brinquedo se colocado na mão'},
      {'id': 'm4_mot_4', 'texto': 'Rola da barriga para as costas'},
    ]
  },

  // =======================================================
  // 6 MESES
  // =======================================================
  {
    'meses': 6,
    'categoria': 'Social',
    'descricao': 'Reconhecimento.',
    'sub_marcos': [
      {'id': 'm6_soc_1', 'texto': 'Reconhece rostos familiares e estranha desconhecidos'},
      {'id': 'm6_soc_2', 'texto': 'Gosta de se olhar no espelho'},
    ]
  },
  {
    'meses': 6,
    'categoria': 'Linguagem',
    'descricao': 'Balbucio inicial.',
    'sub_marcos': [
      {'id': 'm6_com_1', 'texto': 'Responde aos sons emitindo sons'},
      {'id': 'm6_com_2', 'texto': 'Começa a falar consoantes ("ma", "ba", "da")'},
      {'id': 'm6_com_3', 'texto': 'Reage quando chamam seu nome'},
    ]
  },
  {
    'meses': 6,
    'categoria': 'Motor',
    'descricao': 'Mobilidade e Sentar.',
    'sub_marcos': [
      {'id': 'm6_mot_1', 'texto': 'Rola para os dois lados (frente/costas e vice-versa)'},
      {'id': 'm6_mot_2', 'texto': 'Senta com apoio (ou brevemente sem apoio, posição de tripé)'},
      {'id': 'm6_mot_3', 'texto': 'Fica de pé com apoio e pula (faz força nas pernas)'},
    ]
  },

  // =======================================================
  // 9 MESES
  // =======================================================
  {
    'meses': 9,
    'categoria': 'Social / Emocional',
    'descricao': 'Vínculo e Medo.',
    'sub_marcos': [
      {'id': 'm9_soc_1', 'texto': 'Pode ter medo de estranhos e "estranhamento"'},
      {'id': 'm9_soc_2', 'texto': 'Tem brinquedos favoritos'},
    ]
  },
  {
    'meses': 9,
    'categoria': 'Linguagem',
    'descricao': 'Compreensão.',
    'sub_marcos': [
      {'id': 'm9_com_1', 'texto': 'Entende "não"'},
      {'id': 'm9_com_2', 'texto': 'Faz muitos sons diferentes ("mamamama", "babababa")'},
      {'id': 'm9_com_3', 'texto': 'Aponta coisas com o dedo'},
    ]
  },
  {
    'meses': 9,
    'categoria': 'Cognitivo',
    'descricao': 'Permanência do Objeto.',
    'sub_marcos': [
      {'id': 'm9_cog_1', 'texto': 'Procura coisas que você escondeu (Permanência do objeto)'},
      {'id': 'm9_cog_2', 'texto': 'Brinca de "esconde-achou" (Peek-a-boo)'},
      {'id': 'm9_cog_3', 'texto': 'Pega comida com indicador e polegar (Pinça)'},
    ]
  },
  {
    'meses': 9,
    'categoria': 'Motor',
    'descricao': 'Sentar e Engatinhar.',
    'sub_marcos': [
      {'id': 'm9_mot_1', 'texto': 'Senta-se sozinho sem apoio'},
      {'id': 'm9_mot_2', 'texto': 'Fica de pé segurando em algo'},
      {'id': 'm9_mot_3', 'texto': 'Engatinha ou se arrasta (alguns bebês pulam essa fase)'},
    ]
  },

  // =======================================================
  // 12 MESES (1 ANO)
  // =======================================================
  {
    'meses': 12,
    'categoria': 'Social',
    'descricao': 'Interação.',
    'sub_marcos': [
      {'id': 'm12_soc_1', 'texto': 'Chora quando a mãe ou pai sai'},
      {'id': 'm12_soc_2', 'texto': 'Estende braço ou perna para ajudar a vestir'},
      {'id': 'm12_soc_3', 'texto': 'Demonstra preferência por certas pessoas'},
    ]
  },
  {
    'meses': 12,
    'categoria': 'Linguagem',
    'descricao': 'Primeiras palavras.',
    'sub_marcos': [
      {'id': 'm12_com_1', 'texto': 'Dá tchau (acena) ou manda beijo'},
      {'id': 'm12_com_2', 'texto': 'Diz "mama" ou "papa" (sabendo quem é)'},
      {'id': 'm12_com_3', 'texto': 'Entende pedidos simples ("me dá")'},
    ]
  },
  {
    'meses': 12,
    'categoria': 'Motor',
    'descricao': 'Ficar em pé.',
    'sub_marcos': [
      {'id': 'm12_mot_1', 'texto': 'Puxa-se para ficar em pé e anda segurando nos móveis (cruzeiro)'},
      {'id': 'm12_mot_2', 'texto': 'Fica de pé sozinho por instantes'},
      {'id': 'm12_mot_3', 'texto': 'Pode dar os primeiros passos sem apoio'},
    ]
  },

  // =======================================================
  // 15 MESES (1 ANO E 3 MESES)
  // =======================================================
  {
    'meses': 15,
    'categoria': 'Geral',
    'descricao': 'Autonomia inicial.',
    'sub_marcos': [
      {'id': 'm15_mot_1', 'texto': 'Anda sozinho com segurança'},
      {'id': 'm15_com_1', 'texto': 'Fala pelo menos 3 palavras além de mama/papa'},
      {'id': 'm15_cog_1', 'texto': 'Usa objetos corretamente (ex: leva telefone ao ouvido)'},
      {'id': 'm15_mot_2', 'texto': 'Bebe em copo aberto ou com bico'},
    ]
  },

  // =======================================================
  // 18 MESES (1 ANO E MEIO)
  // =======================================================
  {
    'meses': 18,
    'categoria': 'Social / Cognitivo',
    'descricao': 'Faz de conta.',
    'sub_marcos': [
      {'id': 'm18_soc_1', 'texto': 'Aponta para mostrar algo interessante para você'},
      {'id': 'm18_soc_2', 'texto': 'Tenta ajudar na casa ou imita tarefas'},
      {'id': 'm18_soc_3', 'texto': 'Brinca de faz de conta simples (ex: dar comida à boneca)'},
    ]
  },
  {
    'meses': 18,
    'categoria': 'Linguagem',
    'descricao': 'Vocabulário.',
    'sub_marcos': [
      {'id': 'm18_com_1', 'texto': 'Fala várias palavras simples (água, bola, não)'},
      {'id': 'm18_com_2', 'texto': 'Aponta para partes do corpo quando perguntado'},
    ]
  },
  {
    'meses': 18,
    'categoria': 'Motor',
    'descricao': 'Habilidades manuais.',
    'sub_marcos': [
      {'id': 'm18_mot_1', 'texto': 'Come de colher (pode derramar um pouco)'},
      {'id': 'm18_mot_2', 'texto': 'Sobe em móveis sem ajuda'},
      {'id': 'm18_mot_3', 'texto': 'Rabisca espontaneamente'},
    ]
  },

  // =======================================================
  // 24 MESES (2 ANOS)
  // =======================================================
  {
    'meses': 24,
    'categoria': 'Social',
    'descricao': 'Independência.',
    'sub_marcos': [
      {'id': 'm24_soc_1', 'texto': 'Brinca ao lado de outras crianças (brincadeira paralela)'},
      {'id': 'm24_soc_2', 'texto': 'Demonstra comportamento desafiador (testa limites)'},
    ]
  },
  {
    'meses': 24,
    'categoria': 'Linguagem',
    'descricao': 'Frases.',
    'sub_marcos': [
      {'id': 'm24_com_1', 'texto': 'Junta 2 ou mais palavras ("quer água", "caiu bola")'},
      {'id': 'm24_com_2', 'texto': 'Aponta para figuras em livros quando você fala o nome'},
    ]
  },
  {
    'meses': 24,
    'categoria': 'Motor',
    'descricao': 'Agilidade.',
    'sub_marcos': [
      {'id': 'm24_mot_1', 'texto': 'Chuta uma bola'},
      {'id': 'm24_mot_2', 'texto': 'Corre'},
      {'id': 'm24_mot_3', 'texto': 'Sobe e desce escadas segurando'},
    ]
  },

  // =======================================================
  // 30 MESES (2 ANOS E MEIO)
  // =======================================================
  {
    'meses': 30,
    'categoria': 'Geral',
    'descricao': 'Coordenação e Fala.',
    'sub_marcos': [
      {'id': 'm30_com_1', 'texto': 'Fala cerca de 50 palavras'},
      {'id': 'm30_com_2', 'texto': 'Usa pronomes como "eu", "mim", "nós"'},
      {'id': 'm30_mot_1', 'texto': 'Pula com os dois pés juntos'},
      {'id': 'm30_mot_2', 'texto': 'Tira roupas fáceis sozinho'},
    ]
  },

  // =======================================================
  // 36 MESES (3 ANOS)
  // =======================================================
  {
    'meses': 36,
    'categoria': 'Social',
    'descricao': 'Amigos e Emoção.',
    'sub_marcos': [
      {'id': 'm36_soc_1', 'texto': 'Percebe se alguém está triste ou chateado'},
      {'id': 'm36_soc_2', 'texto': 'Separa-se facilmente dos pais'},
      {'id': 'm36_soc_3', 'texto': 'Entende a ideia de "meu" e "seu"'},
    ]
  },
  {
    'meses': 36,
    'categoria': 'Linguagem',
    'descricao': 'Conversação.',
    'sub_marcos': [
      {'id': 'm36_com_1', 'texto': 'Conversa com 2 ou 3 frases'},
      {'id': 'm36_com_2', 'texto': 'Sabe o nome, idade e sexo'},
      {'id': 'm36_com_3', 'texto': 'Estranhos conseguem entender a maior parte da fala'},
    ]
  },
  {
    'meses': 36,
    'categoria': 'Motor',
    'descricao': 'Coordenação fina.',
    'sub_marcos': [
      {'id': 'm36_mot_1', 'texto': 'Pedala triciclo'},
      {'id': 'm36_mot_2', 'texto': 'Copia um círculo com lápis'},
      {'id': 'm36_mot_3', 'texto': 'Veste algumas roupas sozinho'},
    ]
  },
];