import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

// Azure credentials injected via environment or secrets
const AZURE_KEY    = String.fromEnvironment('AZURE_SPEECH_KEY', defaultValue: 'YOUR_KEY');
const AZURE_REGION = String.fromEnvironment('AZURE_SPEECH_REGION', defaultValue: 'eastus');

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azure TTS Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TTSScreen(),
    );
  }
}

class TTSScreen extends StatefulWidget {
  @override
  _TTSScreenState createState() => _TTSScreenState();
}

class _TTSScreenState extends State<TTSScreen> {
  final _controller = TextEditingController();
  final _player = AudioPlayer();

  Future<void> _speak() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    final url = Uri.https(
      '\${AZURE_REGION}.tts.speech.microsoft.com',
      '/cognitiveservices/v1',
    );
    final ssml = '''
    <speak version="1.0" xml:lang="ar-EG">
      <voice name="ar-EG-SalmaNeural">\$text</voice>
    </speak>''';

    final resp = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': AZURE_KEY,
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'audio-16khz-128kbitrate-mono-mp3',
      },
      body: ssml,
    );

    if (resp.statusCode == 200) {
      await _player.play(BytesSource(resp.bodyBytes));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: \${resp.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Azure TTS (ar-EG)')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'نص للنطق باللهجة المصرية',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _speak,
              icon: Icon(Icons.volume_up),
              label: Text('تكلم'),
            ),
          ],
        ),
      ),
    );
  }
}
