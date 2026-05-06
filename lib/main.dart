import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import 'models/file_model.dart';
import 'models/version_model.dart';
import 'models/comment_model.dart';
import 'providers/file_provider.dart';
import 'screens/home_screen.dart';
import 'screens/file_upload_screen.dart';
import 'screens/file_details_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive (NoSQL Local Database)
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(FileModelAdapter());
  Hive.registerAdapter(VersionModelAdapter());
  Hive.registerAdapter(CommentModelAdapter());

  // Open Boxes
  await Hive.openBox<FileModel>('files');
  await Hive.openBox<VersionModel>('versions');
  await Hive.openBox<CommentModel>('comments');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart File Sharing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add-file': (context) => const FileUploadScreen(),
        '/file-details': (context) => const FileDetailsScreen(),
      },
    );
  }
}
