import 'dart:math';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';


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
  //dialogFlow
  late DialogFlowtter dialogFlowtter;
  String? textResponse;
  List<Map<String, dynamic>> messages = [];
  int precio = 0;
  final random = Random();
  Map<String,String>carrito = {};
  Map<String,int>ropaPrecio = {
    'Top Alicia': 105,
    'Top Mila': 115,
    'Top Nancy': 129,
    'Top Manu': 95,
    'Top Renata': 59,
    'Top Brenda': 75,
    'Campera Tiago': 210,
    'Basic': 109,
    'Camisa Tomas': 195,
    'Print Box Men': 139,
    'Short Jordan': 139,
    'Print Oliver':170,
    'Jogger Simon': 189
  };

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
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
    // print(voice);
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
    // print('result voice: ${result.recognizedWords}');
    if(result.finalResult){
      if(result.recognizedWords.contains('carrito') || result.recognizedWords.contains('carro') || result.recognizedWords.contains('lista')){
        textResponse = 'Tu carrito de compra tiene. ';
        if(!carrito.isEmpty){
          carrito.forEach((key, value) { 
            textResponse = '$textResponse $key en talla $value';
          });
        }else{
          textResponse= '$textResponse Nada';
        }
        textResponse = '$textResponse. precio total $precio';
        _flutterTts.speak(textResponse!);
      }else{
        sendMessage(result.recognizedWords);
      }
    }
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
              onPressed: _speechToText.isNotListening ? 
                _startListening
                : _stopListening,
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
    
                if(_lastWords.contains('carrito') || _lastWords.contains('carro') || _lastWords.contains('lista')){
                  textResponse = 'Tu carrito de compra tiene. ';
                  if(!carrito.isEmpty){
                    carrito.forEach((key, value) { 
                      textResponse = '$textResponse $key en talla $value';
                    });
                  }else{
                    textResponse= '$textResponse Nada';
                  }
                  textResponse = '$textResponse. precio total $precio';
                }else{
                  if(_lastWords != textResponse){
                    print('Mensaje enviado a DialogFlow');
                    // await sendMessage(_lastWords);
                  }
                }
                if(textResponse != null){
                  print(textResponse!);
                  _flutterTts.speak(textResponse!);
                }


              },
              tooltip: 'Reproducir',
              child: const Icon(Icons.volume_down_alt),
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
                showModalBottomSheet(
                  context: context,
                  builder: (context) => buildBottomSheet(context),
                );
              },
              tooltip: 'Escribir',
              child: const Icon(Icons.keyboard),
            ),
          ),
        ]
      ),
    );
  }

  Widget buildBottomSheet(context) {
    final controller = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onSubmitted: (_) {
              print(controller.text);
              _lastWords = controller.text;
              sendMessage(_lastWords);
              // Enviar el texto
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  sendMessage(String text) async {
    String ropa='';
    String talla='';
    String ropaM='';
    String tallaM='';
    int pagoTotal=0;

    print('sendMessage: $text');
    if (text.isEmpty) {
      print('Message is empty');
    } else {
      DetectIntentResponse response = await dialogFlowtter.detectIntent(queryInput: QueryInput(text: TextInput(text: text, languageCode: "es")));
      textResponse = response.text;

      response.queryResult!.parameters!.forEach((keyQuery, valueQuery) {
          print(keyQuery);
        if(keyQuery == 'talla' || keyQuery == 'tallaM'){
          talla=valueQuery.toString();
          if(keyQuery=='tallaM'){
            tallaM=valueQuery.toString();
          }
        }
        if(keyQuery == 'ropa' || keyQuery == 'ropaM') {
          if(keyQuery == 'ropaM'){
            ropaPrecio.forEach((key, value) {
                if(valueQuery[0] == key){
                  // precio+=random.nextInt(50) * 5;
                  pagoTotal += value;
                  if(valueQuery.length > 1){
                    // precio+=random.nextInt(50) * 5;
                    if(valueQuery[1] == key){
                      pagoTotal+=value;
                    }
                  }
                  ropaM = key;
                  
                }  
            }
            );
          }
          
          ropaPrecio.forEach((key, value) {
            if(valueQuery[0] == key){
              // precio+=random.nextInt(50) * 5;
              pagoTotal += value;
              if(valueQuery.length > 1){
                // precio+=random.nextInt(50) * 5;
                if(valueQuery[1] == key){
                  pagoTotal+=value;
                }
              }
              ropa = key;
              
            }  
          }
          );    
          
        }
        if(ropa != '' && talla!='')
          carrito.putIfAbsent(ropa, () => talla);

        if(ropaM != '' && tallaM !='')
          carrito.putIfAbsent(ropaM, () => tallaM);
      });
      if(pagoTotal >  0){
        precio = pagoTotal;
        textResponse = '$textResponse $precio bolivianos';
      }
      _flutterTts.speak(textResponse!);
    }
  }

  
}