import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  final String id;
  final String elderId;
  final String imageUrl;
  final String? caption;
  final DateTime uploadedAt;

  Photo({
    required this.id,
    required this.elderId,
    required this.imageUrl,
    this.caption,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'elderId': elderId,
      'imageUrl': imageUrl,
      'caption': caption,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      elderId: json['elderId'] as String,
      imageUrl: json['imageUrl'] as String,
      caption: json['caption'] as String?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }

  factory Photo.fromFirestore(DocumentSnapshot doc) {
    return Photo.fromJson(doc.data() as Map<String, dynamic>);
  }
}
