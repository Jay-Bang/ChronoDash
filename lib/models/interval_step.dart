class IntervalStep {
  final int durationSeconds;
  final String speedLabel;
  final String description; // Optional, e.g. "Warm up", "Sprint"

  const IntervalStep({
    required this.durationSeconds,
    required this.speedLabel,
    this.description = '',
  });
}
