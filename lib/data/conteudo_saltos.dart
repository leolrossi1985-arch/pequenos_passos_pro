import 'package:flutter/material.dart';

// BASE DE DADOS FINAL - SALTOS DE DESENVOLVIMENTO
// Baseado na metodologia "The Wonder Weeks".
// Estrutura otimizada para leitura e engajamento dos pais.

const List<Map<String, dynamic>> saltosDetalhados = [
  // --- SALTO 1: AS SENSAÇÕES ---
  {
    "id": 1,
    "semana_inicio": 4,
    "semana_fim": 5,
    "tipo": "crise",
    "titulo": "Salto 1: O Mundo das Sensações",
    "descricao": "O metabolismo do bebê muda drasticamente e seus sentidos (visão, audição, tato) despertam de uma vez só. Após semanas de 'sonolência', ele é bombardeado por estímulos que antes não percebia dentro do útero. Tudo é novo, brilhante e barulhento, o que pode ser assustador.",
    "sinais": [
      "Os 3 Cs: Choro, 'Clinginess' (Grude) e 'Crankiness' (Irritação).",
      "Choro com lágrimas reais pela primeira vez.",
      "Necessidade de mamar constantemente, não apenas por fome, mas por conforto emocional."
    ],
    "dicas": [
      "Use a técnica do 'Charutinho' (Swaddle) e ruído branco para recriar a segurança do útero.",
      "Faça muito contato pele a pele (coloque o bebê só de fralda no seu peito nu) para regular a respiração e acalmar.",
      "Reduza drasticamente as luzes e o barulho da casa a partir das 17h para evitar a 'Hora da Bruxa'."
    ],
    "habilidades": [
      "Fixa o olhar em rostos e objetos com mais intensidade e por mais tempo.",
      "Reage de forma visível e positiva ao toque suave e sopros na pele.",
      "Pode apresentar o primeiro sorriso social (intencional) em resposta à sua voz ou rosto."
    ]
  },

  // --- SALTO 2: PADRÕES ---
  {
    "id": 2,
    "semana_inicio": 7,
    "semana_fim": 9,
    "tipo": "crise",
    "titulo": "Salto 2: O Mundo dos Padrões",
    "descricao": "A visão do bebê evolui e ele deixa de ver borrões para perceber padrões simples e contrastes. Ele descobre que o mundo é feito de formas e, mais importante, descobre que possui mãos e pés que pertencem a ele, tentando controlá-los de forma desajeitada.",
    "sinais": [
      "Fica 'hipnotizado' observando luzes, sombras, persianas ou estampas listradas.",
      "Chupa o dedo ou a mão de forma obsessiva como mecanismo de auto-regulação.",
      "Mudanças bruscas de humor: pode estar rindo e começar a chorar no mesmo minuto."
    ],
    "dicas": [
      "A rotina é sagrada agora: mantenha a mesma ordem de eventos (banho, massagem, sono) para diminuir a ansiedade.",
      "Ofereça brinquedos com alto contraste (preto e branco) ou móbiles a cerca de 20-30cm do rosto.",
      "Converse com ele enquanto caminha pela casa, narrando o que vê (luzes, quadros)."
    ],
    "habilidades": [
      "Olha fixamente, cruza os olhos e brinca com as próprias mãos (descoberta do corpo).",
      "Vira a cabeça intencionalmente na direção de sons ou vozes familiares.",
      "Começa a emitir sons curtos de vogais (gugu, dada) em resposta à interação."
    ]
  },

  // --- SALTO 3: TRANSIÇÕES SUAVES ---
  {
    "id": 3,
    "semana_inicio": 11,
    "semana_fim": 12,
    "tipo": "crise",
    "titulo": "Salto 3: Transições Suaves",
    "descricao": "O desenvolvimento físico amadurece. O bebê deixa de ser tão 'robótico' e rígido. Seus movimentos tornam-se fluidos e macios. Ele percebe nuances no tom de voz (diferença entre voz brava e doce) e mudanças na luminosidade do ambiente.",
    "sinais": [
      "Menos apetite ou distração extrema durante a mamada (solta o peito para olhar qualquer barulho).",
      "Chora intensamente se for passado rapidamente do colo de uma pessoa conhecida para uma desconhecida.",
      "Sono mais leve, acordando com qualquer ruído, e dificuldade para adormecer."
    ],
    "dicas": [
      "Tente amamentar em um quarto escuro e silencioso, longe de TVs e conversas.",
      "Brinque de balanço suave e 'aviãozinho' devagar para estimular o sistema vestibular e a percepção de movimento.",
      "Fale sussurrando ou cantando; ele agora entende a emoção por trás do tom de voz."
    ],
    "habilidades": [
      "Segue objetos em movimento com o olhar, virando a cabeça suavemente em 180 graus.",
      "Consegue segurar, chacoalhar e levar brinquedos leves à boca intencionalmente.",
      "Faz 'bolinhas de cuspe', grita para testar a voz e experimenta novos sons com a garganta."
    ]
  },

  // --- SALTO 4: EVENTOS ---
  {
    "id": 4,
    "semana_inicio": 14,
    "semana_fim": 19,
    "tipo": "crise",
    "titulo": "Salto 4: O Mundo dos Eventos",
    "descricao": "Um dos saltos mais longos e desafiadores. O bebê começa a entender a causalidade (se eu bato no brinquedo, ele faz barulho). Coincide com a Regressão do Sono dos 4 Meses, onde o ciclo de sono muda permanentemente para o padrão adulto.",
    "sinais": [
      "Regressão do sono severa: acorda a cada 1 ou 2 horas, muitas vezes 'praticando' habilidades (tentando rolar no berço).",
      "Quer a mãe o tempo todo e pode começar a estranhar o pai ou avós momentaneamente.",
      "Muita frustração: grita, fica vermelho e irritado quando não alcança um objeto."
    ],
    "dicas": [
      "Reforce o ritual do sono rigorosamente. O bebê precisa de ajuda para aprender a ligar os ciclos de sono.",
      "Brinque de causa e efeito: bater em brinquedos, amassar papel, derrubar blocos.",
      "Tenha paciência extra e reveze os cuidados à noite; este salto pode durar até 5 semanas."
    ],
    "habilidades": [
      "Leva absolutamente tudo à boca para explorar texturas, temperatura e sabor.",
      "Passa objetos de uma mão para a outra com coordenação.",
      "Responde ativamente (olha, sorri, vocaliza) quando chamam pelo seu próprio nome."
    ]
  },

  // --- SALTO 5: RELAÇÕES ---
  {
    "id": 5,
    "semana_inicio": 22,
    "semana_fim": 26,
    "tipo": "crise",
    "titulo": "Salto 5: O Mundo das Relações",
    "descricao": "O bebê compreende a distância física. Ele percebe que o mundo é enorme e ele é pequeno. O mais assustador: ele percebe que a mãe pode se afastar e 'sumir'. Isso gera a Ansiedade de Separação.",
    "sinais": [
      "Choro desesperado se você sai do cômodo, mesmo que por segundos.",
      "Pesadelos ou medo de dormir sozinho no berço (acorda chorando e checando se você está lá).",
      "Fica 'grudado' na sua roupa ou perna o dia todo (comportamento 'chicletinho')."
    ],
    "dicas": [
      "Brinque muito de 'Esconde-Achou' (cúcou) para ensinar o conceito de que você some, mas sempre volta.",
      "Nunca saia escondido de casa. Despeça-se, diga que volta e cumpra, para construir confiança.",
      "Introduza um objeto de transição (naninha ou ursinho) com o seu cheiro para a hora de dormir."
    ],
    "habilidades": [
      "Entende a permanência do objeto (sabe que algo escondido embaixo do pano ainda existe).",
      "Aprende gestos sociais como dar tchau, bater palmas ou mandar beijo.",
      "Começa a sentar sem apoio ou ficar na posição de tripé, observando o mundo de outro ângulo."
    ]
  },

  // --- SALTO 6: CATEGORIAS ---
  {
    "id": 6,
    "semana_inicio": 33,
    "semana_fim": 37,
    "tipo": "crise",
    "titulo": "Salto 6: O Mundo das Categorias",
    "descricao": "O bebê vira um pequeno cientista. Ele começa a classificar o mundo em grupos: coisas de comer, animais, pessoas, brinquedos. Ele estuda texturas e formas com uma seriedade impressionante.",
    "sinais": [
      "Ciúmes visível se você pega outro bebê no colo ou dá atenção excessiva a outra tarefa.",
      "Fica muito sério e concentrado analisando objetos minúsculos, sujeira no chão ou etiquetas.",
      "Primeiras 'birras' reais ao ser contrariado ou ter uma brincadeira interrompida."
    ],
    "dicas": [
      "Leve-o para passear e nomeie as categorias: 'Olha o cachorro (animal)', 'Olha a árvore (planta)'.",
      "Respeite o tempo dele de exploração; não interrompa bruscamente quando ele estiver focado estudando um objeto.",
      "Deixe-o explorar texturas diferentes (grama, areia, comida pastosa vs sólida) para ajudar na categorização."
    ],
    "habilidades": [
      "Reconhece formas e tenta encaixar peças simples em buracos correspondentes.",
      "Começa a engatinhar ou se arrastar com velocidade e intenção de chegar a algum lugar.",
      "Compreende o significado da palavra 'Não' e reconhece o tom de desaprovação (mesmo que teste o limite)."
    ]
  },

  // --- SALTO 7: SEQUÊNCIAS ---
  {
    "id": 7,
    "semana_inicio": 41,
    "semana_fim": 46,
    "tipo": "crise",
    "titulo": "Salto 7: O Mundo das Sequências",
    "descricao": "Surge a capacidade de planejar. Ele entende que para conseguir algo, precisa seguir uma ordem: 'Para comer, preciso pegar a colher, colocar na comida e levar à boca'. Ele quer fazer tudo sozinho, gerando frustração.",
    "sinais": [
      "Joga comida ou colher no chão repetidamente, não por malcriação, mas para testar a gravidade e sua reação.",
      "Resistência enorme ao sono e à troca de fralda (sente que está perdendo tempo de brincar).",
      "Chora de frustração genuína quando tenta montar algo e não consegue."
    ],
    "dicas": [
      "Dê autonomia controlada: deixe-o segurar uma colher enquanto você alimenta com outra.",
      "Peça ajuda ativa na troca de roupa ('cadê o pé?', 'agora levanta o braço') para ele sentir que participa da sequência.",
      "Ofereça brinquedos de empilhar (torres), encaixar e montar/desmontar."
    ],
    "habilidades": [
      "Aponta com o dedo indicador para mostrar o que quer ou compartilhar algo interessante.",
      "Tenta comer sozinho com as mãos ou talher (fazendo muita bagunça, o que é ótimo para o aprendizado).",
      "Procura ativamente objetos que viu você esconder em lugares difíceis ou altos."
    ]
  },

  // --- SALTO 8: PROGRAMAS ---
  {
    "id": 8,
    "semana_inicio": 50,
    "semana_fim": 54,
    "tipo": "crise",
    "titulo": "Salto 8: O Mundo dos Programas",
    "descricao": "O bebê compreende processos completos e fins. Diferente das sequências, agora ele entende o contexto: 'Depois do jantar vem o banho, depois o pijama, depois a cama'. É a famosa crise de 1 ano.",
    "sinais": [
      "Testa seus limites o tempo todo para ver se a regra muda dependendo do dia.",
      "Choro dramático, teatral e sem lágrimas para conseguir atenção ou um objeto desejado.",
      "Fica carinhoso de repente (beija e abraça) para 'ganhar' você após uma bronca."
    ],
    "dicas": [
      "Seja firme e consistente. Se 'não pode' hoje, não pode amanhã. A inconsistência gera ansiedade.",
      "Redirecione a atenção para outra atividade interessante em vez de ficar apenas dizendo 'não'.",
      "Dê pequenas responsabilidades domésticas: 'Guarde o brinquedo na caixa', 'Pegue o seu sapato'."
    ],
    "habilidades": [
      "Traz objetos específicos de outro cômodo quando você pede.",
      "Pode começar a dar os primeiros passos independentes ou andar segurando nos móveis.",
      "Começa a rabiscar com giz de cera (movimento amplo de ombro)."
    ]
  },

  // --- SALTO 9: PRINCÍPIOS ---
  {
    "id": 9,
    "semana_inicio": 59,
    "semana_fim": 64,
    "tipo": "crise",
    "titulo": "Salto 9: O Mundo dos Princípios",
    "descricao": "Surge o pensamento estratégico e social. O bebê (agora criança) começa a negociar, fazer planos, fazer humor, fingir e imitar o comportamento dos adultos para se inserir no grupo.",
    "sinais": [
      "Pode bater, morder ou gritar quando frustrado (falta de linguagem verbal para expressar raiva complexa).",
      "Faz 'manha' elaborada e birras públicas para testar sua reação social.",
      "Adora imitar tarefas domésticas reais (varrer, limpar com paninho, falar ao telefone)."
    ],
    "dicas": [
      "Valide a emoção antes de corrigir o comportamento: 'Sei que está bravo, mas não batemos. Bater dói'.",
      "Dê opções limitadas ('Quer o copo azul ou vermelho?') para dar sensação de controle e evitar brigas.",
      "Brinque muito de faz de conta (comidinha, cuidar da boneca, consertar coisas)."
    ],
    "habilidades": [
      "Expressa emoções complexas, faz 'caras e bocas' e piadas físicas para fazer os outros rirem.",
      "Sabe claramente o que é 'meu' e 'seu' (início da fase de posse).",
      "Faz planos para alcançar objetivos (ex: arrasta um banquinho para subir e pegar algo no alto)."
    ]
  },

  // --- SALTO 10: SISTEMAS ---
  {
    "id": 10,
    "semana_inicio": 70,
    "semana_fim": 75,
    "tipo": "crise",
    "titulo": "Salto 10: O Mundo dos Sistemas",
    "descricao": "A criança desenvolve a consciência de si e do sistema familiar. Ela entende que faz parte de uma família, que a família tem regras, e começa a desenvolver empatia e consciência moral (sabe quando fez algo errado).",
    "sinais": [
      "Mudanças drásticas de apetite (pode ficar seletivo com alimentos que antes gostava).",
      "Desenvolvimento de medos irracionais (sombra, escuro, barulho de moto, ralo do banho).",
      "Birras intensas movidas pelo desejo de independência total ('eu faço sozinho!')."
    ],
    "dicas": [
      "Não ridicularize os medos; use uma luz noturna e ofereça conforto e segurança.",
      "Elogie muito o bom comportamento ('Gostei de ver você guardando!') para reforçar positivamente.",
      "Use quadros de rotina visuais com imagens para ajudar a criança a antecipar o dia e reduzir a ansiedade."
    ],
    "habilidades": [
      "Começa a entender e seguir regras sociais simples ('esperar a vez', 'guardar depois de brincar').",
      "Começa a desenhar traços com intenção de representar algo (mesmo que seja um rabisco).",
      "Fala frases curtas de 2 ou 3 palavras com sentido completo ('quer água', 'papai chegou', 'neném caiu')."
    ]
  }
];