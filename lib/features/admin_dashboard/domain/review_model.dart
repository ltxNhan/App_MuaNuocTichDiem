class ReviewModel {
  final String id;
  final String orderCode;
  final String userName;
  final String userAvatar;
  final int qualityStars; // 1-5
  final String qualityLabel; // 'Tuyệt hảo', 'Ngon miệng', 'Tạm ổn', 'Chưa ngon', 'Rất tệ'
  final String qualityEmoji; // 🤩, 😊, 😐, 😕, 😡
  final List<String> quickTags;
  final String comment;
  final bool hasPhoto;
  final DateTime createdAt;
  final String? adminResponse;

  const ReviewModel({
    required this.id,
    required this.orderCode,
    required this.userName,
    required this.userAvatar,
    required this.qualityStars,
    required this.qualityLabel,
    required this.qualityEmoji,
    required this.quickTags,
    required this.comment,
    this.hasPhoto = false,
    required this.createdAt,
    this.adminResponse,
  });

  ReviewModel copyWith({
    String? adminResponse,
  }) {
    return ReviewModel(
      id: id,
      orderCode: orderCode,
      userName: userName,
      userAvatar: userAvatar,
      qualityStars: qualityStars,
      qualityLabel: qualityLabel,
      qualityEmoji: qualityEmoji,
      quickTags: quickTags,
      comment: comment,
      hasPhoto: hasPhoto,
      createdAt: createdAt,
      adminResponse: adminResponse ?? this.adminResponse,
    );
  }
}
