import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/file_provider.dart';
import '../utils/app_theme.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fileNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedFileType = 'pdf';
  bool _isLoading = false;
  int _fileSize = 0;
  String? _filePath;

  final List<Map<String, dynamic>> _fileTypes = [
    {'type': 'pdf', 'label': 'PDF', 'icon': Icons.picture_as_pdf_rounded},
    {'type': 'docx', 'label': 'DOCX', 'icon': Icons.description_rounded},
    {'type': 'pptx', 'label': 'PPTX', 'icon': Icons.slideshow_rounded},
    {'type': 'xlsx', 'label': 'XLSX', 'icon': Icons.table_chart_rounded},
    {'type': 'txt', 'label': 'TXT', 'icon': Icons.text_snippet_rounded},
    {'type': 'jpg', 'label': 'Image', 'icon': Icons.image_rounded},
    {'type': 'zip', 'label': 'ZIP', 'icon': Icons.folder_zip_rounded},
  ];

  @override
  void dispose() {
    _fileNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null) {
        PlatformFile file = result.files.first;
        
        setState(() {
          _fileNameController.text = file.name;
          _fileSize = file.size;
          try {
            _filePath = kIsWeb ? null : file.path;
          } catch (_) {
            _filePath = null;
          }
          
          if (file.extension != null) {
            String ext = file.extension!.toLowerCase();
            // Map common extensions to our predefined types
            if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
              _selectedFileType = 'jpg';
            } else if (['doc', 'docx'].contains(ext)) {
              _selectedFileType = 'docx';
            } else if (['ppt', 'pptx'].contains(ext)) {
              _selectedFileType = 'pptx';
            } else if (['xls', 'xlsx', 'csv'].contains(ext)) {
              _selectedFileType = 'xlsx';
            } else if (['zip', 'rar', '7z'].contains(ext)) {
              _selectedFileType = 'zip';
            } else if (ext == 'txt') {
              _selectedFileType = 'txt';
            } else if (ext == 'pdf') {
              _selectedFileType = 'pdf';
            } else {
              // If not matched, default to txt or keep previous
              _selectedFileType = 'txt';
            }
          }
        });

        if (kIsWeb && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note: Browsers block file paths. Run the app as a Windows/Android app to use the "Open File" feature!'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<FileProvider>();
    final fileName = _fileNameController.text.trim();
    if (provider.fileNameExists(fileName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A file with this name already exists!')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    provider.addFile(
      fileName: fileName,
      fileType: _selectedFileType,
      description: _descriptionController.text.trim(),
      fileSize: _fileSize,
      filePath: _filePath,
    );
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File added successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New File'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.2),
                        AppTheme.accentColor.withValues(alpha: 0.1),
                      ]),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.file_upload_rounded, size: 50, color: AppTheme.primaryColor),
                        const SizedBox(height: 12),
                        Text('Browse File', style: TextStyle(
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('File Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fileNameController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(hintText: 'Enter file name...', prefixIcon: Icon(Icons.insert_drive_file_rounded, color: AppTheme.primaryColor)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : (v.trim().length < 3 ? 'Min 3 chars' : null),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('File Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  if (_fileSize > 0)
                    Text('Size: ${AppTheme.formatFileSize(_fileSize)}', style: const TextStyle(fontSize: 12, color: AppTheme.textHint)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _fileTypes.map((ft) {
                  final sel = _selectedFileType == ft['type'];
                  final c = AppTheme.getFileTypeColor(ft['type'] as String);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFileType = ft['type'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? c.withValues(alpha: 0.2) : AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? c : const Color(0xFF2A2A4A), width: sel ? 2 : 1),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(ft['icon'] as IconData, color: sel ? c : AppTheme.textHint, size: 18),
                        const SizedBox(width: 6),
                        Text(ft['label'] as String, style: TextStyle(color: sel ? c : AppTheme.textSecondary, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppTheme.textPrimary),
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Describe your file...'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.save_rounded), SizedBox(width: 8), Text('Save File to Library', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
