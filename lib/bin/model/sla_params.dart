class SlaParams {
  final int atendimentoInicio; // hora de início do atendimento
  final int atendimentoFim; // hora de término do atendimento
  final int tempoMinimoResposta; // tempo mínimo de resposta em horas
  final int tempoMaximoResolucao; // tempo máximo de resolução em horas
  final bool consideraInicioForaExpediente;
  SlaParams(
      {this.atendimentoInicio = 8,
      this.atendimentoFim = 17,
      this.tempoMinimoResposta = 2,
      this.tempoMaximoResolucao = 8,
      this.consideraInicioForaExpediente = true});
}
