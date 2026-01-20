import 'package:fl_chart/fl_chart.dart';

class GrowthStandards {
  // Gera os pontos das curvas Min/Max baseados no peso inicial
  // Retorna [ListaMinima, ListaMaxima]
  static List<List<FlSpot>> calcularCurvasEsperadas({
    required double pesoInicial, // Em Kg
    required int mesesTotais,    // Até quantos meses projetar
  }) {
    List<FlSpot> curveMin = [];
    List<FlSpot> curveMax = [];

    double pesoMinAtual = pesoInicial;
    double pesoMaxAtual = pesoInicial;

    // Adiciona ponto inicial (Mês 0)
    curveMin.add(FlSpot(0, pesoInicial));
    curveMax.add(FlSpot(0, pesoInicial));

    // Projeta mês a mês
    for (int mes = 1; mes <= mesesTotais; mes++) {
      // TAXAS DE GANHO DE PESO (Baseado na OMS - Médias aproximadas)
      // Valores em kg/mês
      double ganhoMin = 0;
      double ganhoMax = 0;

      if (mes <= 3) {
        // 0-3 meses: Ganho rápido (700g - 1kg/mês)
        ganhoMin = 0.700;
        ganhoMax = 1.000;
      } else if (mes <= 6) {
        // 3-6 meses: (500g - 800g/mês)
        ganhoMin = 0.500;
        ganhoMax = 0.800;
      } else if (mes <= 9) {
        // 6-9 meses: (300g - 500g/mês)
        ganhoMin = 0.300;
        ganhoMax = 0.500;
      } else if (mes <= 12) {
        // 9-12 meses: (200g - 400g/mês)
        ganhoMin = 0.200;
        ganhoMax = 0.400;
      } else {
        // 1 ano+: (150g - 300g/mês)
        ganhoMin = 0.150;
        ganhoMax = 0.300;
      }

      pesoMinAtual += ganhoMin;
      pesoMaxAtual += ganhoMax;

      // No gráfico, o X geralmente é o índice do registro. 
      // Mas para curvas de referência, o X precisa ser o TEMPO (Meses ou Semanas).
      // Aqui vamos gerar pontos que serão mapeados na tela.
      // Nota: Isso assume que o gráfico principal também está ordenado por tempo/idade.
      
      // Vamos retornar pontos baseados em MESES para facilitar
      curveMin.add(FlSpot(mes.toDouble(), pesoMinAtual));
      curveMax.add(FlSpot(mes.toDouble(), pesoMaxAtual));
    }

    return [curveMin, curveMax];
  }
}