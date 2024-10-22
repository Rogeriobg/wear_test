import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const WearOsDomaApp());
}

class WearOsDomaApp extends StatelessWidget {
  const WearOsDomaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doma Assistência',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  static const platform =
      MethodChannel('audio_channel'); // Canal para comunicação nativa
  late stt.SpeechToText _speech;
  String _lastWords = '';
  bool _speechAvailable = true;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeechRecognition();
    checkAudioDevices();
  }

  // Inicializa o reconhecimento de voz
  Future<void> _initializeSpeechRecognition() async {
    _speechAvailable = await _speech.initialize();
    setState(() {});
  }

  // Função para falar um texto em voz alta
  Future _speak(String text) async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  // Verifica os dispositivos de áudio disponíveis
  void checkAudioDevices() {
    platform.invokeMethod('checkAudioDevices').then((result) {
      print("Dispositivos de áudio disponíveis: $result");
    }).catchError((error) {
      print("Erro ao verificar dispositivos de áudio: $error");
    });
  }

  Future<void> _checkMicrophone() async {
    var hasMicrophonePermission = await _speech.hasPermission;
    if (!hasMicrophonePermission) {
      await _speech.requestPermission();
    }
  }

  // Simulação de leitura de mensagem
  void _lerMensagem1() {
    _speak(
        'Alerta de segurança: Risco de desabamento da encosta detectado em sua área. Evacue imediatamente para um local seguro e siga as instruções das autoridades locais."');
  }

  void _lerMensagem2() {
    _speak(
        'Alerta de segurança: Enchente iminente detectada em sua área. Evite áreas baixas e mova-se para terrenos mais elevados. Siga as orientações das autoridades locais"');
  }

  // Simulação de lembrete
  void _lembrete1() {
    _speak('Lembrete: Reunião de equipe às 14h.');
  }

  void _lembrete2() {
    _speak(
        'Mensagem da equipe: Parabéns a todos pelo excelente trabalho! Continuamos firmes, unidos, e com um grande espírito de equipe. Juntos, alcançaremos nossos objetivos e superaremos todos os desafios.');
  }

  // Simulação de notificação de segurança
  void _alertaSeguranca() {
    _speak('Alerta de segurança: Queimadas detectadas na sua região.');
  }

  // Função para iniciar o reconhecimento de voz
  void _startListening() {
    if (_speechAvailable) {
      setState(() {});
      _speech.listen(onResult: (val) {
        setState(() {
          _lastWords = val.recognizedWords;
          if (_lastWords.toLowerCase().contains('Ouvir Mensagem 1')) {
            _lerMensagem1();
          } else if (_lastWords.toLowerCase().contains('Ouvir Mensagem 2')) {
            _lerMensagem2();
          } else if (_lastWords.toLowerCase().contains('Ouvir Lembrete 1')) {
            _lembrete1();
          } else if (_lastWords.toLowerCase().contains('Ouvir Lembrete 2')) {
            _lembrete2();
          } else if (_lastWords.toLowerCase().contains('alerta de segurança')) {
            _alertaSeguranca();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistência Doma'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
                'Pressione um botão ou use comando de voz para ouvir uma notificação'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _lerMensagem1,
              child: const Text('Ouvir Mensagem 1'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _lerMensagem2,
              child: const Text('Ouvir Mensagem 2'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _lembrete1,
              child: const Text('Ouvir Lembrete 1'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _lembrete2,
              child: const Text('Ouvir Lembrete 2'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _alertaSeguranca,
              child: const Text('Ouvir Alerta de Segurança'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startListening,
              child: const Text('Iniciar Comando de Voz'),
            ),
          ],
        ),
      ),
    );
  }
}

extension on stt.SpeechToText {
  requestPermission() {}
}
