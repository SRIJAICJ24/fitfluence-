import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../data/repositories/stories_repository.dart';
import '../../../../shared/presentation/widgets/glassmorphic/glass_container.dart';

class CreateStoryScreen extends ConsumerStatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  ConsumerState<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends ConsumerState<CreateStoryScreen> {
  File? _selectedFile;
  String _selectedStreak = 'gym';
  bool _isUploading = false;
  final _captionController = TextEditingController(); // Not used in schema yet, but good for future

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadStory() async {
    if (_selectedFile == null) return;
    
    setState(() => _isUploading = true);
    
    try {
      final repo = ref.read(storiesRepositoryProvider);
      await repo.createStory(
        filePath: _selectedFile!.path,
        streakType: _selectedStreak,
        gymId: null, // Logic to detect gym location would go here
      );
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Story Posted! 🔥'), backgroundColor: AppColors.volt),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Story'),
        backgroundColor: AppColors.midnightBlue,
      ),
      body: Stack(
         children: [
            // Preview
            if (_selectedFile != null)
              Positioned.fill(
                child: Image.file(_selectedFile!, fit: BoxFit.cover),
              )
            else
              const Center(child: Text("Pick an image to start")),
            
            // UI Overlay
            SafeArea(
              child: Column(
                children: [
                   if (_selectedFile == null)
                     Expanded(
                       child: Center(
                         child: IconButton(
                           icon: const Icon(Icons.add_a_photo, size: 64, color: AppColors.volt),
                           onPressed: _pickImage,
                         ),
                       ),
                     ),
                   
                   const Spacer(),
                   
                   if (_selectedFile != null) ...[
                     // Metadata Controls
                     GlassContainer(
                       borderRadius: 0,
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           // Streak Selector
                           SingleChildScrollView(
                             scrollDirection: Axis.horizontal,
                             padding: const EdgeInsets.all(16),
                             child: Row(
                               children: ['gym', 'nutrition', 'mindfulness', 'other'].map((type) {
                                 final isSelected = _selectedStreak == type;
                                 return Padding(
                                   padding: const EdgeInsets.only(right: 8),
                                   child: ChoiceChip(
                                     label: Text(type.toUpperCase()),
                                     selected: isSelected,
                                     onSelected: (val) => setState(() => _selectedStreak = type),
                                     selectedColor: AppColors.volt,
                                     backgroundColor: Colors.black26,
                                     labelStyle: TextStyle(
                                       color: isSelected ? AppColors.deepSlate : Colors.white,
                                       fontWeight: FontWeight.bold
                                     ),
                                   ),
                                 );
                               }).toList(),
                             ),
                           ),
                           
                           Padding(
                             padding: const EdgeInsets.all(16.0),
                             child: SizedBox(
                               width: double.infinity,
                               child: ElevatedButton(
                                 onPressed: _isUploading ? null : _uploadStory,
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: AppColors.volt,
                                   padding: const EdgeInsets.symmetric(vertical: 16),
                                 ),
                                 child: _isUploading 
                                    ? const CircularProgressIndicator(color: AppColors.midnightBlue)
                                    : const Text("SHARE TO STORY", style: TextStyle(color: AppColors.midnightBlue, fontWeight: FontWeight.bold)),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ],
                ],
              ),
            ),
         ],
      ),
    );
  }
}
