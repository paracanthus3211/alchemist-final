class DailyTaskModel {
  final int id;
  final String taskName;
  final String taskType;
  final String? description;
  final int targetValue;
  final int xpReward;
  final bool isActive;
  final int currentProgress;
  final bool isCompleted;
  final List<dynamic>? stages;
  final List<int>? completedStages;

  DailyTaskModel({
    required this.id,
    required this.taskName,
    required this.taskType,
    this.description,
    required this.targetValue,
    required this.xpReward,
    required this.isActive,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.stages,
    this.completedStages,
  });

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) {
    // Handle completed_stages which might be a Map instead of List from PHP
    List<int> parseCompletedStages(dynamic val) {
      if (val is List) return List<int>.from(val.map((e) => int.tryParse(e.toString()) ?? 0));
      if (val is Map) return val.values.map((e) => int.tryParse(e.toString()) ?? 0).toList().cast<int>();
      return [];
    }

    return DailyTaskModel(
      id: json['id'] ?? 0,
      taskName: json['task_name'] ?? '',
      taskType: json['task_type'] ?? '',
      description: json['description'],
      targetValue: int.tryParse(json['target_value']?.toString() ?? '1') ?? 1,
      xpReward: int.tryParse(json['xp_reward']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
      currentProgress: int.tryParse(json['current_progress']?.toString() ?? '0') ?? 0,
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1 || json['is_completed'] == '1',
      stages: json['stages'] is List ? json['stages'] : null,
      completedStages: parseCompletedStages(json['completed_stages']),
    );
  }

  Map<String, dynamic> toJson() => {
        'task_name': taskName,
        'task_type': taskType,
        'description': description,
        'target_value': targetValue,
        'xp_reward': xpReward,
        'is_active': isActive,
      };

  /// Human-readable label for task type
  String get taskTypeLabel {
    switch (taskType) {
      case 'FINISH_LESSONS':
        return 'Complete Quiz (menyelesaikan tugas)';
      case 'GAIN_XP':
        return 'Gain XP';
      case 'READ_ARTICLE':
        return 'Read Article';
      case 'LAB_EXPERIMENT':
        return 'Lab Experiment';
      case 'DAILY_LOGIN':
        return 'Daily Login';
      case 'SCORE':
        return 'Quiz Score (total skor kuis)';
      default:
        return taskType;
    }
  }

  DailyTaskModel copyWith({
    int? id,
    String? taskName,
    String? taskType,
    String? description,
    int? targetValue,
    int? xpReward,
    bool? isActive,
    int? currentProgress,
    bool? isCompleted,
    List<dynamic>? stages,
    List<int>? completedStages,
  }) {
    return DailyTaskModel(
      id: id ?? this.id,
      taskName: taskName ?? this.taskName,
      taskType: taskType ?? this.taskType,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      xpReward: xpReward ?? this.xpReward,
      isActive: isActive ?? this.isActive,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      stages: stages ?? this.stages,
      completedStages: completedStages ?? this.completedStages,
    );
  }
}
