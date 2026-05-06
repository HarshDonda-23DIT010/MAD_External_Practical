import 'package:hive/hive.dart';

part 'comment_model.g.dart';

@HiveType(typeId: 2)
class CommentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fileId;

  @HiveField(2)
  String commentText;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String authorName;

  @HiveField(5)
  bool isSynced;

  CommentModel({
    required this.id,
    required this.fileId,
    required this.commentText,
    required this.timestamp,
    this.authorName = 'You',
    this.isSynced = false,
  });
}
