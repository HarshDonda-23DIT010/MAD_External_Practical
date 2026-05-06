import 'package:hive/hive.dart';

part 'file_model.g.dart';

@HiveType(typeId: 0)
class FileModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fileName;

  @HiveField(2)
  String fileType;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  bool isShared;

  @HiveField(7)
  String sharedWith; // comma-separated user names

  @HiveField(8)
  int currentVersion;

  @HiveField(9)
  bool isSynced;

  @HiveField(10)
  String ownerId;

  @HiveField(11)
  int fileSize; // in bytes (mock)

  @HiveField(12)
  String? filePath; // actual path to view the file

  FileModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.isShared = false,
    this.sharedWith = '',
    this.currentVersion = 1,
    this.isSynced = false,
    this.ownerId = 'current_user',
    this.fileSize = 0,
    this.filePath,
  });

  FileModel copyWith({
    String? id,
    String? fileName,
    String? fileType,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isShared,
    String? sharedWith,
    int? currentVersion,
    bool? isSynced,
    String? ownerId,
    int? fileSize,
    String? filePath,
  }) {
    return FileModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isShared: isShared ?? this.isShared,
      sharedWith: sharedWith ?? this.sharedWith,
      currentVersion: currentVersion ?? this.currentVersion,
      isSynced: isSynced ?? this.isSynced,
      ownerId: ownerId ?? this.ownerId,
      fileSize: fileSize ?? this.fileSize,
      filePath: filePath ?? this.filePath,
    );
  }
}
