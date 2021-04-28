class SamplesState {
  final List<int> samples;

  SamplesState(this.samples);

  factory SamplesState.initial() {
    return SamplesState(List<int>.filled(512, 128));
  }
}
