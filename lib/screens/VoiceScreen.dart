import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  double _cofidence = 1.0;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initSpeech();
  }
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _listen() async {
    if(!_speechEnabled){
      bool available = await _speechToText.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val')
      );
      if (available) {
        setState(() => _speechEnabled = true);
        _speechToText.listen(
          onResult: (val) => setState(() {
            _lastWords = val.recognizedWords;
            if(val.hasConfidenceRating && val.confidence > 0){
              _cofidence = val.confidence;
            }
          }),
        );
      }
    }else{
      setState(() => _speechEnabled = false);
      _speechToText.stop();
    }
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
          children: <Widget>[
            // Container(
            //   padding: const EdgeInsets.all(16),     
            //   child: Text( _lastWords.isEmpty ? 'Tiene que presionar el boton para hablar' : _lastWords, style: TextStyle(fontSize: 20.0),)
            // ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text( _lastWords.isEmpty ? 'Tiene que presionar el boton para hablar' : _lastWords, style: TextStyle(fontSize: 20.0),)
                  // Text(_speechToText.isListening 
                  //     ? _lastWords 
                  //     : _speechEnabled
                  //       ? 'Presione el microfono para Hablar'
                  //       : 'microfono no disponible'
                  //     ),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _speechEnabled,
        glowRadiusFactor: 75.0,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeat: false,
        child: FloatingActionButton(
          onPressed: _listen,//_speechToText.isNotListening ? _startListening : _stopListening,
          tooltip: 'Escuchar',
          child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
        ),
      ),
    );
  }
}