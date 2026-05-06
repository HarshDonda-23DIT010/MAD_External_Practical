import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:typed_data';

class MongoService {
  static Db? _db;
  static DbCollection? _filesCollection;
  static DbCollection? _versionsCollection;
  static DbCollection? _commentsCollection;
  
  static bool get isConnected => _db?.state == State.OPEN;

  static Future<void> connect() async {
    if (kIsWeb) {
      debugPrint('MongoDB direct connection is not supported on Flutter Web.');
      return;
    }
    
    if (isConnected) return;

    try {
      // Connect to local MongoDB instance
      _db = await Db.create('mongodb://127.0.0.1:27017/smart_file_hub');
      await _db!.open();
      
      _filesCollection = _db!.collection('files');
      _versionsCollection = _db!.collection('versions');
      _commentsCollection = _db!.collection('comments');
      
      debugPrint('Successfully connected to MongoDB local database.');
    } catch (e) {
      debugPrint('MongoDB connection error: $e');
    }
  }

  static Future<void> disconnect() async {
    if (_db != null && isConnected) {
      await _db!.close();
    }
  }

  // --- FILE SYNC ---
  
  static Future<void> upsertFile(Map<String, dynamic> fileData) async {
    if (!isConnected || _filesCollection == null) return;
    
    try {
      // BSON map processing (removing fileBytes for database size, or converting to Binary)
      final dataToSave = Map<String, dynamic>.from(fileData);
      
      if (dataToSave['fileBytes'] != null) {
        // You can save it as BsonBinary if you want to store actual bytes in MongoDB
        dataToSave['fileBytes'] = BsonBinary.from(dataToSave['fileBytes'] as Uint8List);
      }
      
      await _filesCollection!.update(
        where.eq('id', dataToSave['id']),
        dataToSave,
        upsert: true,
      );
      debugPrint('MongoDB: File ${dataToSave['id']} upserted.');
    } catch (e) {
      debugPrint('MongoDB upsertFile error: $e');
    }
  }
  
  static Future<void> deleteFile(String id) async {
    if (!isConnected || _filesCollection == null) return;
    try {
      await _filesCollection!.remove(where.eq('id', id));
      debugPrint('MongoDB: File $id deleted.');
    } catch (e) {
      debugPrint('MongoDB deleteFile error: $e');
    }
  }

  // --- VERSION SYNC ---

  static Future<void> upsertVersion(Map<String, dynamic> versionData) async {
    if (!isConnected || _versionsCollection == null) return;
    try {
      await _versionsCollection!.update(
        where.eq('id', versionData['id']),
        versionData,
        upsert: true,
      );
    } catch (e) {
      debugPrint('MongoDB upsertVersion error: $e');
    }
  }

  static Future<void> deleteVersionsForFile(String fileId) async {
    if (!isConnected || _versionsCollection == null) return;
    try {
      await _versionsCollection!.remove(where.eq('fileId', fileId));
    } catch (e) {
      debugPrint('MongoDB deleteVersionsForFile error: $e');
    }
  }

  // --- COMMENT SYNC ---

  static Future<void> upsertComment(Map<String, dynamic> commentData) async {
    if (!isConnected || _commentsCollection == null) return;
    try {
      await _commentsCollection!.update(
        where.eq('id', commentData['id']),
        commentData,
        upsert: true,
      );
    } catch (e) {
      debugPrint('MongoDB upsertComment error: $e');
    }
  }
  
  static Future<void> deleteComment(String id) async {
    if (!isConnected || _commentsCollection == null) return;
    try {
      await _commentsCollection!.remove(where.eq('id', id));
    } catch (e) {
      debugPrint('MongoDB deleteComment error: $e');
    }
  }
  
  static Future<void> deleteCommentsForFile(String fileId) async {
    if (!isConnected || _commentsCollection == null) return;
    try {
      await _commentsCollection!.remove(where.eq('fileId', fileId));
    } catch (e) {
      debugPrint('MongoDB deleteCommentsForFile error: $e');
    }
  }
}
