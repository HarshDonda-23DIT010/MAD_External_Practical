import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/file_provider.dart';
import '../utils/app_theme.dart';
import 'file_list_screen.dart';
import 'shared_files_screen.dart';
import 'search_filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isSyncing = false;

  final List<Widget> _screens = const [
    FileListScreen(),
    SharedFilesScreen(),
    SearchFilterScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Seed sample data on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileProvider>().seedSampleData();
    });
  }

  Future<void> _handleSync() async {
    final provider = context.read<FileProvider>();
    if (!provider.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: AppTheme.warning, size: 20),
              const SizedBox(width: 12),
              const Text('You are offline. Data will sync when online.'),
            ],
          ),
          backgroundColor: AppTheme.surfaceLight,
        ),
      );
      return;
    }

    setState(() => _isSyncing = true);
    await provider.syncData();
    setState(() => _isSyncing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.cloud_done_rounded,
                  color: AppTheme.success, size: 20),
              const SizedBox(width: 12),
              const Text('All data synced successfully!'),
            ],
          ),
          backgroundColor: AppTheme.surfaceLight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: _screens[_currentIndex],
          floatingActionButton: _currentIndex == 0
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-file');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add File'),
                  backgroundColor: AppTheme.primaryColor,
                )
              : null,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    _buildNavItem(0, Icons.folder_rounded, 'Files',
                        provider.allFiles.length),
                    _buildNavItem(1, Icons.share_rounded, 'Shared',
                        provider.sharedFiles.length),
                    _buildNavItem(
                        2, Icons.search_rounded, 'Search', null),
                    // Sync button
                    Expanded(
                      child: GestureDetector(
                        onTap: _handleSync,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  _isSyncing
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.accentColor,
                                          ),
                                        )
                                      : Icon(
                                          Icons.sync_rounded,
                                          color: provider.isOnline
                                              ? AppTheme.success
                                              : AppTheme.textHint,
                                          size: 24,
                                        ),
                                  if (provider.unsyncedCount > 0)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${provider.unsyncedCount}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sync',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: provider.isOnline
                                      ? AppTheme.success
                                      : AppTheme.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Online/Offline toggle
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          provider.setOnlineStatus(!provider.isOnline);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                provider.isOnline
                                    ? Icons.wifi_rounded
                                    : Icons.wifi_off_rounded,
                                color: provider.isOnline
                                    ? AppTheme.success
                                    : AppTheme.warning,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: provider.isOnline
                                      ? AppTheme.success
                                      : AppTheme.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int? count) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textHint,
                    size: 24,
                  ),
                  if (count != null && count > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
