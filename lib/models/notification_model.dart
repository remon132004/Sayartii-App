class NotificationModel {
  final int? id;
  final String? title;
  final String? description;
  final String? userId;

  NotificationModel({
    this.id,
    this.title,
    this.description,
    this.userId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'] ?? json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'user_id': userId,
    };
  }
}
