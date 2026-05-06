import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../providers/file_provider.dart';
import '../models/file_model.dart';
import '../utils/app_theme.dart';

class FileDetailsScreen extends StatefulWidget {
  const FileDetailsScreen({super.key});
  @override
  State<FileDetailsScreen> createState() => _FileDetailsScreenState();
}

class _FileDetailsScreenState extends State<FileDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _commentController = TextEditingController();
  final _updateDescController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _updateDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileId = ModalRoute.of(context)!.settings.arguments as String;
    return Consumer<FileProvider>(builder: (context, provider, _) {
      final file = provider.getFileById(fileId);
      if (file == null) {
        return Scaffold(appBar: AppBar(), body: const Center(child: Text('File not found')));
      }
      final versions = provider.getVersionsForFile(fileId);
      final comments = provider.getCommentsForFile(fileId);
      final color = AppTheme.getFileTypeColor(file.fileType);
      return Scaffold(
        appBar: AppBar(
          title: Text(file.fileName, overflow: TextOverflow.ellipsis),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded), onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(
              icon: Icon(file.isShared ? Icons.people_rounded : Icons.person_rounded, color: file.isShared ? AppTheme.accentColor : AppTheme.textHint),
              onPressed: () => _showShareDialog(context, provider, file),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (v) {
                if (v == 'update') _showUpdateDialog(context, provider, file);
                if (v == 'delete') _showDeleteDialog(context, provider, file);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'update', child: Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text('Update File')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: AppTheme.error), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppTheme.error))])),
              ],
            ),
          ],
        ),
        body: Column(children: [
          // File info header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3))),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                child: Icon(AppTheme.getFileTypeIcon(file.fileType), color: color, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(file.fileName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(file.description, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  _chip(file.fileType.toUpperCase(), color),
                  const SizedBox(width: 6),
                  _chip('v${file.currentVersion}', AppTheme.accentColor),
                  const SizedBox(width: 6),
                  _chip(AppTheme.formatFileSize(file.fileSize), AppTheme.textSecondary),
                  if (file.isShared) ...[const SizedBox(width: 6), _chip('Shared', AppTheme.primaryColor)],
                ]),
                if (file.filePath != null || (kIsWeb && file.fileBytes != null)) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (kIsWeb && file.fileBytes != null) {
                          final blob = html.Blob([file.fileBytes!]);
                          final url = html.Url.createObjectUrlFromBlob(blob);
                          html.window.open(url, '_blank');
                          html.Url.revokeObjectUrl(url);
                        } else if (file.filePath != null) {
                          OpenFilex.open(file.filePath!);
                        }
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Open File', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ])),
            ]),
          ),
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: AppTheme.surfaceBg, borderRadius: BorderRadius.circular(12)),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(12)),
              labelColor: Colors.white, unselectedLabelColor: AppTheme.textHint,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'Versions (${versions.length})'),
                Tab(text: 'Comments (${comments.length})'),
                const Tab(text: 'Info'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(controller: _tabController, children: [
              // Versions tab
              _buildVersionsTab(versions),
              // Comments tab
              _buildCommentsTab(comments, provider, fileId),
              // Info tab
              _buildInfoTab(file),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _chip(String text, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: c)),
    );
  }

  Widget _buildVersionsTab(List versions) {
    if (versions.isEmpty) return const Center(child: Text('No versions', style: TextStyle(color: AppTheme.textHint)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: versions.length,
      itemBuilder: (ctx, i) {
        final v = versions[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12),
            border: v.isConflict ? Border.all(color: AppTheme.warning, width: 1.5) : null,
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: v.isConflict ? AppTheme.warning.withValues(alpha: 0.15) : AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text('v${v.versionNumber}', style: TextStyle(fontWeight: FontWeight.bold, color: v.isConflict ? AppTheme.warning : AppTheme.primaryColor))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.changeDescription, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text(DateFormat('MMM d, yyyy – h:mm a').format(v.timestamp), style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
              if (v.isConflict)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(children: [
                    const Icon(Icons.warning_rounded, color: AppTheme.warning, size: 14),
                    const SizedBox(width: 4),
                    const Text('Conflict detected', style: TextStyle(fontSize: 11, color: AppTheme.warning)),
                    const Spacer(),
                    _miniBtn('Keep Latest', () => context.read<FileProvider>().resolveConflictLatest(v.id)),
                    const SizedBox(width: 6),
                    _miniBtn('Keep Both', () => context.read<FileProvider>().resolveConflictKeepBoth(v.id)),
                  ]),
                ),
              if (v.conflictResolution.isNotEmpty && !v.isConflict)
                Padding(padding: const EdgeInsets.only(top: 4), child: Text('Resolved: ${v.conflictResolution}', style: const TextStyle(fontSize: 10, color: AppTheme.success))),
            ])),
            Icon(v.isSynced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded, size: 16, color: v.isSynced ? AppTheme.success : AppTheme.textHint),
          ]),
        );
      },
    );
  }

  Widget _miniBtn(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: const TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCommentsTab(List comments, FileProvider provider, String fileId) {
    return Column(children: [
      Expanded(
        child: comments.isEmpty
            ? const Center(child: Text('No comments yet', style: TextStyle(color: AppTheme.textHint)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: comments.length,
                itemBuilder: (ctx, i) {
                  final c = comments[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(radius: 14, backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2), child: Text(c.authorName[0], style: const TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 8),
                        Text(c.authorName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        const Spacer(),
                        Text(DateFormat('MMM d, h:mm a').format(c.timestamp), style: const TextStyle(fontSize: 10, color: AppTheme.textHint)),
                        const SizedBox(width: 4),
                        GestureDetector(onTap: () => provider.deleteComment(c.id), child: const Icon(Icons.close, size: 14, color: AppTheme.textHint)),
                      ]),
                      const SizedBox(height: 8),
                      Text(c.commentText, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    ]),
                  );
                },
              ),
      ),
      // Comment input
      Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: AppTheme.cardBg, border: Border(top: BorderSide(color: Color(0xFF2A2A4A)))),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                filled: true, fillColor: AppTheme.surfaceBg,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_commentController.text.trim().isEmpty) return;
              provider.addComment(fileId: fileId, commentText: _commentController.text.trim());
              _commentController.clear();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildInfoTab(FileModel file) {
    final items = [
      ['File Name', file.fileName],
      ['Type', file.fileType.toUpperCase()],
      ['Size', AppTheme.formatFileSize(file.fileSize)],
      ['Created', DateFormat('MMM d, yyyy – h:mm a').format(file.createdAt)],
      ['Updated', DateFormat('MMM d, yyyy – h:mm a').format(file.updatedAt)],
      ['Version', 'v${file.currentVersion}'],
      ['Status', file.isShared ? 'Shared' : 'Personal'],
      ['Sync', file.isSynced ? 'Synced' : 'Pending sync'],
      ['Owner', file.ownerId],
      if (file.sharedWith.isNotEmpty) ['Shared With', file.sharedWith],
    ];
    return ListView(padding: const EdgeInsets.all(16), children: items.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Text(item[0], style: const TextStyle(fontSize: 13, color: AppTheme.textHint)),
          const Spacer(),
          Text(item[1], style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
        ]),
      );
    }).toList());
  }

  void _showShareDialog(BuildContext context, FileProvider provider, FileModel file) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.cardBg,
      title: const Text('Share File', style: TextStyle(color: AppTheme.textPrimary)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (file.isShared) ...[
          Text('Currently shared with: ${file.sharedWith}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
        ],
        TextField(controller: ctrl, style: const TextStyle(color: AppTheme.textPrimary), decoration: const InputDecoration(hintText: 'Enter username...')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        if (file.isShared) TextButton(
          onPressed: () { provider.unshareFile(file.id); Navigator.pop(ctx); },
          child: const Text('Unshare', style: TextStyle(color: AppTheme.error)),
        ),
        ElevatedButton(
          onPressed: () {
            if (ctrl.text.trim().isEmpty) return;
            provider.shareFile(file.id, ctrl.text.trim());
            Navigator.pop(ctx);
          },
          child: const Text('Share'),
        ),
      ],
    ));
  }

  void _showUpdateDialog(BuildContext context, FileProvider provider, FileModel file) {
    _updateDescController.text = '';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.cardBg,
      title: const Text('Update File', style: TextStyle(color: AppTheme.textPrimary)),
      content: TextField(controller: _updateDescController, style: const TextStyle(color: AppTheme.textPrimary), maxLines: 3, decoration: const InputDecoration(hintText: 'What changed?')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            provider.updateFile(fileId: file.id, changeDescription: _updateDescController.text.trim().isEmpty ? 'File updated' : _updateDescController.text.trim());
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New version created!')));
          },
          child: const Text('Update'),
        ),
      ],
    ));
  }

  void _showDeleteDialog(BuildContext context, FileProvider provider, FileModel file) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.cardBg,
      title: const Text('Delete File?', style: TextStyle(color: AppTheme.textPrimary)),
      content: Text('Are you sure you want to delete "${file.fileName}"?', style: const TextStyle(color: AppTheme.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
          onPressed: () { provider.deleteFile(file.id); Navigator.pop(ctx); Navigator.pop(context); },
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}
