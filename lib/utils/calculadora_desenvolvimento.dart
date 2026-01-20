import 'package:flutter/material.dart';

class CalculadoraDesenvolvimento {
  
  // Definição dos Estados
  static const String STATUS_CRISE = 'raio';   // Salto (Tempestade/Crise)
  static const String STATUS_SOL = 'sol';      // Fase Ensolarada (Habilidade recém-adquirida)
  static const String STATUS_NUVEM = 'nuvem';  // Desenvolvimento Motor/Linguagem (Fases de treino)

  // ===========================================================================
  // 1. CÁLCULO DA IDADE CORRIGIDA (A REGRA DE OURO)
  // ===========================================================================
  
  /// Calcula a semana de desenvolvimento neurológico.
  /// Para os saltos, a base é a CONCEPÇÃO (40 semanas), não apenas o nascimento.
  /// Se [dataPrevista] (DPP) for fornecida, usamos ela (Idade Corrigida).
  /// Se não, usamos a [dataNascimento] (Idade Cronológica).
  static int calcularSemanasDeVida({
    required DateTime dataNascimento, 
    DateTime? dataPrevista
  }) {
    final DateTime hoje = DateTime.now();
    
    // Se a mãe informou a DPP, usamos ela como base.
    // Se não informou, assumimos que nasceu de 40 semanas (data de nascimento).
    final DateTime dataBase = dataPrevista ?? dataNascimento;

    final int diasDeVida = hoje.difference(dataBase).inDays;

    // Se o bebê nasceu prematuro e hoje ainda é antes da data prevista,
    // ele tecnicamente está na semana 0 (ainda amadurecendo).
    if (diasDeVida < 0) {
      return 0; 
    }

    return (diasDeVida / 7).floor();
  }

  // ===========================================================================
  // 2. TABELA DA VERDADE (Timeline Macro: Títulos e Descrições Curtas)
  // ===========================================================================
  
  static Map<String, String> getDadosSemana(int semana) {
    
    // --- RECÉM-NASCIDO ---
    if (semana <= 3) return {'status': STATUS_NUVEM, 'titulo': 'Adaptação', 'desc': 'Regulação fisiológica. O bebê está aprendendo a viver fora do útero.'};
    
    // --- SALTO 1 ---
    if (semana >= 4 && semana <= 5) return {'status': STATUS_CRISE, 'titulo': 'Salto 1: Sensações', 'desc': 'Metabolismo muda. Ele sente tudo mais intensamente.'};
    if (semana == 6) return {'status': STATUS_SOL, 'titulo': 'O Primeiro Sorriso', 'desc': 'O bebê está mais acordado e responde com sorrisos sociais.'};

    // --- SALTO 2 ---
    if (semana >= 7 && semana <= 9) return {'status': STATUS_CRISE, 'titulo': 'Salto 2: Padrões', 'desc': 'Percebe padrões de luz e som. O mundo parece caótico.'};
    if (semana == 10) return {'status': STATUS_SOL, 'titulo': 'Descobrindo as Mãos', 'desc': 'Fascinação por rostos, luzes e movimentos das próprias mãos.'};

    // --- SALTO 3 ---
    if (semana >= 11 && semana <= 12) return {'status': STATUS_CRISE, 'titulo': 'Salto 3: Transições', 'desc': 'Percebe nuances na voz e movimentos fluidos. Luta contra o sono.'};
    if (semana == 13) return {'status': STATUS_SOL, 'titulo': 'O Tagarela', 'desc': 'Faz bolhinhas, ri alto, agita o corpo e "conversa".'};

    // --- SALTO 4 ---
    if (semana >= 14 && semana <= 19) return {'status': STATUS_CRISE, 'titulo': 'Salto 4: Eventos', 'desc': 'Salto longo. Regressão de sono e mudanças cognitivas bruscas.'};
    if (semana == 20) return {'status': STATUS_SOL, 'titulo': 'Mundo na Boca', 'desc': 'Rola, pega objetos com as duas mãos e leva tudo à boca.'};

    // --- INTERVALO PÓS-SALTO 4 ---
    if (semana == 21) return {'status': STATUS_NUVEM, 'titulo': 'Ginástica', 'desc': 'Fase de treino motor intenso. Quer rolar o tempo todo.'};

    // --- SALTO 5 ---
    if (semana >= 22 && semana <= 25) return {'status': STATUS_CRISE, 'titulo': 'Salto 5: Relações', 'desc': 'Entende distância. Angústia da separação e medo de estranhos.'};
    if (semana == 26 || semana == 27) return {'status': STATUS_SOL, 'titulo': 'Causa e Efeito', 'desc': 'Entende que objetos continuam existindo e que ações geram reações.'};

    // --- INTERVALO MOTOR (A Grande Fase do Chão) ---
    if (semana >= 28 && semana <= 32) return {'status': STATUS_NUVEM, 'titulo': 'Rumo a Sentar', 'desc': 'Focadíssimo em tentar sentar sozinho, se arrastar ou engatinhar.'};

    // --- SALTO 6 ---
    if (semana >= 33 && semana <= 36) return {'status': STATUS_CRISE, 'titulo': 'Salto 6: Categorias', 'desc': 'Classifica o mundo: comida, bicho, brinquedo. Examina detalhes.'};
    if (semana == 37 || semana == 38) return {'status': STATUS_SOL, 'titulo': 'O Investigador', 'desc': 'Reconhece formas, faz caretas no espelho e imita gestos.'};

    // --- INTERVALO PRÉ-ANDAR ---
    if (semana >= 39 && semana <= 40) return {'status': STATUS_NUVEM, 'titulo': 'Ficar em Pé', 'desc': 'Treinando ficar em pé apoiado nos móveis. Força nas pernas.'};

    // --- SALTO 7 ---
    if (semana >= 41 && semana <= 45) return {'status': STATUS_CRISE, 'titulo': 'Salto 7: Sequências', 'desc': 'Aprende passo-a-passo. Quer fazer sozinho. Primeiras birras.'};
    if (semana == 46 || semana == 47) return {'status': STATUS_SOL, 'titulo': 'O Construtor', 'desc': 'Monta torres, aponta para o que quer e tenta comer sozinho.'};

    // --- INTERVALO PRÉ-ANIVERSÁRIO ---
    if (semana >= 48 && semana <= 49) return {'status': STATUS_NUVEM, 'titulo': 'Cruising', 'desc': 'Anda segurando nos móveis. Primeiras palavras podem surgir.'};

    // --- SALTO 8 ---
    if (semana >= 50 && semana <= 54) return {'status': STATUS_CRISE, 'titulo': 'Salto 8: Programas', 'desc': 'Entende o "todo" (lavar louça, ir passear). Testa limites.'};
    if (semana == 55 || semana == 56) return {'status': STATUS_SOL, 'titulo': 'O Ajudante', 'desc': 'Ajuda a guardar coisas, traz objetos e entende instruções.'};

    // --- INTERVALO TODDLER ---
    if (semana >= 57 && semana <= 58) return {'status': STATUS_NUVEM, 'titulo': 'Independência', 'desc': 'Quer fazer tudo sozinho (vestir, comer, andar).'};

    // --- SALTO 9 ---
    if (semana >= 59 && semana <= 63) return {'status': STATUS_CRISE, 'titulo': 'Salto 9: Princípios', 'desc': 'Estratégias, negociação, drama e posse ("é meu!").'};
    if (semana == 64 || semana == 65) return {'status': STATUS_SOL, 'titulo': 'O Ator', 'desc': 'Entende piadas, faz graça, pensa antes de agir.'};

    // --- INTERVALO LINGUAGEM ---
    if (semana >= 66 && semana <= 69) return {'status': STATUS_NUVEM, 'titulo': 'Explosão Verbal', 'desc': 'Aprendendo muitas palavras novas e correndo com firmeza.'};

    // --- SALTO 10 ---
    if (semana >= 70 && semana <= 74) return {'status': STATUS_CRISE, 'titulo': 'Salto 10: Sistemas', 'desc': 'Consciência moral, entende o certo e errado, manipula situações.'};
    
    // --- PÓS 75 SEMANAS ---
    return {'status': STATUS_SOL, 'titulo': 'Personalidade', 'desc': 'Empatia, frases completas, noção de tempo e vontade própria.'};
  }

  // --- Helpers Visuais ---
  static String getStatusSemana(int semana) => getDadosSemana(semana)['status']!;
  static String getTituloFase(int semana) => getDadosSemana(semana)['titulo']!;

  static List<Color> getCoresCard(int semana) {
    String status = getStatusSemana(semana);
    switch (status) {
      case STATUS_CRISE: return [const Color(0xFFFF9800), const Color(0xFFF57C00)]; // Laranja
      case STATUS_SOL:   return [const Color(0xFF6A9C89), const Color(0xFF4E8D7C)]; // Verde
      default:           return [const Color(0xFF78909C), const Color(0xFF546E7A)]; // Azul Acinzentado
    }
  }

  static IconData getIcone(int semana) {
    String status = getStatusSemana(semana);
    switch (status) {
      case STATUS_CRISE: return Icons.flash_on;
      case STATUS_SOL:   return Icons.wb_sunny;
      default:           return Icons.fitness_center; // Ícone de "treino"
    }
  }

  // ===========================================================================
  // 3. CONTEÚDO RICO, DENSO E ESPECÍFICO (SEM FALLBACKS GENÉRICOS)
  // ===========================================================================
  
  static Map<String, List<String>> getConteudoDetalhado(int semana) {
    
    List<String> sinais;
    List<String> dicas;
    List<String> habilidades;

    // -------------------------------------------------------------------------
    // RECÉM-NASCIDO (0-3 Semanas)
    // -------------------------------------------------------------------------
    if (semana <= 3) {
      sinais = [
        "Dorme a maior parte do tempo (16-18h)",
        "Reflexos primitivos fortes (Moro, sucção)",
        "Ainda não sorri socialmente",
        "Choro é a única forma de comunicação"
      ];
      dicas = [
        "Foco total na amamentação/fórmula",
        "Muito contato pele a pele (posição canguru)",
        "Reproduza o útero: escuro, apertadinho e ruído branco",
        "Não espere rotina agora: é sobrevivência"
      ];
      habilidades = [
        "Reconhece o cheiro e a voz da mãe",
        "Foca a visão a 30cm (distância do rosto ao mamar)",
        "Levanta o queixo brevemente no Tummy Time"
      ];
    }

    // -------------------------------------------------------------------------
    // SALTO 1: AS SENSAÇÕES (4-5 Semanas)
    // -------------------------------------------------------------------------
    else if (semana == 4) { // Início
      sinais = ["Metabolismo mudando", "Acorda com mais facilidade", "Olhar vago e distante"];
      dicas = ["Aumente o contato pele a pele", "Comece a usar o charutinho (swaddle)"];
      habilidades = ["Começa a fixar o olhar", "Acompanha objetos por poucos segundos"];
    } else if (semana == 5) { // O PICO
      sinais = ["CHORO COM LÁGRIMAS (Primeira vez)", "Desespero ao ser deixado no berço", "Mamadas irregulares (busca conforto)", "Treme ou se sobressalta"];
      dicas = ["Não tenha medo de dar colo (não vicia)", "Use ruído branco alto para acalmar", "Faça revezamento entre os pais"];
      habilidades = ["Órgãos internos amadurecendo", "Mais sensível ao toque"];
    } else if (semana == 6) { // SOL (Pós-salto)
      sinais = ["Olhos brilhantes", "Menos choro inexplicável", "Fica acordado feliz por janelas maiores"];
      dicas = ["Converse muito olhando nos olhos", "Faça caretas simples para ele imitar", "Massagem nas perninhas"];
      habilidades = ["SORRISO SOCIAL (Intencional!)", "Responde a sons com atenção", "Segue objetos com o olhar"];
    }

    // -------------------------------------------------------------------------
    // SALTO 2: PADRÕES (7-9 Semanas)
    // -------------------------------------------------------------------------
    else if (semana == 7) { // Início
      sinais = ["Parece ver coisas que não existem", "Vira a cabeça para luzes e janelas", "Leve inquietação nas mamadas"];
      dicas = ["Passeie pela casa mostrando sombras", "Use móbiles preto e branco"];
      habilidades = ["Vira a cabeça na direção de sons", "Começa a controlar o pescoço"];
    } else if (semana == 8) { // O PICO
      sinais = ["IRRITABILIDADE EXTREMA (Hora da bruxa)", "Fica rígido e tenso no colo", "Grita sem motivo aparente", "Recusa o peito por briga/distração"];
      dicas = ["Massagem relaxante (Shantala)", "Banho de balde (Ofurô)", "Use o Sling para manter perto"];
      habilidades = ["Começa a bater nos brinquedos (swiping)", "Chuta com força"];
    } else if (semana == 9) { // Finalizando
      sinais = ["Ainda chora, mas acalma mais rápido", "Chupa o dedo/mão com força", "Fica quieto observando"];
      dicas = ["Deixe ele descobrir as mãos", "Converse bem de pertinho"];
      habilidades = ["Descobre que tem mãos", "Olha para as mãos fascinado"];
    } else if (semana == 10) { // SOL
      sinais = ["Fica olhando para as mãos", "Sorri para brinquedos", "Tenta alcançar objetos"];
      dicas = ["Coloque chocalhos nos pés", "Bicicleta com as pernas", "Deixe-o nu por alguns minutos"];
      habilidades = ["Sustenta a cabeça a 45 graus", "Vocaliza vogais curtas ('ah', 'eh')", "Coordenação olho-mão iniciando"];
    }

    // -------------------------------------------------------------------------
    // SALTO 3: TRANSIÇÕES SUAVES (11-12 Semanas)
    // -------------------------------------------------------------------------
    else if (semana == 11) { // Início
      sinais = ["Movimentos menos robóticos", "Testa a voz (gritinhos agudos)", "Come menos (sem paciência)"];
      dicas = ["Brinque de fazer sons com a boca", "Não force a alimentação, ofereça com calma"];
      habilidades = ["Segue objetos em 180 graus", "Leva a mão à boca com precisão"];
    } else if (semana == 12) { // O PICO
      sinais = ["BRIGA COM O SONO", "Choro sentido, alto e agudo", "Rejeita pessoas estranhas", "Chupa o dedo com raiva"];
      dicas = ["Faça 'aviãozinho' (movimento vestibular)", "Balance ritmicamente", "Ambiente totalmente escuro antes de dormir"];
      habilidades = ["Segura objetos colocados na mão", "Começa a babar (preparação dentária)"];
    } else if (semana == 13) { // SOL
      sinais = ["Explosão de sons", "Adora ficar sentado (com apoio)", "Gargalhadas altas"];
      dicas = ["Faça cosquinhas", "Leia livros de texturas", "Imite os sons que ele faz"];
      habilidades = ["Faz bolhinhas de cuspe (framboesa)", "RI ALTO (Gargalhada)", "Sacode chocalhos intencionalmente"];
    }

    // -------------------------------------------------------------------------
    // SALTO 4: EVENTOS (14-19 Semanas) - O LONGO
    // -------------------------------------------------------------------------
    else if (semana == 14 || semana == 15) { // Regressão 4 Meses
      sinais = ["REGRESSÃO DE SONO DOS 4 MESES", "Acorda a cada ciclo (45-60 min)", "Parece ter 'desaprendido' a dormir", "Agitação noturna"];
      dicas = ["Mantenha a rotina de sono sagrada", "Muita paciência na madrugada", "Evite criar novos maus hábitos de sono"];
      habilidades = ["Visão de cores completa", "Vira de lado"];
    } else if (semana == 16 || semana == 17) { // O PICO DA FRUSTRAÇÃO
      sinais = ["FRUSTRAÇÃO MOTORA", "Quer pegar e não consegue", "Grita de raiva", "Vira a cabeça procurando a mãe o tempo todo"];
      dicas = ["Coloque brinquedos perto das mãos", "Ajude-o a rolar", "Mude de cenário (vá para a varanda/janela)"];
      habilidades = ["Tenta alcançar os pés", "Passa objetos de uma mão para outra"];
    } else if (semana == 18 || semana == 19) { // Finalizando
      sinais = ["Mais ativo e menos chorão", "Joga o corpo para tentar pegar coisas", "Começa a emitir consoantes"];
      dicas = ["Tapetinho de atividades no chão", "Deixe-o tentar pegar sozinho (não entregue tudo)"];
      habilidades = ["Agarra os pés e leva à boca", "Rola acidentalmente"];
    } else if (semana == 20 || semana == 21) { // SOL + INTERVALO
      sinais = ["Coloca TUDO na boca (fase oral)", "Muito ativo fisicamente", "Faz 'flexão de braço' no chão"];
      dicas = ["Brinquedos de texturas variadas", "Esconde-achou com paninho", "Ofereça mordedores"];
      habilidades = ["ROLA (de bruços para as costas)", "Pega objetos com as duas mãos", "Reconhece o próprio nome"];
    }

    // -------------------------------------------------------------------------
    // SALTO 5: RELAÇÕES (22-26 Semanas)
    // -------------------------------------------------------------------------
    else if (semana == 22 || semana == 23) { // Ansiedade
      sinais = ["ANSIEDADE DE SEPARAÇÃO", "Chora se você sai do campo de visão", "Quer ficar grudado (velcro)", "Estranha desconhecidos"];
      dicas = ["Brinque de 'Cadê? Achou!' (Peek-a-boo)", "Fale com ele de outro cômodo para ele ouvir sua voz"];
      habilidades = ["Percebe que pessoas vão e voltam", "Entende distância"];
    } else if (semana == 24 || semana == 25) { // O PICO
      sinais = ["Dorme mal por medo de acordar sozinho", "Joga comida/brinquedo no chão (teste de física)", "Testa sua reação"];
      dicas = ["Introduza um objeto de transição (naninha)", "Nunca saia escondido, sempre dê tchau e diga que volta"];
      habilidades = ["Entende causa e efeito (aperto = som)", "Joga objetos intencionalmente"];
    } else if (semana == 26 || semana == 27) { // Finalizando/Sol
      sinais = ["Entende que coisas estão dentro/fora", "Mais curioso que chorão", "Observa detalhes"];
      dicas = ["Brinquedos de caixa (põe e tira)", "Mostre como as coisas funcionam (interruptor, torneira)"];
      habilidades = ["Senta sem apoio (ou com pouco)", "Entende permanência de objeto", "Estica os braços pedindo colo"];
    }

    // -------------------------------------------------------------------------
    // INTERVALO MOTOR (28-32 Semanas) - SEMANA A SEMANA
    // -------------------------------------------------------------------------
    else if (semana >= 28 && semana <= 29) {
      sinais = ["Focadíssimo no equilíbrio", "Cai para os lados tentando sentar", "Balbucia muito"];
      dicas = ["Crie um 'ninho' de almofadas para segurança", "Converse e responda aos balbucios"];
      habilidades = ["Senta sem apoio por minutos", "Gira sentado (pivô)"];
    } else if (semana >= 30 && semana <= 32) {
      sinais = ["Frustração por não alcançar brinquedos", "Tenta se arrastar (commando crawl)", "Fica de 4 apoios e balança"];
      dicas = ["Coloque brinquedos longe para estimular", "Chão livre e roupa confortável", "Não use andador"];
      habilidades = ["Postura de 4 apoios", "Passa objeto de mão em mão", "Pinça grossa (pega com os dedos)"];
    }

    // -------------------------------------------------------------------------
    // SALTO 6: CATEGORIAS (33-37 Semanas)
    // -------------------------------------------------------------------------
    else if (semana == 33 || semana == 34) { // O Cientista
      sinais = ["Examina migalhas no chão", "Fica sério e concentrado", "Ignora brinquedos grandes para ver etiquetas"];
      dicas = ["Leve para a natureza (tocar na grama, areia)", "Mostre livros de animais realistas"];
      habilidades = ["Foco em detalhes minúsculos", "Separa comida por tipos (cospe o que não quer)"];
    } else if (semana == 35 || semana == 36) { // O PICO
      sinais = ["CIÚMES INTENSO", "Chora se você pega outro bebê", "Quer fazer tudo sozinho mas falha", "Muito dengo"];
      dicas = ["Dê atenção exclusiva", "Valide a frustração dele", "Brinque de agrupar cores ou formas"];
      habilidades = ["Entende que coisas pertencem a grupos", "Reconhece animais"];
    } else if (semana == 37 || semana == 38) { // Finalizando/Sol
      sinais = ["Reconhece a si mesmo no espelho", "Faz caretas", "Imita gestos dos adultos"];
      dicas = ["Brinque muito no espelho", "Faça sons de animais para ele imitar"];
      habilidades = ["Imita tchau e beijo", "Engatinha com velocidade", "Entende 'não' e 'mamãe'"];
    }

    // -------------------------------------------------------------------------
    // INTERVALO PRÉ-ANDAR (39-40 Semanas)
    // -------------------------------------------------------------------------
    else if (semana == 39 || semana == 40) {
      sinais = ["Treina ficar em pé nos móveis", "Cai e levanta repetidamente", "Começa a soltar as mãos"];
      dicas = ["Proteja quinas e tomadas", "Ofereça apoio firme (sofá)", "Crie percursos de obstáculos"];
      habilidades = ["Fica em pé com apoio", "Pinça fina perfeita (indicador e polegar)", "Bate palmas"];
    }

    // -------------------------------------------------------------------------
    // SALTO 7: SEQUÊNCIAS (41-46 Semanas)
    // -------------------------------------------------------------------------
    else if (semana >= 41 && semana <= 42) { // Início
      sinais = ["Quer comer sozinho (faz muita bagunça)", "Recusa ajuda", "Aponta para o que quer imperativamente"];
      dicas = ["Deixe tentar usar a colher (mesmo sujando)", "Nomeie tudo o que ele aponta"];
      habilidades = ["Aponta com indicador", "Tenta se vestir/despir"];
    } else if (semana >= 43 && semana <= 44) { // O PICO
      sinais = ["PRIMEIRAS BIRRAS", "Se joga para trás", "Grita quando contrariado", "Joga comida longe"];
      dicas = ["Mantenha a calma (seja o porto seguro)", "Desvie a atenção", "Não grite de volta"];
      habilidades = ["Testa reações emocionais", "Sabe que 'não' significa pare (mas ignora)"];
    } else if (semana == 45) { // Finalizando
      sinais = ["Entende sequências ('primeiro meia, depois sapato')", "Mais cooperativo na rotina"];
      dicas = ["Ensine rotinas passo-a-passo", "Brinquedos de empilhar e encaixar"];
      habilidades = ["Encaixa formas simples", "Participa da rotina"];
    } else if (semana == 46 || semana == 47) { // SOL
      sinais = ["Adora brincar de construir", "Bebe no copo com ajuda", "Responde a comandos simples"];
      dicas = ["Dê ordens simples ('pegue a bola')", "Brinque de telefone"];
      habilidades = ["Monta torre de 2 ou 3 blocos", "Tenta acertar a boca com a colher"];
    }

    // -------------------------------------------------------------------------
    // INTERVALO PRÉ-ANIVERSÁRIO (48-49 Semanas)
    // -------------------------------------------------------------------------
    else if (semana == 48 || semana == 49) {
      sinais = ["Cruising (anda segurando nos móveis)", "Pode dar os primeiros passos", "Fala 1 ou 2 palavras"];
      dicas = ["Ofereça empurradores (carrinho de boneca/mercado)", "Olhe álbuns de fotos juntos"];
      habilidades = ["Fica em pé sem apoio por segundos", "Compreende muitas palavras", "Dança com música"];
    }

    // -------------------------------------------------------------------------
    // SALTO 8: PROGRAMAS (50-54 Semanas)
    // -------------------------------------------------------------------------
    else if (semana == 50 || semana == 51) { // Crise de 1 Ano
      sinais = ["SONO PIORA DRASTICAMENTE", "Acorda gritando", "Mudança brusca de apetite", "Testa limites olhando para você"];
      dicas = ["Reassegure a presença, mas não crie novos hábitos de sono", "Seja firme e amoroso nos limites"];
      habilidades = ["Entende o fim e o meio de uma tarefa", "Observa a rotina da casa"];
    } else if (semana == 52 || semana == 53) { // O PICO
      sinais = ["Testa limites o tempo todo", "Chora para manipular", "Agressividade (tapas/mordidas de frustração)"];
      dicas = ["Dê opções limitadas ('quer a blusa azul ou vermelha?')", "Não leve para o pessoal"];
      habilidades = ["Sabe como conseguir o que quer", "Usa ferramentas (vassoura, colher)"];
    } else if (semana == 54) { // Finalizando
      sinais = ["Ajuda a guardar coisas", "Traz objetos pedidos", "Entende o 'todo' (lavar louça = processo)"];
      dicas = ["Peça ajuda nas tarefas domésticas simples", "Elogie a cooperação"];
      habilidades = ["Guarda brinquedos na caixa", "Busca objetos em outro cômodo"];
    } else if (semana == 55 || semana == 56) { // SOL
      sinais = ["Anda com confiança", "Tenta se despir", "Rabisca papel"];
      dicas = ["Dê giz de cera grosso", "Brincadeiras de correr"];
      habilidades = ["Anda sozinho", "Rabisca papel", "Usa objetos corretamente (pente)"];
    }

    // -------------------------------------------------------------------------
    // INTERVALO INDEPENDÊNCIA (57-58 Semanas)
    // -------------------------------------------------------------------------
    else if (semana == 57 || semana == 58) {
      sinais = ["Quer fazer tudo sozinho", "Foge na hora de trocar fralda/roupa", "Sobe em tudo"];
      dicas = ["Faça trocas em pé se possível", "Dê autonomia controlada (escolher o livro)"];
      habilidades = ["Sobe em sofás/cadeiras", "Carrega brinquedos enquanto anda"];
    }

    // -------------------------------------------------------------------------
    // SALTO 9: PRINCÍPIOS (59-64 Semanas)
    // -------------------------------------------------------------------------
    else if (semana >= 59 && semana <= 60) { // Testes
      sinais = ["Faz 'arte' olhando para você", "Imita tarefas domésticas", "Sobe em lugares perigosos"];
      dicas = ["Ambiente seguro para explorar", "Brinque de casinha/ferramenta"];
      habilidades = ["Planeja como subir nas coisas", "Imita adultos com perfeição"];
    } else if (semana >= 61 && semana <= 62) { // O PICO
      sinais = ["DRAMA E TEATRO", "Finge choro", "Possessivo ('MEU!')", "Birras longas e dramáticas"];
      dicas = ["Negocie: 'primeiro guardamos, depois brincamos'", "Não ria do drama (incentiva)", "Elogie o bom comportamento"];
      habilidades = ["Faz estratégias para conseguir coisas", "Negocia troca de objetos"];
    } else if (semana == 63) { // Finalizando
      sinais = ["Planeja brincadeiras", "Pensa antes de agir", "Mais carinhoso e negociador"];
      dicas = ["Brincadeiras de faz-de-conta mais complexas", "Pique-esconde"];
      habilidades = ["Pensa antes de fazer", "Faz de conta simples"];
    } else if (semana == 64 || semana == 65) { // SOL
      sinais = ["Faz piadas e acha graça", "Faz de conta (alimenta boneca)", "Chuta bola"];
      dicas = ["Brinque de bola", "Quebra-cabeças simples"];
      habilidades = ["Senso de humor", "Vocabulário crescendo rápido"];
    }

    // -------------------------------------------------------------------------
    // INTERVALO LINGUAGEM (66-69 Semanas)
    // -------------------------------------------------------------------------
    else if (semana >= 66 && semana <= 69) {
      sinais = ["Explosão de vocabulário", "Começa a juntar 2 palavras ('mamãe dá')", "Corre com segurança"];
      dicas = ["Leia muito e converse o tempo todo", "Corrija repetindo a palavra certa (não critique)"];
      habilidades = ["Sobe escadas engatinhando", "Corre", "Identifica partes do corpo"];
    }

    // -------------------------------------------------------------------------
    // SALTO 10: SISTEMAS (70-74 Semanas)
    // -------------------------------------------------------------------------
    else if (semana >= 70 && semana <= 71) { // Consciência
      sinais = ["Entende que você tem sentimentos", "Alteração de apetite", "Fica 'bonzinho' e depois 'terrível'"];
      dicas = ["Valide os sentimentos ('sei que está bravo')", "Explique o porquê das regras"];
      habilidades = ["Consciência moral (sabe que errou)", "Entende que é uma pessoa separada"];
    } else if (semana >= 72 && semana <= 73) { // O PICO
      sinais = ["PESADELOS / TERROR NOTURNO", "Medos irracionais (do ralo, do escuro)", "Manipulação inteligente"];
      dicas = ["Evite telas à noite", "Desenhe com ele (arte terapia)", "Seja consistente nas regras"];
      habilidades = ["Imaginação ativa (daí os medos)", "Entende posse e família"];
    } else if (semana == 74) { // Finalizando
      sinais = ["Entende o conceito de tempo (hoje/amanhã)", "Começa a desenhar com intenção", "Demonstra empatia"];
      dicas = ["Fale sobre o que farão amanhã", "Estimule a autonomia no banho/roupa"];
      habilidades = ["Noção de tempo", "Empatia (consola outros)"];
    } 
    
    // --- FASES MAIORES (75+) ---
    else {
      sinais = ["Personalidade forte e definida", "Fala frases completas", "Mais independente"];
      dicas = ["Incentive amizades", "Brincadeiras de regras simples", "Início do desfralde (se houver sinais)"];
      habilidades = ["Conversa", "Corre e pula", "Come sozinho"];
    }

    return {
      'sinais': sinais,
      'dicas': dicas,
      'habilidades': habilidades
    };
  }
}