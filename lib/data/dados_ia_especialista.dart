
import '../utils/calculadora_desenvolvimento.dart';
import '../utils/calculadora_sono.dart';

class DadosIAEspecialista {
  
  // ===========================================================================
  // 1. SONO (O maior problema dos pais)
  // ===========================================================================
  static String diagnosticarSono(int meses, int horaAtual) {
    // Análise da Hora do Dia (Cronobiologia)
    String conselhoHora = "";
    if (horaAtual >= 17 && horaAtual <= 19) {
      conselhoHora = "\n\n⚠️ **Alerta de Hora:** São entre 17h e 19h. Esse é o horário clássico da 'Hora da Bruxaria'. O bebê não chora só por sono, mas por *descompressão* do dia. Diminua as luzes e evite interações agitadas.";
    } else if (horaAtual >= 0 && horaAtual < 5) {
      conselhoHora = "\n\n🌙 **Madrugada:** Mantenha o ambiente em breu total. Não converse, não faça contato visual estimulante. O bebê precisa entender que a madrugada é entediante.";
    }

    // Diagnóstico por Idade
    if (meses < 1) {
      return "Nesta fase (recém-nascido), o bebê **não tem ritmo circadiano**. Ele dorme e acorda guiado apenas pela fome. \n\n✅ **O que fazer:** Foque apenas em diferenciar o ambiente (Dia = Claridade/Barulho; Noite = Escuro/Silêncio). Não tente impor horários agora.$conselhoHora";
    }
    
    if (meses <= 3) {
      return "Com $meses meses, a melatonina começa a ser produzida, mas a 'Janela de Vigília' é curta (60 a 90 min). \n\n🚫 **Erro comum:** Achar que deixar o bebê acordado cansa ele. Pelo contrário! Se passar de 90min, ele entra em 'Efeito Vulcânico' (excesso de cortisol) e luta para dormir.$conselhoHora";
    }
    
    if (meses == 4) {
      return "⚠️ **Regressão dos 4 Meses:** Seu bebê está na fase mais difícil do sono! O ciclo de sono mudou e agora ele acorda levemente a cada 45min. \n\n✅ **A solução:** Ele precisa aprender a emendar os ciclos. Não crie novos hábitos de dependência (como ninar no colo a cada despertar) se não quiser mantê-los por meses.$conselhoHora";
    }
    
    if (meses <= 6) {
      return "Aos $meses meses, o ideal são **3 sonecas** por dia. A última soneca deve acabar até às 17h para não atrapalhar a noite. \n\n💡 **Dica:** O hormônio do crescimento (GH) tem pico no início da noite. Tente colocar para dormir entre 19h e 20h.$conselhoHora";
    }
    
    if (meses <= 12) {
      return "Nesta fase, a **Angústia da Separação** afeta o sono. Ele acorda e grita porque acha que você sumiu. \n\n✅ **Treino:** Brinque muito de 'cadê-achou' durante o dia para ele entender que você some e volta. Mantenha a rotina noturna inegociável.$conselhoHora";
    }
    
    return "Após 1 ano, a maioria dos bebês migra para **1 soneca longa** após o almoço. Se ele estiver resistindo à noite, verifique se a soneca da tarde não está terminando muito tarde (após as 15h30).$conselhoHora";
  }

  // ===========================================================================
  // 2. ALIMENTAÇÃO & PICOS
  // ===========================================================================
  static String diagnosticarFome(int meses, int semanasVida) {
    // Picos de Crescimento (Fome insaciável)
    final picos = [3, 6, 12, 24]; // Semanas aproximadas (3 sem, 6 sem, 3 meses, 6 meses)
    bool emPico = picos.any((p) => (semanasVida - p).abs() <= 1);

    String textoPico = emPico 
      ? "\n\n🔥 **ALERTA DE PICO:** Pela idade ($semanasVida semanas), ele provavelmento está em um PICO DE CRESCIMENTO. A demanda por leite vai dobrar por 2 ou 3 dias. É normal! Não é falta de leite, é calibragem." 
      : "";

    if (meses < 6) {
      return "Até os 6 meses, a recomendação é **Aleitamento Exclusivo** (Peito ou Fórmula). \n\n🚫 Não dê água ou chás. O leite já hidrata. Se ele parece pedir comida, observe se não é apenas curiosidade ou fase oral (levar tudo à boca).$textoPico";
    }
    
    if (meses == 6) {
      return "🎉 **Introdução Alimentar:** Começou a sujeira! Lembre-se: 'Até 1 ano, o leite é o principal alimento'. \n\n✅ A comida agora é para apresentar texturas e sabores, não para encher a barriga. Se ele comer 1 colher, é vitória. Não force.$textoPico";
    }
    
    return "Com $meses meses, o bebê já pode participar das refeições da família (com pouco sal). \n\n💡 **Seletividade:** É normal ele rejeitar o que amava ontem. Continue oferecendo sem pressão. O bebê precisa de até 15 exposições para aceitar um sabor novo.";
  }

  // ===========================================================================
  // 3. SALTOS & COMPORTAMENTO
  // ===========================================================================
  static String diagnosticarComportamento(int semanasVida) {
    // Consulta a calculadora de saltos existente
    final statusSalto = CalculadoraDesenvolvimento.getStatusSemana(semanasVida);
    final tituloSalto = CalculadoraDesenvolvimento.getTituloFase(semanasVida);

    if (statusSalto == 'raio' || statusSalto == 'nuvem') {
      return "⚡ **Você está no olho do furacão!** \n\nSeu bebê está na $semanasVidaª semana, passando pelo salto: **$tituloSalto**. \n\nSintomas clássicos:\n1. 'Grudinho' (quer colo o tempo todo).\n2. Dorme pior.\n3. Come pior.\n\nIsso acontece porque o cérebro dele está atualizando. Tenha paciência, é um sinal de saúde e inteligência!";
    }

    return "Na $semanasVidaª semana, o desenvolvimento está mais estável (fase 'Ensolarada'). Aproveite para treinar as habilidades novas que ele aprendeu no último salto ($tituloSalto).";
  }

  // ===========================================================================
  // 4. CHORO (TRIAGEM)
  // ===========================================================================
  static String checklistChoro(int meses) {
    return "O choro é a única 'fala' do bebê. Vamos investigar por eliminação:\n\n"
           "1. **Fome?** (Faz mais de 3h que comeu?)\n"
           "2. **Sono?** (Está acordado há mais de ${CalculadoraSono.getJanelaVigiliaMinutos(meses)} min?)\n"
           "3. **Fralda/Calor/Frio?** (Cheque a nuca, não as mãos)\n"
           "4. **Tédio ou Excesso?** (Mude de cômodo)\n"
           "5. **Dor?** (Esprema a barriguinha - gases? Gengiva inchada?)\n\n"
           "💡 *Dica de Ouro:* Tente o 'Charutinho' (se < 4 meses) e Ruído Branco alto (som de útero).";
  }
}
