class OnboardingState {
  final int step;
  final bool completed;

  const OnboardingState({required this.step, required this.completed});

  factory OnboardingState.initial() {
    return const OnboardingState(step: 0, completed: false);
  }

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    return OnboardingState(
      step: json['step'] ?? 0,
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'completed': completed,
    };
  }
}
