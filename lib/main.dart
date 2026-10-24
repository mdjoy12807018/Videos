import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      title: 'My Videos App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoHomeScreen(),
    );
  }
}

class VideoHomeScreen extends StatelessWidget {
  const VideoHomeScreen({super.key});

  // ফোন থেকে ভিডিও ফাইল সিলেক্ট করার ফাংশন
  Future<void> _pickAndUploadVideo(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      String fileName = result.files.single.name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected video: $fileName')),
      );
      // পরবর্তীতে এখানে ফায়ারবেসে ফাইল ট্রান্সফার লজিক যুক্ত হবে
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video selection canceled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Videos - Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Video Admin Panel',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _pickAndUploadVideo(context),
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload New Video'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Uploaded Videos List:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 0,
                itemBuilder: (context, index) {
                  return const ListTile(
                    leading: Icon(Icons.video_library),
                    title: Text('Sample Video Title'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
