class IntervalStep {
  final int durationSeconds;
  final String speedLabel;
  final String description;

  IntervalStep({
    required this.durationSeconds,
    required this.speedLabel,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'durationSeconds': durationSeconds,
        'speedLabel': speedLabel,
        'description': description,
      };

  factory IntervalStep.fromJson(Map<String, dynamic> json) {
    return IntervalStep(
      durationSeconds: json['durationSeconds'] ?? 60,
      speedLabel: json['speedLabel'] ?? '4.0',
      description: json['description'] ?? '',
    );
  }
}
