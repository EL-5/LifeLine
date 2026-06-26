import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/services/supabase_service.dart';
import '../../../providers/auth_provider.dart';

class IdentityVerificationScreen extends ConsumerStatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  ConsumerState<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends ConsumerState<IdentityVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  
  String _selectedIdType = 'National ID';
  final List<String> _idTypes = ['National ID', 'Passport', "Driver's License"];
  
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // compress slightly
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitVerification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a photo of your ID document.'), backgroundColor: AppColors.emergencyRed),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final authState = ref.read(authProvider);
      final user = authState.user;
      if (user == null) throw Exception('User not found');

      final supabase = ref.read(supabaseServiceProvider).client;

      // 1. Upload the image to Supabase Storage
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}${path.extension(_selectedImage!.path)}';
      final storagePath = '${user.id}/$fileName';

      await supabase.storage.from('identity_documents').upload(
        storagePath,
        _selectedImage!,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // Get public URL (or just store the path, but public URL is easier for admins if bucket is public, 
      // but bucket is private so we store the path or a signed URL later. We'll store the path.)
      final documentUrl = storagePath;

      // 2. Update user record in database
      await supabase.from('users').update({
        'id_type': _selectedIdType,
        'id_number': _idNumberController.text.trim(),
        'identity_document_url': documentUrl,
        'verification_status': 'pending',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      setState(() {
        _isUploading = false;
      });

      // 3. Trigger AI Verification Edge Function
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifying document with AI... Please wait.'), backgroundColor: Colors.orange),
        );
      }

      setState(() => _isUploading = true); // reuse flag for loading state

      try {
        final response = await supabase.functions.invoke(
          'verify-identity',
          body: {'user_id': user.id},
        );

        final aiResult = response.data['aiResult'];
        final isVerified = aiResult['is_verified'] == true;
        
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (isVerified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Identity Verified Successfully!'), backgroundColor: AppColors.trustBlue),
            );
            Navigator.pop(context);
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification failed: ${aiResult['reason']}'), backgroundColor: AppColors.emergencyRed, duration: const Duration(seconds: 5)),
            );
            // User can try again
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI verification delayed. Status is pending.'), backgroundColor: Colors.orange),
          );
          Navigator.pop(context);
        }
      }

      // 4. Refresh user state
      await ref.read(authProvider.notifier).checkAuthStatus();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $e'), backgroundColor: AppColors.emergencyRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Identity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Identity Verification',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'To unlock full access and ensure community safety, please provide a valid government-issued ID.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400, height: 1.5),
              ),
              const SizedBox(height: 32),

              DropdownButtonFormField<String>(
                value: _selectedIdType,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                items: _idTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedIdType = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _idNumberController,
                decoration: const InputDecoration(
                  labelText: 'Document Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter your document number' : null,
              ),
              const SizedBox(height: 32),

              const Text('Upload Document Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text('Please ensure all details are clearly visible.', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedImage == null ? Colors.white24 : AppColors.trustBlue, width: 2, style: BorderStyle.solid),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.white54),
                            SizedBox(height: 12),
                            Text('Tap to select an image', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _isUploading ? 'Uploading...' : 'Submit Verification',
                  onPressed: _isUploading ? null : _submitVerification,
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
