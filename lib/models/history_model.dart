class HistoryModel {
  final int? id;
  final String? image;
  final String? issueId;
  final String? issueName;

  HistoryModel({
    this.id,
    this.image,
    this.issueId,
    this.issueName,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      image: json['image'],
      issueId: json['issue']?['id']?.toString() ?? json['issueId'],
      issueName: json['issue']?['name']?.toString() ?? json['issueName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'issueId': issueId,
      'issueName': issueName,
    };
  }
}
