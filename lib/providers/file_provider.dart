import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/file_model.dart';
import '../models/version_model.dart';
import '../models/comment_model.dart';

class FileProvider extends ChangeNotifier {
  final Box<FileModel> _fileBox = Hive.box<FileModel>('files');
  final Box<VersionModel> _versionBox = Hive.box<VersionModel>('versions');
  final Box<CommentModel> _commentBox = Hive.box<CommentModel>('comments');
  final _uuid = const Uuid();

  // Search and filter state
  String _searchQuery = '';
  String _filterType = 'All';
  String _filterShared = 'All'; // 'All', 'Shared', 'Personal'

  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  String get filterShared => _filterShared;

  // Connectivity state
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  void setOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }

  // ==================== FILE OPERATIONS ====================

  List<FileModel> get allFiles {
    return _fileBox.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<FileModel> get filteredFiles {
    List<FileModel> files = allFiles;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      files = files
          .where((f) =>
              f.fileName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              f.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply file type filter
    if (_filterType != 'All') {
      files = files.where((f) => f.fileType == _filterType).toList();
    }

    // Apply shared/personal filter
    if (_filterShared == 'Shared') {
      files = files.where((f) => f.isShared).toList();
    } else if (_filterShared == 'Personal') {
      files = files.where((f) => !f.isShared).toList();
    }

    return files;
  }

  List<FileModel> get sharedFiles {
    return allFiles.where((f) => f.isShared).toList();
  }

  List<FileModel> get personalFiles {
    return allFiles.where((f) => !f.isShared).toList();
  }

  List<String> get fileTypes {
    final types = _fileBox.values.map((f) => f.fileType).toSet().toList();
    types.sort();
    return types;
  }

  int get unsyncedCount {
    return _fileBox.values.where((f) => !f.isSynced).length;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterShared(String filter) {
    _filterShared = filter;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = 'All';
    _filterShared = 'All';
    notifyListeners();
  }

  FileModel? getFileById(String id) {
    try {
      return _fileBox.values.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if file name already exists
  bool fileNameExists(String name, {String? excludeId}) {
    return _fileBox.values.any((f) =>
        f.fileName.toLowerCase() == name.toLowerCase() && f.id != excludeId);
  }

  /// Add a new file
  String addFile({
    required String fileName,
    required String fileType,
    required String description,
    int fileSize = 0,
  }) {
    final id = _uuid.v4();
    final now = DateTime.now();

    final file = FileModel(
      id: id,
      fileName: fileName,
      fileType: fileType,
      description: description,
      createdAt: now,
      updatedAt: now,
      fileSize: fileSize > 0 ? fileSize : _generateMockFileSize(fileType),
    );

    _fileBox.put(id, file);

    // Create initial version
    _addVersion(
      fileId: id,
      versionNumber: 1,
      changeDescription: 'Initial upload',
    );

    notifyListeners();
    return id;
  }

  /// Update a file (creates new version)
  void updateFile({
    required String fileId,
    String? fileName,
    String? description,
    String? changeDescription,
  }) {
    final file = getFileById(fileId);
    if (file == null) return;

    final now = DateTime.now();
    final newVersion = file.currentVersion + 1;

    // Check for conflicts (simulated: if file was updated within last minute)
    bool hasConflict = now.difference(file.updatedAt).inMinutes < 1;

    file.fileName = fileName ?? file.fileName;
    file.description = description ?? file.description;
    file.updatedAt = now;
    file.currentVersion = newVersion;
    file.isSynced = false;

    file.save();

    _addVersion(
      fileId: fileId,
      versionNumber: newVersion,
      changeDescription: changeDescription ?? 'File updated',
      isConflict: hasConflict,
      conflictResolution: hasConflict ? 'keep_both' : '',
    );

    notifyListeners();
  }

  /// Delete a file and its versions/comments
  void deleteFile(String fileId) {
    _fileBox.delete(fileId);

    // Delete associated versions
    final versions =
        _versionBox.values.where((v) => v.fileId == fileId).toList();
    for (var v in versions) {
      v.delete();
    }

    // Delete associated comments
    final comments =
        _commentBox.values.where((c) => c.fileId == fileId).toList();
    for (var c in comments) {
      c.delete();
    }

    notifyListeners();
  }

  /// Share a file
  void shareFile(String fileId, String shareWith) {
    final file = getFileById(fileId);
    if (file == null) return;

    file.isShared = true;
    final existingShared =
        file.sharedWith.isEmpty ? <String>[] : file.sharedWith.split(',');
    if (!existingShared.contains(shareWith)) {
      existingShared.add(shareWith);
    }
    file.sharedWith = existingShared.join(',');
    file.updatedAt = DateTime.now();
    file.isSynced = false;
    file.save();

    notifyListeners();
  }

  /// Unshare a file
  void unshareFile(String fileId) {
    final file = getFileById(fileId);
    if (file == null) return;

    file.isShared = false;
    file.sharedWith = '';
    file.updatedAt = DateTime.now();
    file.isSynced = false;
    file.save();

    notifyListeners();
  }

  // ==================== VERSION OPERATIONS ====================

  List<VersionModel> getVersionsForFile(String fileId) {
    return _versionBox.values
        .where((v) => v.fileId == fileId)
        .toList()
      ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
  }

  void _addVersion({
    required String fileId,
    required int versionNumber,
    required String changeDescription,
    bool isConflict = false,
    String conflictResolution = '',
  }) {
    final id = _uuid.v4();
    final version = VersionModel(
      id: id,
      fileId: fileId,
      versionNumber: versionNumber,
      timestamp: DateTime.now(),
      changeDescription: changeDescription,
      isConflict: isConflict,
      conflictResolution: conflictResolution,
    );

    _versionBox.put(id, version);
  }

  /// Resolve conflict by keeping latest version
  void resolveConflictLatest(String versionId) {
    final version =
        _versionBox.values.firstWhere((v) => v.id == versionId);
    version.isConflict = false;
    version.conflictResolution = 'latest';
    version.save();
    notifyListeners();
  }

  /// Resolve conflict by keeping both versions
  void resolveConflictKeepBoth(String versionId) {
    final version =
        _versionBox.values.firstWhere((v) => v.id == versionId);
    version.isConflict = false;
    version.conflictResolution = 'keep_both';
    version.save();
    notifyListeners();
  }

  // ==================== COMMENT OPERATIONS ====================

  List<CommentModel> getCommentsForFile(String fileId) {
    return _commentBox.values
        .where((c) => c.fileId == fileId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void addComment({
    required String fileId,
    required String commentText,
    String authorName = 'You',
  }) {
    final id = _uuid.v4();
    final comment = CommentModel(
      id: id,
      fileId: fileId,
      commentText: commentText,
      timestamp: DateTime.now(),
      authorName: authorName,
    );

    _commentBox.put(id, comment);
    notifyListeners();
  }

  void deleteComment(String commentId) {
    _commentBox.delete(commentId);
    notifyListeners();
  }

  // ==================== SYNC OPERATIONS ====================

  /// Simulate sync - marks all unsynced items as synced
  Future<void> syncData() async {
    if (!_isOnline) return;

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mark all files as synced
    for (var file in _fileBox.values.where((f) => !f.isSynced)) {
      file.isSynced = true;
      file.save();
    }

    // Mark all versions as synced
    for (var version in _versionBox.values.where((v) => !v.isSynced)) {
      version.isSynced = true;
      version.save();
    }

    // Mark all comments as synced
    for (var comment in _commentBox.values.where((c) => !c.isSynced)) {
      comment.isSynced = true;
      comment.save();
    }

    notifyListeners();
  }

  int _generateMockFileSize(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return 1024 * 1024 * 2; // 2MB
      case 'doc':
      case 'docx':
        return 1024 * 512; // 512KB
      case 'ppt':
      case 'pptx':
        return 1024 * 1024 * 5; // 5MB
      case 'xls':
      case 'xlsx':
        return 1024 * 256; // 256KB
      case 'txt':
        return 1024 * 10; // 10KB
      case 'jpg':
      case 'png':
        return 1024 * 1024 * 3; // 3MB
      case 'zip':
        return 1024 * 1024 * 10; // 10MB
      default:
        return 1024 * 100; // 100KB
    }
  }

  /// Seed sample data for demonstration
  void seedSampleData() {
    if (_fileBox.isNotEmpty) return;

    // Sample files
    final sampleFiles = [
      {
        'name': 'Project_Report_Final.pdf',
        'type': 'pdf',
        'desc': 'Final project report for MAD semester 6',
        'shared': true,
        'sharedWith': 'Alice,Bob',
      },
      {
        'name': 'Lecture_Notes_Ch5.docx',
        'type': 'docx',
        'desc': 'Chapter 5 lecture notes on Flutter widgets',
        'shared': false,
        'sharedWith': '',
      },
      {
        'name': 'Assignment_3.pdf',
        'type': 'pdf',
        'desc': 'Assignment 3 - Mobile App Development',
        'shared': true,
        'sharedWith': 'Charlie',
      },
      {
        'name': 'Database_Design.pptx',
        'type': 'pptx',
        'desc': 'Database design presentation slides',
        'shared': false,
        'sharedWith': '',
      },
      {
        'name': 'Budget_Tracker.xlsx',
        'type': 'xlsx',
        'desc': 'Monthly budget tracking spreadsheet',
        'shared': true,
        'sharedWith': 'Alice,Diana',
      },
    ];

    for (var data in sampleFiles) {
      final id = _uuid.v4();
      final now = DateTime.now().subtract(Duration(
        hours: sampleFiles.indexOf(data) * 24,
      ));

      final file = FileModel(
        id: id,
        fileName: data['name'] as String,
        fileType: data['type'] as String,
        description: data['desc'] as String,
        createdAt: now,
        updatedAt: now,
        isShared: data['shared'] as bool,
        sharedWith: data['sharedWith'] as String,
        fileSize: _generateMockFileSize(data['type'] as String),
      );

      _fileBox.put(id, file);

      // Add initial version
      _addVersion(
        fileId: id,
        versionNumber: 1,
        changeDescription: 'Initial upload',
      );

      // Add sample comments for shared files
      if (data['shared'] as bool) {
        addComment(
          fileId: id,
          commentText: 'Great work on this file! 👍',
          authorName: 'Alice',
        );
        addComment(
          fileId: id,
          commentText: 'Please review section 3.',
          authorName: 'Bob',
        );
      }
    }

    notifyListeners();
  }
}
