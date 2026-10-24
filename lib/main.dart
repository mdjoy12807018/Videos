import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Videos Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoHomeScreen(),
    );
  }
}

class VideoHomeScreen extends StatefulWidget {
  const VideoHomeScreen({super.key});

  @override
  State<VideoHomeScreen> createState() => _VideoHomeScreenState();
}

class _VideoHomeScreenState extends State<VideoHomeScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref().child('videos/$fileName.mp4');
        
        UploadTask uploadTask = ref.putData(result.files.single.bytes!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('videos').add({
          'url': downloadUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video uploaded successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Admin Panel'),
      ),
      body: Center(
        child: _isUploading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _pickAndUploadVideo,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Video'),
              ),
      ),
    );
  }
}
