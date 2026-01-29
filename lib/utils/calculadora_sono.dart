
class CalculadoraSono {
  
  /// Retorna a janela de vigília ideal (tempo acordado) em minutos,
  /// baseada na idade do bebê em meses.
  /// 
  /// A lógica segue uma progressão suave para evitar grandes saltos,
  /// focando no limite superior da janela "saudável" antes do bebê ficar exausto.
  static int getJanelaVigiliaMinutos(int meses) {
    if (meses < 1) return 60;   // 0 meses: 45-60 min
    if (meses == 1) return 75;  // 1 mês: 60-75 min
    if (meses == 2) return 90;  // 2 meses: 75-90 min
    if (meses == 3) return 105; // 3 meses: 90-105 min
    if (meses == 4) return 120; // 4 meses: 1h30-2h
    if (meses == 5) return 135; // 5 meses: 2h-2h15
    if (meses == 6) return 150; // 6 meses: 2h15-2h30
    if (meses == 7) return 165; // 7 meses: 2h30-2h45
    if (meses == 8) return 180; // 8 meses: 2h45-3h
    if (meses == 9) return 195; // 9 meses: 3h-3h15
    if (meses == 10) return 210; // 10 meses: 3h15-3h30
    if (meses == 11) return 225; // 11 meses: 3h30-3h45
    if (meses >= 12 && meses < 15) return 240; // 12-14 meses: 4h
    if (meses >= 15 && meses < 18) return 300; // 15-18 meses: 5h
    
    return 360; // 18+ meses: 6h (Uma soneca ou nenhuma)
  }

  /// Retorna uma descrição amigável sobre o sono nesta fase
  static String getDicaSono(int meses) {
    if (meses < 3) return "Nesta fase, o bebê dorme muito e não tem hora para acordar. O foco é evitar que ele fique acordado por mais de 1h direto.";
    if (meses < 6) return "O ritmo circadiano começa a se formar. Tente estabelecer uma rotina de 'comer, brincar, dormir'.";
    if (meses < 12) return "A maioria dos bebês faz 2 sonecas (manhã e tarde). Fique atento aos sinais de sono antes da janela fechar.";
    return "Transição para 1 soneca pode acontecer. Se ele pular a da manhã, antecipe a da tarde e o horário de dormir.";
  }
}
