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
  });

  factory DailyTaskModel.fromJson(Map<String, dynamic> json) {
    return DailyTaskModel(
      id: json['id'],
      taskName: json['task_name'] ?? '',
      taskType: json['task_type'] ?? '',
      description: json['description'],
      targetValue: json['target_value'] ?? 1,
      xpReward: json['xp_reward'] ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      currentProgress: json['current_progress'] ?? 0,
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
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
    );
  }
}
