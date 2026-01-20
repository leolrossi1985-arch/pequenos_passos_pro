// Calendário Nacional de Vacinação (Brasil)
final List<Map<String, dynamic>> vacinasPadrao = [
  {'id': 'vac_ao_nascer_1', 'meses': 0, 'nome': 'BCG', 'descricao': 'Dose única (famosa marquinha no braço).'},
  {'id': 'vac_ao_nascer_2', 'meses': 0, 'nome': 'Hepatite B', 'descricao': '1ª dose ao nascer.'},
  
  {'id': 'vac_2m_1', 'meses': 2, 'nome': 'Pentavalente', 'descricao': '1ª dose (Difteria, Tétano, Coqueluche, Hep B, Hib).'},
  {'id': 'vac_2m_2', 'meses': 2, 'nome': 'VIP (Poliomielite)', 'descricao': '1ª dose (Injetável).'},
  {'id': 'vac_2m_3', 'meses': 2, 'nome': 'Pneumocócica 10', 'descricao': '1ª dose.'},
  {'id': 'vac_2m_4', 'meses': 2, 'nome': 'Rotavírus', 'descricao': '1ª dose (Gotinha oral).'},

  {'id': 'vac_3m_1', 'meses': 3, 'nome': 'Meningocócica C', 'descricao': '1ª dose.'},

  {'id': 'vac_4m_1', 'meses': 4, 'nome': 'Pentavalente', 'descricao': '2ª dose.'},
  {'id': 'vac_4m_2', 'meses': 4, 'nome': 'VIP (Poliomielite)', 'descricao': '2ª dose.'},
  {'id': 'vac_4m_3', 'meses': 4, 'nome': 'Pneumocócica 10', 'descricao': '2ª dose.'},
  {'id': 'vac_4m_4', 'meses': 4, 'nome': 'Rotavírus', 'descricao': '2ª dose.'},

  {'id': 'vac_5m_1', 'meses': 5, 'nome': 'Meningocócica C', 'descricao': '2ª dose.'},

  {'id': 'vac_6m_1', 'meses': 6, 'nome': 'Pentavalente', 'descricao': '3ª dose.'},
  {'id': 'vac_6m_2', 'meses': 6, 'nome': 'VIP (Poliomielite)', 'descricao': '3ª dose.'},
  {'id': 'vac_6m_3', 'meses': 6, 'nome': 'Influenza (Gripe)', 'descricao': 'Dose anual (em campanha).'},

  {'id': 'vac_9m_1', 'meses': 9, 'nome': 'Febre Amarela', 'descricao': 'Dose inicial.'},

  {'id': 'vac_12m_1', 'meses': 12, 'nome': 'Tríplice Viral', 'descricao': 'Sarampo, Caxumba, Rubéola.'},
  {'id': 'vac_12m_2', 'meses': 12, 'nome': 'Pneumocócica 10', 'descricao': 'Reforço.'},
  {'id': 'vac_12m_3', 'meses': 12, 'nome': 'Meningocócica C', 'descricao': 'Reforço.'},

  {'id': 'vac_15m_1', 'meses': 15, 'nome': 'DTP (Tríplice Bacteriana)', 'descricao': '1º Reforço.'},
  {'id': 'vac_15m_2', 'meses': 15, 'nome': 'VOP (Poliomielite)', 'descricao': '1º Reforço (Gotinha).'},
  {'id': 'vac_15m_3', 'meses': 15, 'nome': 'Hepatite A', 'descricao': 'Dose única.'},
  {'id': 'vac_15m_4', 'meses': 15, 'nome': 'Tetra Viral', 'descricao': 'Tríplice + Varicela.'},
  
  {'id': 'vac_4anos_1', 'meses': 48, 'nome': 'DTP', 'descricao': '2º Reforço.'},
  {'id': 'vac_4anos_2', 'meses': 48, 'nome': 'VOP', 'descricao': '2º Reforço.'},
  {'id': 'vac_4anos_3', 'meses': 48, 'nome': 'Varicela', 'descricao': 'Reforço.'},
];