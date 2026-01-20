import 'package:flutter/material.dart';

final List<Map<String, dynamic>> cursosPremium = [
  // ===========================================================================
  // CURSO 1: ESCOLA DO SONO (12 AULAS - PROFUNDO)
  // ===========================================================================
  {
    "id": "sono_master",
    "titulo": "Escola do Sono",
    "subtitulo": "Fisiologia, Ritmo e Autonomia (0 a 2 anos)",
    "descricao": "Um tratado completo sobre o sono infantil baseado em evidências científicas. Entenda a biologia do seu bebê para regular o sono sem treinamentos agressivos.",
    "cor": 0xFF3F51B5, // Indigo
    "icone": Icons.nights_stay,
    "autor": "Ref: Dr. Marc Weissbluth, Dr. Harvey Karp e SBP",
    "aulas": [
      {
        "titulo": "1. A Fisiologia do Sono",
        "subtitulo": "Melatonina, Cortisol e Adenosina",
        "texto": """
Para entender o sono, precisamos entender a química do cérebro. O sono do bebê é regido por dois processos principais que precisam estar sincronizados:

1. O Processo Homeostático (Pressão de Sono):
É o acúmulo de cansaço. Durante o tempo acordado, o cérebro acumula Adenosina. Quando o nível está ideal, o bebê dorme facilmente. Se o nível for baixo (pouco tempo acordado), ele não dorme. Se for excessivo, o corpo entra em estresse.

2. O Processo Circadiano (Relógio Biológico):
Regulado pela luz e escuridão. A ausência de luz estimula a Glândula Pineal a produzir Melatonina (o hormônio que 'abre o portão' do sono). A luz (especialmente azul/branca) inibe a melatonina e estimula o Cortisol (hormônio do alerta).

O PARADOXO DO CANSAÇO:
Quando um bebê fica acordado além da sua janela de tolerância, o cérebro interpreta isso como uma situação de perigo ("Se não dormi até agora, deve haver um urso por perto"). 
Resposta biológica: O corpo inunda a corrente sanguínea de Cortisol e Adrenalina.
Resultado: O bebê fica "elétrico", irritado, arqueia as costas e luta contra o sono. Ele está exausto, mas quimicamente impedido de relaxar.

CONCLUSÃO: O sono gera sono. Um bebê descansado dorme melhor; um bebê exausto dorme mal e acorda mais vezes (Efeito Vulcânico).
        """
      },
      {
        "titulo": "2. O 4º Trimestre e a Exterogestação",
        "subtitulo": "Por que recém-nascidos não dormem?",
        "texto": """
O ser humano nasce neurologicamente imaturo (neotenia). Os primeiros 3 meses são, biologicamente, o final da gestação ocorrendo fora do útero.

O AMBIENTE INTRAUTERINO vs. O BERÇO:
- Útero: Contenção total (apertado), barulho constante (90dB, som das artérias), movimento constante, temperatura controlada, nutrição contínua.
- Berço: Espaço aberto, silêncio absoluto, estático, variações de temperatura, fome cíclica.

Para o RN, o berço não é relaxante; é um deserto sensorial assustador.

A TÉCNICA DOS 5 S's (Dr. Harvey Karp):
Para ativar o "Reflexo de Acalmamento" e induzir o sono, precisamos replicar o útero:
1. Swaddle (Charutinho): A contenção evita o Reflexo de Moro (susto) que acorda o bebê.
2. Side/Stomach (Lado): Segurar de lado para acalmar (mas dormir sempre de barriga para cima!).
3. Shhh (Ruído Branco): O som chiado é essencial.
4. Swing (Balanço): Movimentos rítmicos e curtos (a "tremidinha" da cabeça).
5. Suck (Sucção): Peito, dedo ou chupeta (analgesia natural).

APLICAÇÃO: Use essas técnicas para acalmar, mas comece a reduzir a intervenção conforme o bebê cresce (após 3-4 meses).
        """
      },
      {
        "titulo": "3. Janelas de Sono e Sinais de Cansaço",
        "subtitulo": "O timing perfeito",
        "texto": """
A Janela de Sono é o tempo máximo que o bebê tolera ficar acordado antes de entrar em estresse (cortisol).

TABELA DE REFERÊNCIA (MÉDIAS):
- 0-1 mês: 45 a 60 min
- 2-3 meses: 1h15 a 1h30
- 4-5 meses: 1h45 a 2h15
- 6-8 meses: 2h30 a 3h
- 9-12 meses: 3h a 4h
- 12-18 meses: 4h a 5h30

LEITURA DE SINAIS (Aprenda a observar):
1. Sinais Precoces (A hora ideal): Olhar fixo/vidrado, ficar quieto, sobrancelhas avermelhadas, desinteresse por brinquedos. -> COLOQUE NO BERÇO AGORA.
2. Sinais Tardios (Já passou da hora): Bocejar, esfregar olhos, puxar orelha. -> AGIR RÁPIDO.
3. Sinais de Estresse (Tarde demais): Choro, irritabilidade, arquear as costas. -> É necessário acalmar o bebê totalmente antes de tentar fazê-lo dormir.

DICA: Se a soneca anterior foi curta (<45min), a próxima janela de sono será menor.
        """
      },
      {
        "titulo": "4. Higiene do Sono e Ambiente",
        "subtitulo": "Preparando o palco",
        "texto": """
O ambiente de sono deve ser um sinal claro para o cérebro. Não subestime a higiene do sono.

1. ESCURIDÃO TOTAL (Blackout):
Aos 4 meses, o bebê enxerga bem e se distrai com tudo. Qualquer fresta de luz ou led de babá eletrônica pode inibir a produção de melatonina ou estimular o despertar às 5am.
Teste: Estique o braço no quarto escuro. Se você vê sua mão, não está escuro o suficiente.

2. RUÍDO BRANCO:
Deve ser contínuo (não desligar no timer) e no volume de um chuveiro ligado (~50-60dB). Ele mascara ruídos externos (motos, portas) que causariam microdespertares e associa o som ao sono.

3. TEMPERATURA:
O corpo precisa resfriar levemente para entrar em sono profundo. O ideal é entre 22°C e 24°C. O superaquecimento é um fator de risco para SIDS (Morte Súbita) e causa despertares. Toque no peito/costas para checar a temperatura, não nas mãos.

4. SEGURANÇA:
Berço vazio. Sem protetores laterais (risco de sufocamento), sem travesseiro, sem pelúcias. Saco de dormir é mais seguro que cobertores soltos.
        """
      },
      {
        "titulo": "5. O Ritual do Sono",
        "subtitulo": "Programação Neurológica",
        "texto": """
O ritual não é apenas higiene; é uma sequência de gatilhos que diz ao cérebro: "Desligue". A consistência é mais importante que a duração.

RITUAL SUGERIDO (Início 30-40 min antes do sono):
1. Banho de relaxamento (água morna).
2. Hidratação/Massagem no quarto com luz baixa/âmbar.
3. Colocar a fralda noturna e o pijama/saco de dormir.
4. Ligar o Ruído Branco.
5. Alimentação (Peito ou mamadeira).
6. Higiene oral (se tiver dentes).
7. Momento de conexão (colinho, música calma ou oração).
8. Berço (Idealmente sonolento, mas ainda acordado).

IMPORTANTE: O ritual deve acontecer no quarto onde ele vai dormir. Evite fazer o bebê dormir na sala (com TV ligada) e transportá-lo. A transição de ambiente pode acordá-lo ou assustá-lo no meio da noite.
        """
      },
      {
        "titulo": "6. A Regressão dos 4 Meses",
        "subtitulo": "Maturação Neurológica",
        "texto": """
Seu bebê dormia bem e, de repente, acorda a cada hora? Isso é o marco dos 4 meses.

O QUE ACONTECE:
O bebê deixa de ter o padrão de sono de recém-nascido (apenas 2 fases: Ativo e Quieto) e passa a ter a arquitetura de sono adulta (4 fases + REM). Isso introduz ciclos de sono de 45-60 minutos.

O DESAFIO:
Ao final de cada ciclo, há um leve despertar (microdespertar).
- O adulto: vira de lado e dorme.
- O bebê com forte associação: acorda e percebe que as condições mudaram ("Dormi no colo e acordei no berço? Perigo!"). Ele chora para restaurar a condição inicial.

SOLUÇÃO:
Esta fase é permanente (é como o cérebro funcionará para sempre). A solução é trabalhar gentilmente a autonomia, ensinando o bebê a conectar os ciclos sem precisar de intervenção total dos pais a cada 60 minutos.
        """
      },
      {
        "titulo": "7. Sonecas do Dia",
        "subtitulo": "A arquitetura do dia",
        "texto": """
Sonecas não são opcionais até os 3 anos. Elas "limpam" a adenosina do cérebro.

CRONOGRAMA DE EVOLUÇÃO:
- RN a 4 meses: Sonecas caóticas, guiadas por janelas de vigília.
- 5 a 7 meses: Transição para 3 sonecas fixas (Manhã, Início da Tarde, Fim de Tarde - o 'catnap').
- 8 a 14 meses: Transição para 2 sonecas (Manhã e Tarde).
- 15 a 18 meses: Transição para 1 soneca (Pós-almoço).

A SONECA DO DESASTRE:
A última soneca do dia (fim de tarde) é difícil. O bebê está cansado, a "pressão de sono" é alta, mas o ritmo circadiano está dizendo para acordar. Essa soneca pode ser curta (30 min) e assistida (colo/carrinho) apenas para ele aguentar até a hora de dormir.

SONECA CURTA (<30 min):
Se o bebê acorda chorando após 30 min, ele não descansou. Tente a técnica de "Soneca Assistida": entre no quarto e tente ninar de volta imediatamente para ele emendar o próximo ciclo.
        """
      },
      {
        "titulo": "8. Associações de Sono",
        "subtitulo": "Muletas ou Ferramentas?",
        "texto": """
Uma associação é qualquer condição necessária para o início do sono.
Exemplos: Peito, mamadeira, colo, balanço, chupeta, segurar a mão da mãe.

ELAS SÃO UM PROBLEMA?
Apenas se estiverem insustentáveis para a família. Se você ama amamentar seu bebê a cada 2 horas à noite, não é um problema. Se você está exausta e deprimida, é um problema.

COMO RETIRAR (Substituição Gradual):
Não retire o suporte de uma vez (isso gera choro excessivo). Desça a "Escada de Intervenção":
1. Se ele dorme mamando -> Tente fazer dormir no colo (sem o peito).
2. Se ele dorme no colo balançando -> Tente fazer dormir no colo parado.
3. Se ele dorme no colo parado -> Tente colocar no berço quase dormindo e faça carinho/shhh no berço (shhh-pat).
4. Se ele precisa de carinho -> Tente apenas a voz.

Esse processo leva semanas, mas ensina a autonomia com acolhimento.
        """
      },
      {
        "titulo": "9. Desmame Noturno",
        "subtitulo": "Nutrição vs Hábito",
        "texto": """
Fisiologicamente, a maioria dos bebês saudáveis, com mais de 6 meses (ou 7kg) e com IA estabelecida, não precisa de calorias de madrugada (consulte seu pediatra).

POR QUE ELES ACORDAM?
1. Hábito Metabólico: O corpo acostumou a receber glicose às 2am e libera grelina (hormônio da fome) nessa hora.
2. Conforto/Sucção: É a forma que ele sabe voltar a dormir.

ESTRATÉGIA DE RETIRADA (Night Weaning):
- Reduza gradualmente.
- Mamadeira: Diminua 30ml a cada 2-3 noites. Quando chegar a 60ml, dilua ou retire.
- Peito: Cronometre. Se mama 10 min, faça 8, 6, 4, 2 minutos ao longo de 10 dias.
- Quando ele acordar e a oferta for mínima, ofereça colo/conforto em vez de leite. O pai pode assumir essa função para "quebrar" o cheiro do leite.
        """
      },
      {
        "titulo": "10. Despertar Matinal Precoce",
        "subtitulo": "Acordando às 5 da manhã",
        "texto": """
Lidar com o "Clube das 5" é desafiador. Causas principais:

1. LUZ: O sol nasce cedo. Se houver fresta, a melatonina cai.
2. PRIMEIRO SONO: Se ele acorda às 5h e você faz a primeira soneca às 7h, o corpo entende que 5h é hora de começar o dia. Empurre a primeira soneca para o horário correto (baseado em acordar às 6h30 ou 7h), mesmo que ele fique cansado.
3. EXAUSTÃO: Parece contra-intuitivo, mas dormir muito tarde ou pular sonecas faz o bebê acordar mais cedo (excesso de cortisol). Tente ANTECIPAR a hora de dormir em 20 minutos por alguns dias.

REGRA DE OURO: Trate qualquer despertar antes das 6:00 como "madrugada". Não acenda luzes, não brinque, não dê tela. Mantenha o tédio.
        """
      },
      {
        "titulo": "11. A Hora da Bruxa",
        "subtitulo": "A crise do fim de tarde",
        "texto": """
Entre 17h e 19h, bebês (especialmente RNs até 3 meses) choram sem parar. É a "disregulação sensorial". O sistema nervoso imaturo acumulou estímulos o dia todo e "transbordou".

O QUE NÃO FAZER:
Tentar ensinar, brincar com luzes, passar de colo em colo, TV alta.

O QUE FAZER:
Redução de danos.
- Banho de balde (ofurô) demorado.
- Pele a pele no escuro.
- Ruído branco.
- Antecipar o sono noturno. Às vezes, colocar o bebê para dormir às 18h30 é a única salvação e evita que ele entre em exaustão extrema.
        """
      },
      {
        "titulo": "12. Sono e Doença / Saltos",
        "subtitulo": "Gerenciando o caos",
        "texto": """
Bebês não são robôs. Doenças, nascimentos de dentes e saltos de desenvolvimento (aquisições motoras/cognitivas) VÃO atrapalhar o sono.

DURANTE A CRISE:
Sobrevivência e Acolhimento. Se ele precisa de colo a noite toda para respirar melhor (resfriado), dê colo. Se precisa mamar por dor, amamente. Não se preocupe em criar "maus hábitos" em 3 dias de febre.

PÓS-CRISE:
Assim que o bebê estiver bem (sem febre/dor), retome a rotina antiga IMEDIATAMENTE.
Ele vai protestar por 1 ou 2 noites ("Ei, ontem tinha colo!"), mas como a base já existia, ele retomará o padrão rapidamente. O erro é manter o colo por meses após um resfriado de 3 dias.
        """
      }
    ]
  },

  // ===========================================================================
  // CURSO 2: NUTRIÇÃO AVANÇADA (12 AULAS)
  // ===========================================================================
  {
    "id": "nutricao_completa",
    "titulo": "Nutrição Infantil",
    "subtitulo": "Do Aleitamento ao Prato da Família",
    "descricao": "Baseado nos protocolos da SBP, OMS e Nutrição Comportamental. Aprenda sobre BLW, prevenção de seletividade e segurança alimentar.",
    "cor": 0xFF4CAF50, // Green
    "icone": Icons.restaurant,
    "autor": "Diretrizes SBP e OMS",
    "aulas": [
      {
        "titulo": "1. Aleitamento: O Padrão Ouro",
        "subtitulo": "Fisiologia da Lactação",
        "texto": """
Até os 6 meses, o leite (materno ou fórmula) supre 100% das necessidades hidrícas e calóricas.

POR QUE NÃO DAR ÁGUA/CHÁ ANTES DOS 6 MESES?
O estômago do RN tem a capacidade de uma cereja (dia 1) a um ovo (mês 1). Qualquer ml de água ocupa o espaço do leite, que contém os nutrientes vitais. Isso pode levar à perda de peso e desnutrição. Além disso, o intestino imaturo é permeável ("aberto") e a introdução de outros fluidos aumenta drasticamente o risco de infecções e diarreia.

A PEGA CORRETA:
Dor não é normal. Fissuras indicam pega rasa.
- Boca bem aberta (peixinho).
- Lábios virados para fora.
- Queixo encostado na mama.
- Aréola assimétrica (mais visível acima da boca).
- Bochecha não faz covinha.
        """
      },
      {
        "titulo": "2. Sinais de Prontidão (6 Meses)",
        "subtitulo": "A maturação do corpo",
        "texto": """
A Introdução Alimentar (IA) depende de maturidade neurológica e gastrointestinal, não apenas da idade cronológica.

OS 5 SINAIS OBRIGATÓRIOS:
1. 6 Meses Completos: O intestino fecha a permeabilidade ("sela"), protegendo contra alergias.
2. Controle de Tronco: Senta-se com o mínimo de apoio, sem tombar para os lados (essencial para deglutição segura e tosse eficaz).
3. Reflexo de Protrusão diminuído: A língua para de empurrar tudo para fora automaticamente.
4. Coordenação Mão-Boca: Consegue mirar e levar objetos à boca.
5. Interesse Ativo: Olha os pais comendo e tenta pegar a comida.

Se o bebê tem 6 meses mas cai para o lado ao sentar, aguarde mais alguns dias/semanas estimulando o sentar no chão.
        """
      },
      {
        "titulo": "3. Métodos: BLW vs Tradicional",
        "subtitulo": "Escolhendo sua abordagem",
        "texto": """
TRADICIONAL (Papinhas):
- Vantagem: Controle maior da quantidade ingerida (pelos pais) e menos sujeira inicial.
- Regra: Amassar com o garfo. NUNCA liquidificar ou peneirar (o bebê precisa aprender a lidar com texturas para desenvolver a fala). Evoluir a textura rapidamente.

BLW (Baby-Led Weaning):
- O bebê se alimenta sozinho com pedaços seguros.
- Vantagem: Estimula autonomia, coordenação motora fina, mastigação e autorregulação de saciedade.
- Regra: Cortes seguros (bastão) e alimento macio.

PARTICIPATIVA (Mista):
- A família oferece colheradas de amassadinho, mas deixa pedaços de legumes/frutas na mão do bebê para exploração sensorial. É uma ótima transição.
        """
      },
      {
        "titulo": "4. Segurança: Engasgo vs GAG",
        "subtitulo": "O medo nº 1 dos pais",
        "texto": """
Você PRECISA saber diferenciar para não atrapalhar o aprendizado do bebê.

REFLEXO DE GAG (Ânsia de Vômito):
- O que é: Mecanismo de defesa. O alimento toca o fundo da língua e o cérebro o empurra para frente.
- Sinais: Bebê fica vermelho, faz barulho de ânsia, tosse, olhos lacrimejam.
- Ação: NADA. Mantenha a calma, sorria e encoraje ("Cospe, isso aí"). O bebê resolve sozinho. Se você enfiar o dedo, pode empurrar a comida para a traqueia.

ENGASGO (Obstrução da Via Aérea):
- O que é: Bloqueio real da respiração.
- Sinais: Bebê fica pálido ou arroxeado (cianose), olhos arregalados de pânico, SILÊNCIO ABSOLUTO (o ar não passa, o som não sai).
- Ação: MANOBRA DE HEIMLICH IMEDIATA. Não chacoalhe, não vire de cabeça para baixo pelos pés. Inicie as tapotagens nas costas. (Veja aba SOS).
        """
      },
      {
        "titulo": "5. Cortes Seguros (BLW)",
        "subtitulo": "A física do alimento",
        "texto": """
Até os 9 meses, o bebê usa a "preensão palmar" (pega com a mão toda). Ele não consegue pegar pedaços pequenos.

FORMATO SEGURO: BASTÃO (Finger Food).
- Tamanho: Do dedo indicador de um adulto.
- Textura: Macio o suficiente para amassar com a língua no céu da boca (teste pressionando com seu polegar e indicador).

EXEMPLOS:
- Banana: Descascada até a metade (para não escorregar).
- Brócolis: Cozido, ofereça o "buquê" com talo.
- Carne: Tira fibrosa grossa (para chupar o suco e ferro) ou almôndega macia.

PROIBIDOS (Risco de Aspiração):
- Formatos redondos (uva inteira, tomate cereja, ovo de codorna). CORTE SEMPRE NO COMPRIMENTO (Longitudinal).
- Alimentos duros (cenoura crua, maçã crua, castanhas inteiras).
- Folhas cruas inteiras (podem colar no céu da boca).
        """
      },
      {
        "titulo": "6. Grupos Alimentares",
        "subtitulo": "Montando o prato perfeito",
        "texto": """
O leite materno é pobre em Ferro e Zinco após os 6 meses. O prato deve focar nesses nutrientes.
Ofereça 1 alimento de cada grupo no almoço e jantar:

1. Energéticos (Carboidratos): Arroz, batata, mandioca, macarrão, milho. Dão energia para crescer.
2. Construtores (Proteínas): Carne bovina, frango, peixe, ovo (gema e clara), vísceras (fígado é superalimento).
3. Leguminosas (Ferro): Feijão, lentilha, grão de bico, ervilha.
4. Reguladores (Vitaminas/Fibras): Legumes (cenoura, abóbora, chuchu) e Verduras (espinafre, couve).
5. Gorduras Boas: Azeite de oliva extra virgem (um fio no prato pronto) ajuda no desenvolvimento cerebral.

Sobremesa: Fruta rica em Vitamina C (Laranja, Manga, Morango, Kiwi) para triplicar a absorção do ferro vegetal (feijão).
        """
      },
      {
        "titulo": "7. A Janela Imunológica",
        "subtitulo": "Prevenção de Alergias",
        "texto": """
Diretrizes antigas diziam para evitar ovo e peixe até 1 ano. A ciência atual (LEAP study) provou que isso AUMENTA alergias.
O ideal é apresentar os alérgenos potencias (Ovo, Peixe, Trigo, Amendoim, Leite e Derivados - iogurte natural/queijo) entre 6 e 9 meses.

PROTOCOLO DE INTRODUÇÃO DE ALÉRGENOS:
- Ofertar em casa (não na creche/restaurante).
- Pela manhã ou almoço (para ter o dia todo para observar).
- Pequena quantidade inicial.
- Um novo alérgeno por vez (espere 3 dias antes de introduzir outro alérgeno forte).
- Sinais de reação: Placas vermelhas (urticária), inchaço nos lábios/olhos, vômito em jato, dificuldade respiratória.
        """
      },
      {
        "titulo": "8. O que é PROIBIDO",
        "subtitulo": "Até os 2 anos",
        "texto": """
O paladar é formado nos primeiros 1000 dias. Proteja seu filho.

1. AÇÚCAR (Todos os tipos): Vicia o paladar, causa inflamação, sobrecarrega o pâncreas, predispõe a diabetes e obesidade.
2. MEL: Risco de Botulismo (bactéria que paralisa o sistema respiratório). O intestino do bebê <1 ano não tem flora para combater.
3. LEITE DE VACA (Como bebida): Pobre em ferro biodisponível, excesso de proteínas (sobrecarga renal) e causa micro-hemorragias intestinais (anemia).
4. SUCOS (Mesmo naturais): A fibra é quebrada, sobra a frutose livre (açúcar). Ensine a comer a fruta e beber água.
5. SAL: O sódio natural dos alimentos é suficiente. Tempere com alho, cebola, salsa, manjericão, orégano.
6. ULTRAPROCESSADOS: Danoninho, bolacha maisena, salsicha, nuggets. Cheios de sódio e corantes.
        """
      },
      {
        "titulo": "9. Água e Intestino",
        "subtitulo": "Evitando constipação",
        "texto": """
Começou a comer, a água é OBRIGATÓRIA.
O intestino vai mudar. O cocô vai ficar mais sólido e cheiroso.

Se o cocô ficar duro/seco (bolinhas) ou o bebê fizer força e chorar:
1. Aumente a oferta de água (copo aberto ou 360, evite mamadeira para não causar confusão de bicos).
2. Alimentos Laxativos ("Pê"): Mamão, Pêra, Ameixa, Pêssego, Abacate, Aveia, Azeite.
3. Evite temporariamente os Constipantes: Maçã, Banana (verde), Goiaba, Batata.

A fibra (comida) sem água vira um "cimento" no intestino.
        """
      },
      {
        "titulo": "10. Autorregulação e Saciedade",
        "subtitulo": "Quanto o bebê deve comer?",
        "texto": """
Nós decidimos O QUE, ONDE e QUANDO ofertar.
O bebê decide SE vai comer e QUANTO vai comer.

Bebês nascem com um regulador de saciedade perfeito. Se forçamos a "raspa do prato" ou fazemos "aviãozinho" para distrair e enfiar comida, quebramos esse sensor. Isso leva a obesidade ou transtornos alimentares no futuro.

Se o bebê fechar a boca, virar o rosto ou empurrar o prato: A REFEIÇÃO ACABOU.
Não ofereça leite imediatamente depois (espere o próximo horário) para ele não aprender que "se eu recusar o brócolis, ganho o peito/mamadeira".
        """
      },
      {
        "titulo": "11. A Crise de 1 Ano",
        "subtitulo": "Seletividade Fisiológica",
        "texto": """
"Meu bebê comia de tudo, agora não come nada."
Isso é esperado e normal.

MOTIVOS:
1. Desaceleração do Crescimento: No 1º ano, o bebê triplica de peso. No 2º ano, ganha só 2-3kg. Ele precisa de MENOS calorias. A fome diminui.
2. Curiosidade: O mundo é mais interessante que o prato.
3. Autonomia: Ele quer provar que manda no próprio corpo ("Não!").

O QUE FAZER:
Mantenha a oferta de alimentos saudáveis sem pressão. Continue colocando o brócolis no prato, mesmo que ele não toque. A exposição visual conta. Não substitua refeições por lanches ou leite excessivo.
        """
      },
      {
        "titulo": "12. Comportamento à Mesa",
        "subtitulo": "Exemplo arrasta",
        "texto": """
O bebê aprende por imitação (neurônios-espelho).
Se você come em pé, na frente da TV ou com o celular na mão, ele não vai querer ficar sentado no cadeirão comendo cenoura.

REGRAS DE OURO:
1. Comam juntos sempre que possível. Deixe ele ver você comendo o mesmo brócolis que está no prato dele.
2. Zero telas. A distração impede que o bebê sinta o sabor, a textura e o sinal de saciedade.
3. Sujeira faz parte. Deixe ele tocar na comida. Isso é exploração sensorial e reduz a seletividade.
        """
      }
    ]
  },

  // ===========================================================================
  // CURSO 3: DESENVOLVIMENTO 360º (18 AULAS - MASSIVO)
  // ===========================================================================
  {
    "id": "desenvolvimento_master",
    "titulo": "Desenvolvimento 360º",
    "subtitulo": "Motor, Cognitivo, Sensorial e Social (0-2 anos)",
    "descricao": "O guia definitivo da neuroevolução. Entenda os marcos motores (Pikler), saltos cognitivos (Piaget), desenvolvimento da fala e a importância do vínculo seguro.",
    "cor": 0xFFFF9800, // Orange
    "icone": Icons.emoji_objects,
    "autor": "Ref: Emmi Pikler, Maria Montessori, Jean Piaget",
    "aulas": [
      // --- BLOCO 1: O CÉREBRO E OS SENTIDOS ---
      {
        "titulo": "1. O Cérebro em Construção",
        "subtitulo": "Os primeiros 1000 dias",
        "texto": "O cérebro do bebê faz 1 milhão de sinapses (conexões) por segundo. Você é o arquiteto.\n\nNEUROPLASTICIDADE: O cérebro se molda conforme o uso. Experiências repetidas fortalecem caminhos neurais. Experiências não usadas são 'podadas'.\n\nALIMENTO CEREBRAL: Afeto, olho no olho, toque e conversa são tão vitais quanto o leite. O 'Estresse Tóxico' (negligência, violência, choro excessivo sem consolo) danifica a arquitetura cerebral permanentemente."
      },
      {
        "titulo": "2. Visão: Do Borrão ao Foco",
        "texto": "RN: Enxerga 30cm (distância do rosto da mãe ao mamar). Vê vultos e alto contraste (Preto e Branco).\n2-3 Meses: Fixa o olhar, segue objetos (rastreamento) e começa a ver vermelho/verde.\n6 Meses: Visão de profundidade (3D) se desenvolve plenamente, essencial para calcular distância ao engatinhar.\n\nESTÍMULO: Cartões de alto contraste, móbiles lentos, rosto humano."
      },
      {
        "titulo": "3. Audição e Música",
        "texto": "O bebê ouve desde o útero (24 semanas). A voz materna é o som mais calmante e reconhecível.\n\nLOCALIZAÇÃO SONORA: Aos 4 meses, o bebê deve virar a cabeça procurando a fonte do som.\n\nA IMPORTÂNCIA DA MÚSICA: Ritmos e rimas preparam o cérebro para a matemática e padrões de linguagem. Cante, mesmo desafinado. O bebê ama sua voz."
      },
      {
        "titulo": "4. Integração Sensorial",
        "subtitulo": "Tato e Vestibular",
        "texto": "O bebê aprende o mundo pelo corpo.\n\nTATO: Exponha a diferentes texturas (liso, áspero, gelado, morno, molhado). Isso previne a hipersensibilidade tátil (que causa seletividade alimentar).\n\nSISTEMA VESTIBULAR (Equilíbrio): O bebê precisa ser balançado, girado, colocado de cabeça para baixo (com segurança). Isso regula o equilíbrio e a noção espacial."
      },

      // --- BLOCO 2: DESENVOLVIMENTO MOTOR (PIKLER) ---
      {
        "titulo": "5. O Livre Movimento (Pikler)",
        "texto": "Emmi Pikler provou: O desenvolvimento motor é natural e não precisa ser 'ensinado', apenas permitido.\n\nO CHÃO É O MELHOR AMIGO: Evite 'containers' (bebê conforto, cadeirinhas de descanso, andadores) por longos períodos. Eles prendem o corpo do bebê e atrasam a musculatura.\n\nROUPA CONFORTÁVEL: O bebê precisa conseguir levar o pé à boca. Jeans e sapatos rígidos atrapalham."
      },
      {
        "titulo": "6. Controle Cervical (0-3m)",
        "subtitulo": "Tummy Time",
        "texto": "Segurar a cabeça é o primeiro marco. Fortalece as costas para todo o resto.\n\nTUMMY TIME (Bruços): Essencial desde a saída da maternidade (acordado e supervisionado). Comece com segundos. Faça no seu peito, no trocador, no chão. \n\nALERTA: Se aos 3 meses a cabeça cai para trás ao ser puxado pelas mãos (pull-to-sit), avise o pediatra."
      },
      {
        "titulo": "7. O Rolar (4-6m)",
        "texto": "A primeira locomoção. O bebê descobre que pode sair do lugar.\n\nNÃO VIRE O BEBÊ: Se você vira ele, você rouba o aprendizado do movimento. Coloque um brinquedo na lateral, fora do alcance, e deixe ele se esforçar, torcer o tronco e descobrir como virar.\n\nSEGURANÇA: Nunca mais deixe sozinho no trocador ou cama."
      },
      {
        "titulo": "8. O Sentar (6-8m)",
        "subtitulo": "Não force a posição",
        "texto": "Pela visão Pikleriana, o bebê só 'senta' de verdade quando ele consegue entrar e sair dessa posição sozinho (geralmente vindo de quatro apoios).\n\nO ERRO: Sentar o bebê que não tem força ('boneca de pano') cercado de almofadas. Isso comprime as vértebras e ele não aprende a reação de proteção (colocar a mão para não bater a cabeça ao cair)."
      },
      {
        "titulo": "9. Rastejar e Engatinhar (8-10m)",
        "texto": "O engatinhar é um marco crucial para a conexão entre os hemisférios cerebrais (movimento cruzado: braço direito, perna esquerda).\n\nBENEFÍCIOS: Fortalece o cinto escapular (ombros) e as mãos, o que será vital para a escrita fina na escola.\n\nNÃO PULE ETAPAS: Não estimule o andar antes do engatinhar. Deixe o bebê no chão."
      },
      {
        "titulo": "10. A Marcha (12-18m)",
        "texto": "Andar é um processo de coragem e equilíbrio.\nFases: Ficar de pé com apoio -> Cruzeiro (andar de lado nos móveis) -> Ficar de pé sem apoio (equilíbrio estático) -> Primeiros passos.\n\nANDADORES SÃO PROIBIDOS: A SBP condena. Eles causam acidentes graves (traumatismo craniano em escadas) e ensinam o bebê a andar errado (na ponta dos pés, sem usar o centro de gravidade)."
      },
      {
        "titulo": "11. Pés Descalços",
        "texto": "O pé do bebê é um órgão sensorial. Ele precisa sentir o chão para ajustar o equilíbrio e formar o arco plantar (a cava do pé).\n\nSapato rígido, só na rua para proteção. Em casa, sempre descalço ou meia antiderrapante. Sapatos 'ortopédicos' rígidos atrofiam a musculatura do pé."
      },

      // --- BLOCO 3: COGNITIVO E LINGUAGEM ---
      {
        "titulo": "12. Permanência do Objeto (8-9m)",
        "subtitulo": "Onde a mamãe foi?",
        "texto": "Até os 8 meses, 'longe dos olhos, longe do coração'. Se você sai do quarto, você deixou de existir.\n\nO SALTO: O bebê entende que as coisas continuam existindo mesmo sem ele ver. Isso gera a ANGÚSTIA DA SEPARAÇÃO. Ele chora porque sabe que você existe e quer você.\n\nBRINCADEIRA: 'Achou!' (Peek-a-boo) e esconder brinquedos embaixo de panos."
      },
      {
        "titulo": "13. Causa e Efeito",
        "subtitulo": "O pequeno cientista",
        "texto": "O bebê joga a colher no chão 10 vezes. Você acha que é birra. Ele acha que é Física.\nEle está testando a gravidade e a sua reação social.\n\nESTÍMULO: Brinquedos de ação-reação (aperta e toca música, martelo, caixas de permanência Montessori)."
      },
      {
        "titulo": "14. A Regra dos 3 T's (Linguagem)",
        "subtitulo": "Harvard Center",
        "texto": "Para desenvolver a fala:\n1. TUNE IN (Sintonize): Perceba o que interessa ao bebê e fale sobre isso.\n2. TALK MORE (Fale mais): Narre o dia. 'Agora vou limpar seu pé esquerdo'. Use palavras ricas, não infantilize a gramática.\n3. TAKE TURNS (Revezar): Fale e espere a resposta (um som, um olhar). Isso ensina o turno da conversação."
      },
      {
        "titulo": "15. Coordenação Motora Fina",
        "subtitulo": "A Pinça (9-12m)",
        "texto": "A capacidade de pegar objetos pequenos com o polegar e indicador.\n\nIMPORTÂNCIA: Fundamental para se alimentar sozinho (BLW) e, no futuro, segurar o lápis.\n\nATIVIDADE: Colocar macarrão penne em um palito, puxar fitas adesivas coladas na mesa, rasgar papel."
      },

      // --- BLOCO 4: SOCIAL E EMOCIONAL ---
      {
        "titulo": "16. O Vínculo (Attachment)",
        "texto": "A teoria do apego diz: Para explorar o mundo, a criança precisa de uma Base Segura.\nSe você acolhe o choro e está presente, o bebê se sente seguro para engatinhar para longe e brincar. Bebês 'independentes' demais podem, na verdade, estar inseguros sobre o retorno dos pais."
      },
      {
        "titulo": "17. O Estranhamento (6-9m)",
        "texto": "O bebê simpático de repente chora com a avó? Isso é ótimo!\nSignifica que ele desenvolveu a cognição para diferenciar 'Figuras de Apego' de 'Estranhos'. É um marco de inteligência e proteção. Não force o colo de ninguém. Respeite o tempo dele."
      },
      {
        "titulo": "18. Autonomia e o 'Não' (18m+)",
        "texto": "Perto dos 2 anos (Terrible Twos), a criança descobre que é um ser separado da mãe. A forma de afirmar essa existência é negando.\n\nO 'NÃO' é a primeira declaração de independência. \nESTRATÉGIA: Dê escolhas limitadas. Em vez de 'Vamos banhar?', diga: 'Você quer levar o pato ou o barco para o banho?'. Você controla o resultado, ele controla a escolha."
      }
      
      
    ]
  },
  {
    "id": "fala_sinais_pro",
    "titulo": "Fala e Comunicação",
    "subtitulo": "Estimulação Verbal e Baby Signs",
    "descricao": "Baseado em estudos de Harvard e Fonoaudiologia. Aprenda a acelerar a fala do seu bebê, reduzir a frustração com sinais (Baby Signs) e identificar sinais de alerta.",
    "cor": 0xFF9C27B0, // Purple
    "icone": Icons.record_voice_over,
    "autor": "Ref: Harvard Center on the Developing Child & Acredolo/Goodwyn",
    "aulas": [
      {
        "titulo": "1. O Cérebro Social",
        "subtitulo": "Serve and Return (Servir e Devolver)",
        "texto": "A linguagem não se aprende passivamente (ouvindo TV ou rádio). Ela depende de INTERAÇÃO.\n\nO CONCEITO DE HARVARD: 'Serve and Return'.\nImagine um jogo de tênis.\n1. O bebê 'sacam' (faz um som, aponta, olha).\n2. Você PRECISA 'rebater' (olhar de volta, responder, nomear).\n\nSe o bebê saca e ninguém rebate (pais no celular), a conexão neural daquela tentativa de comunicação é podada. Para o bebê falar, ele precisa saber que falar gera resultado."
      },
      {
        "titulo": "2. O Poder do 'Manhês'",
        "subtitulo": "Não é falar errado",
        "texto": "Falar 'Tatibitate' (errado) é prejudicial. Mas o 'Manhês' (Parentese) é CIÊNCIA.\n\nO QUE É: Falar com voz mais aguda, cantada, vogais alongadas e ritmo lento ('Oiii, meu amoooor').\n\nPOR QUE FUNCIONA: O cérebro do bebê é programado para filtrar sons graves e focar em frequências agudas. O Manhês funciona como um 'marca-texto' auditivo, ajudando o bebê a separar onde começa e termina cada palavra. Use sem medo, mas pronunciando as palavras corretamente."
      },
      {
        "titulo": "3. Baby Signs (Sinais)",
        "subtitulo": "Comunicação sem choro",
        "texto": "O bebê controla as mãos meses antes de controlar a língua. Ensinar sinais NÃO atrasa a fala; pelo contrário, acelera a comunicação e reduz o estresse (cortisol) causado pela frustração de não ser entendido.\n\nQUANDO COMEÇAR: A partir dos 6 meses.\n\nCOMO FAZER: Sempre fale a palavra junto com o gesto. Repetição é a chave."
      },
      {
        "titulo": "4. Sinais Essenciais: 'Mais' e 'Acabou'",
        "subtitulo": "Redutores de birra",
        "texto": "SINAL DE 'MAIS':\nJunte as pontas dos dedos das duas mãos e toque uma mão na outra repetidamente (bico com bico).\nUse quando: Ele quiser mais comida, mais brincadeira.\n\nSINAL DE 'ACABOU':\nLevante as mãos abertas e gire os pulsos (como se dissesse 'não tem mais').\nUse quando: A comida acabar, o banho terminar. Isso ajuda o bebê a antecipar o fim da atividade e aceitar a transição."
      },
      {
        "titulo": "5. Sinais Essenciais: 'Leite' e 'Comer'",
        "subtitulo": "Necessidades básicas",
        "texto": "SINAL DE 'LEITE':\nAbra e feche a mão (como se estivesse ordenhando uma vaca ou apertando uma bolinha).\nUse: Toda vez que for amamentar ou dar mamadeira.\n\nSINAL DE 'COMER':\nJunte os dedos de uma mão em bico e leve à boca repetidamente.\nUse: Em todas as refeições."
      },
      {
        "titulo": "6. A Narração da Vida",
        "subtitulo": "Enriquecimento de Vocabulário",
        "texto": "Seu bebê é um estudante de uma língua estrangeira em imersão total. Você é o professor.\n\nTÉCNICA DO NARRADOR:\nDescreva o que ele está vendo, sentindo e fazendo. Não faça perguntas ('O que é isso?'), dê respostas.\n\nErrado: (Silêncio enquanto troca fralda).\nCerto: 'Vou levantar sua perna. Ui, que fralda molhada! O lenço é gelado, né? Agora está sequinho.'\n\nIsso constrói o 'Vocabulário Passivo' (o que ele entende), que é a base para o 'Vocabulário Ativo' (o que ele fala)."
      },
      {
        "titulo": "7. O Uso da Chupeta",
        "subtitulo": "Impacto na Fala",
        "texto": "A chupeta é ótima para acalmar (sucção não-nutritiva), mas é inimiga da fala se usada acordado.\n\nO PROBLEMA FÍSICO:\nEla deixa a língua em posição baixa e flácida. Para falar sons como T, D, N, L, a língua precisa subir no céu da boca. O uso constante cria uma 'barreira física' e o bebê aprende a falar com a língua solta.\n\nREGRA: Chupeta apenas para DORMIR. Acordou? Tira."
      },
      {
        "titulo": "8. Telas e Atraso de Fala",
        "subtitulo": "O perigo do silêncio",
        "texto": "A SBP recomenda ZERO telas até 2 anos. Por quê?\n\n1. Passividade: A tela fala, mas não espera resposta. O cérebro do bebê aprende a linguagem pela interação (troca), não pela recepção.\n2. Hiperestímulo Visual: O cérebro foca tanto na luz e movimento que 'desliga' o processamento auditivo.\n\nEstudos mostram que cada 30 min de tela por dia aumenta em 49% o risco de atraso na fala expressiva."
      },
      {
        "titulo": "9. Marcos de Fala (Red Flags)",
        "subtitulo": "Quando procurar ajuda?",
        "texto": "Cada bebê tem seu tempo, mas existem limites.\n\n- 12 Meses: Não balbucia, não aponta, não dá tchau, não atende pelo nome.\n- 18 Meses: Fala menos de 6 palavras, não imita sons.\n- 24 Meses: Fala menos de 50 palavras, não junta duas palavras ('quer água', 'dá bola').\n\nIntervenção precoce muda tudo. Na dúvida, procure um fonoaudiólogo. Não espere 'o tempo dele' se houver atraso significativo."
      },
      {
        "titulo": "10. Leitura Compartilhada",
        "subtitulo": "Não é só ler",
        "texto": "Não leia apenas o texto do livro. Faça a 'Leitura Dialógica'.\n\n1. Aponte para as figuras.\n2. Faça os sons dos animais/objetos.\n3. Relacione com a vida real ('Olha o cachorro! Igual ao Totó da vovó').\n\nLivros com abas e texturas mantêm o interesse motor enquanto você estimula a audição."
      }
    ]
  },

  // ===========================================================================
  // CURSO 5: MASSAGEM E ALÍVIO (SHANTALA)
  // ===========================================================================
  {
    "id": "massagem_pro",
    "titulo": "Massagem e Toque",
    "subtitulo": "Shantala, Cólicas e Vínculo",
    "descricao": "Técnicas manuais para acalmar o sistema nervoso, aliviar dores de gases e fortalecer o sistema imunológico através do toque terapêutico.",
    "cor": 0xFFFF4081, // Pink Accent
    "icone": Icons.spa,
    "autor": "Baseado em Frédérick Leboyer (Shantala)",
    "aulas": [
      {
        "titulo": "1. A Ciência do Toque",
        "subtitulo": "Ocitocina e Mielinização",
        "texto": "A pele é o primeiro órgão a se formar. O toque libera Ocitocina (hormônio do amor) tanto no bebê quanto na mãe/pai, reduzindo o Cortisol imediatamente.\n\nAlém do vínculo, a massagem estimula o Nervo Vago, melhorando a digestão e a absorção de nutrientes, e acelera a mielinização dos neurônios (o bebê fica mais 'esperto' motoramente)."
      },
      {
        "titulo": "2. Preparando o Ambiente",
        "subtitulo": "O cenário ideal",
        "texto": "A Shantala é um diálogo sem palavras. Você precisa estar presente.\n\nCHECKLIST:\n1. Mãos quentes (esfregue uma na outra).\n2. Sem anéis ou relógios.\n3. Óleo vegetal comestível (Coco, Semente de Uva, Amêndoas Doce). Se o bebê colocar a mão na boca, não tem problema.\n4. Bebê nu (ou de fralda).\n5. Olho no olho. \n\nNUNCA faça se o bebê estiver chorando, com fome ou logo após mamar (risco de refluxo)."
      },
      {
        "titulo": "3. O Protocolo de Cólica",
        "subtitulo": "Alívio de Gases e Disquesia",
        "texto": "Faça esta sequência quando o bebê estiver calmo (prevenção) ou no início do desconforto.\n\n1. O RELOGINHO: Com a mão espalmada, faça círculos na barriga no sentido horário (do ponto de vista de quem olha para o bebê). Isso segue o trajeto do intestino grosso.\n2. O U INVERTIDO (I Love You): Desenhe um 'I' no lado esquerdo do bebê. Um 'L' invertido do lado direito para o esquerdo. Um 'U' invertido de baixo para cima e para o lado.\n3. BICICLETINHA: Segure os tornozelos e leve os joelhos em direção à barriga, segure por 5 segundos e solte. Repita."
      },
      {
        "titulo": "4. Massagem no Peito",
        "subtitulo": "Abrindo o livro",
        "texto": "Ótimo para relaxar a tensão do choro e melhorar a respiração.\n\nMOVIMENTO: Junte as duas mãos no centro do peito do bebê. Deslize suavemente para as laterais (como alisando as páginas de um livro aberto), descendo pelos braços.\n\nRepita num ritmo lento e contínuo. Mantenha contato visual."
      },
      {
        "titulo": "5. Braços e Mãos",
        "subtitulo": "Braceletes",
        "texto": "Ajuda na consciência corporal.\n\n1. DESLIZAMENTO: Segure o braço com uma mão e deslize a outra do ombro até o punho.\n2. ROSQUINHA (Torção suave): Faça movimentos de torção leve (como torcer uma toalha molhada, mas com delicadeza extrema) do ombro ao punho.\n3. MÃOS: Abra a palma da mão do bebê com seus polegares, massageando do centro para os dedos."
      },
      {
        "titulo": "6. Pernas e Pés",
        "subtitulo": "Reflexologia Básica",
        "texto": "As pernas carregam muita tensão de crescimento.\n\n1. DESLIZAMENTO: Da coxa ao tornozelo, alternando as mãos.\n2. SOLA DO PÉ: Pressione com o polegar do calcanhar até os dedinhos. Essa região tem terminações nervosas que relaxam o corpo todo.\n3. DEDINHOS: Gire suavemente cada dedo do pé."
      },
      {
        "titulo": "7. Costas",
        "subtitulo": "Fortalecimento",
        "texto": "Vire o bebê de bruços (na transversal das suas pernas ou no trocador).\n\n1. VAI E VEM: Com as mãos espalmadas, faça movimentos horizontais do pescoço até o bumbum (uma mão vai, outra vem).\n2. FINALIZAÇÃO: Deslize a mão da nuca até os calcanhares em um movimento longo e lento. Isso integra o corpo todo."
      },
      {
        "titulo": "8. O Rosto",
        "subtitulo": "Relaxando a sucção",
        "texto": "Bebês acumulam tensão na mandíbula por causa da sucção (mamar).\n\n1. TESTA: Com os polegares, alise do centro da testa para as têmporas.\n2. SOBRANCELHAS: Contorne as sobrancelhas.\n3. BOCHECHAS: Faça pequenos círculos na articulação da mandíbula (perto da orelha) para relaxar a mordida.\n4. SORRISO: Desenhe um sorriso com os dedos acima do lábio superior e abaixo do inferior."
      }
    ]
  },
];