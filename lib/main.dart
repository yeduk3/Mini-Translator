import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:window_manager/window_manager.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.setAlwaysOnTop(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Mini Translator App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const MyHomePage(),
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();

  final _apiKey = 'YOUR_API_KEY';
  String _translatedText = '';

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _translateText(myController.text, 'ko');
  }

  Future<void> _translateText(String text, String targetLanguage) async {
    final url = 'https://translation.googleapis.com/language/translate/v2?key=$_apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'q': text,
        'target': targetLanguage,
      }),
    );

    if(response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _translatedText = responseData['data']['translations'][0]['translatedText'];
      });
    } else {
      setState(() {
        _translatedText = '번역 중 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: myController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Input Here',
                labelText: 'English',
              ),
              onSubmitted: (value) {
                _translateText(myController.text, 'ko');
              }
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                const Icon(Icons.arrow_forward),
                Text(
                  _translatedText,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
