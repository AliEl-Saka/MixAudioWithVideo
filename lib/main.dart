import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VideoMixingPage(),
    );
  }
}

class VideoMixingPage extends StatefulWidget {
  const VideoMixingPage({super.key});

  @override
  _VideoMixingPageState createState() => _VideoMixingPageState();
}

class _VideoMixingPageState extends State<VideoMixingPage> {
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _audioUrlController = TextEditingController();
  String _outputVideoUrl = '';

  @override
  void dispose() {
    _videoUrlController.dispose();
    _audioUrlController.dispose();
    super.dispose();
  }

  void mixAudioAndVideo() async {
    String videoUrl = _videoUrlController.text.trim();
    String audioUrl = _audioUrlController.text.trim();

    if (videoUrl.isEmpty || audioUrl.isEmpty) {
      _showSnackBar('Please enter both video and audio URLs.');
      return;
    }

    // Set the default FFmpegKit configuration (optional)
    // await FFmpegKitConfig.setFFmpegKitConfig();

    // Create a unique output file name
    String outputFileName =
        "output_${DateTime.now().millisecondsSinceEpoch}.mp4";
    String outputFilePath = await x(outputFileName);

    // Build ffmpeg command
    String ffmpegCommand =
        "-i $videoUrl -i $audioUrl -c:v copy -c:a aac -strict experimental $outputFilePath";

    // Execute ffmpeg command
    FFmpegSession response = await FFmpegKit.executeAsync(ffmpegCommand);

    setState(() {
      _outputVideoUrl = outputFilePath;
    });

    // Check if command execution was successful
    if (ReturnCode.isSuccess(await response.getReturnCode())) {
      _showSnackBar('Video mixed successfully.');
      setState(() {
        _outputVideoUrl = outputFilePath;
      });
    } else {
      _showSnackBar('Error mixing video: ${response.getAllLogs()}');
      print('Error mixing video: ${response.getAllLogs()}');
    }
  }

  Future<String> x(String fileName) async {
    bool dirDownloadExists = true;
    String directory;
    directory = "/storage/emulated/0/Download/";

    dirDownloadExists = await Directory(directory).exists();
    if (dirDownloadExists) {
     return directory = "/storage/emulated/0/Download/$fileName";
    } else {
     return directory = "/storage/emulated/0/Downloads/$fileName";
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Mixing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _videoUrlController,
              decoration: const InputDecoration(labelText: 'Video URL'),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _audioUrlController,
              decoration: const InputDecoration(labelText: 'Audio URL'),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: mixAudioAndVideo,
              child: const Text('Mix Audio and Video'),
            ),
            const SizedBox(height: 20.0),
            if (_outputVideoUrl.isNotEmpty)
              Text(
                'Mixed Video URL: $_outputVideoUrl',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
