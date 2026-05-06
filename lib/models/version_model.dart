import 'package:hive/hive.dart';

part 'version_model.g.dart';

@HiveType(typeId: 1)
class VersionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fileId;

  @HiveField(2)
  int versionNumber;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  String changeDescription;

  @HiveField(5)
  String modifiedBy;

  @HiveField(6)
  bool isSynced;

  @HiveField(7)
  bool isConflict;

  @HiveField(8)
  String conflictResolution; // 'latest', 'keep_both', 'manual'

  VersionModel({
    required this.id,
    required this.fileId,
    required this.versionNumber,
    required this.timestamp,
    required this.changeDescription,
    this.modifiedBy = 'current_user',
    this.isSynced = false,
    this.isConflict = false,
    this.conflictResolution = '',
  });
}
