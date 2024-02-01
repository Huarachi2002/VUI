import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  //Voz a Texto
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  double _cofidence = 1.0;
  //Texto a Voz
  FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;
  List<Map> _voices = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initSpeech();
    initTTS();
  }

  void initTTS(){
    _flutterTts.setLanguage("es-MX");
    _flutterTts.getVoices.then((data) {
      try {
        _voices = List<Map>.from(data);
        
        setState(() {
          _voices = _voices.where((_voice) => _voice["name"].contains("es-MX")).toList();
          _currentVoice = _voices.first;
          setVoice(_currentVoice!);
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice){
    print(voice);
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _cofidence = result.confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Coincidencia: ${(_cofidence * 100.0).toStringAsFixed(1)}%'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text( _lastWords.isEmpty ? 'Tiene que presionar el boton para hablar' : _lastWords, style: const TextStyle(fontSize: 20.0),)
              ),
            ),
            //DropdownButton(value: _currentVoice,items: _voices.map((_voice) => DropdownMenuItem(value: _voice,child: Text(_voice["name"]))).toList(), onChanged: (value) {}),
            //RichText(textAlign: TextAlign.center, text: TextSpan(style: TextStyle(fontWeight: FontWeight.w200, fontSize: 20, color: Colors.black), children: <TextSpan>[TextSpan(text: _lastWords)])),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarGlow(
            animate: _speechEnabled,
            glowRadiusFactor: 75.0,
            glowColor: Theme.of(context).primaryColor,
            duration: const Duration(milliseconds: 2000),
            repeat: false,
            child: FloatingActionButton(
              onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
              tooltip: 'Escuchar',
              child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            ),
          ),
          
          AvatarGlow(
            animate: _speechEnabled,
            glowRadiusFactor: 75.0,
            glowColor: Theme.of(context).primaryColor,
            duration: const Duration(milliseconds: 2000),
            repeat: false,
            child: FloatingActionButton(
              onPressed:() {
                _flutterTts.speak(_lastWords);
              },
              tooltip: 'Reproducir',
              child: const Icon(Icons.volume_down_alt),
            ),
          ),

        ]
      ),
    );
  }
}