import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';

// import 'package:appmovil/models/reshape.dart';
//import 'package:collection/collection.dart';
class Category {
  final String label;
  final double score;

  Category(this.label, this.score);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: ModelPredictor()));
}

class ModelPredictor extends StatefulWidget {
  const ModelPredictor({super.key});

  @override
  ModelPredictorState createState() => ModelPredictorState();
}

class ModelPredictorState extends State<ModelPredictor> {
  final List<double> means = [
    3765.845265408867,
    3190.0948012479184,
    3035.557117017183,
    3510.393693754023,
    3706.387150946137,
    7.732744643821431,
    1.6618465455158538,
    0.3254653331543827,
    0.9820175503879984,
    3.314855887028633,
    -0.7506291934458335
  ];

  final List<double> scales = [
    383.04825505766837,
    523.6792419689415,
    353.0132076857515,
    321.9238512113866,
    366.313501290756,
    3.9870302486604796,
    3.048152060922383,
    3.974590840408789,
    26.84802445928352,
    33.76176728856988,
    30.039826308995753
  ];
  final List<String> classes = [
    'a',
    'b',
    'c',
    'chao',
    'como estas?',
    'd',
    'e',
    'f',
    'g',
    'gracias',
    'h',
    'hola',
    'i',
    'j',
    'k',
    'l',
    'lo siento',
    'm',
    'n',
    'no',
    'no hay problema',
    'o',
    'p',
    'porfavor',
    'q',
    'r',
    's',
    'si',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z'
  ];
  String _displayText = '';
  bool _isProcessing = false;
  List<String> predictions = [];
  late Interpreter _interpreter;
  final FlutterTts flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isAlertShowing = false;
  StreamSubscription<DatabaseEvent>? _subscription;
  //String _lastPrediction = '';
  //DateTime _lastPredictionTime = DateTime.now();
  List<String> _predictionBuffer = [];
  int _bufferSize = 5;
  Timer? _bufferTimer;
  Timer? _longPressTimer;
  @override
  void initState() {
    super.initState();
    initializeFirebaseAndLoadModel();
    _startBufferTimer();
  }

  void _startBufferTimer() {
    _bufferTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _processPredictionBuffer();
    });
  }

  Future<void> initializeFirebaseAndLoadModel() async {
    await Firebase.initializeApp();
    await loadModel();
    _startListening();
  }

  Future<void> loadModel() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('/modelos/Modelo_final_3.tflite');
      final file = File('${Directory.systemTemp.path}/Modelo.tflite');
      await storageRef.writeToFile(file);
      if (await file.exists()) {
        print('El archivo existe: ${file.path}');
      } else {
        print('El archivo no existe');
      }
      _interpreter = Interpreter.fromFile(file);

      print('Modelo cargado con éxito');
      print('Input shape: ${_interpreter.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter.getOutputTensor(0).shape}');
      print('Input type: ${_interpreter.getInputTensor(0).type}');
      print('Output type: ${_interpreter.getOutputTensor(0).type}');
    } catch (e) {
      print('Error al cargar el modelo: $e');
    }
  }

  void _startListening() {
    if (!_isListening) {
      _subscription =
          FirebaseDatabase.instance.ref('sensores').onValue.listen((event) {
        if (event.snapshot.value != null && !_isProcessing) {
          _isProcessing = true;
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final List<double> input = [
            data['Flex1'].toDouble(),
            data['Flex2'].toDouble(),
            data['Flex3'].toDouble(),
            data['Flex4'].toDouble(),
            data['Flex5'].toDouble(),
            data['AX'].toDouble(),
            data['AY'].toDouble(),
            data['AZ'].toDouble(),
            data['GX'].toDouble(),
            data['GY'].toDouble(),
            data['GZ'].toDouble()
          ];
          final normalizedInput = _preProcess(input);
          _predict(normalizedInput);
        }
      });
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() {
    _subscription?.cancel();
    setState(() {
      _isListening = false;
    });
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  List<double> _normalizeInput(List<double> entrada) {
    return List.generate(entrada.length, (i) {
      return (entrada[i] - means[i]) / scales[i];
    });
  }

  List<double> _preProcess(List<double> input) {
    return _normalizeInput(input);
  }

  void _showAlert(String message) {
    if (_isAlertShowing)
      return; // Si ya se está mostrando una alerta, no hacer nada

    setState(() {
      _isAlertShowing = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.orangeAccent,
          title: const Text('Alerta',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: Text(message, style: const TextStyle(fontSize: 20)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK',
                  style: TextStyle(fontSize: 20, color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isAlertShowing = false;
                  _isProcessing = false;
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _predict(List<double> input) async {
    try {
      print('Input normalizado: $input');
      var inputShape = [1, 11];
      var outputShape = [1, 35];

      var inputTensor = input.reshape(inputShape);
      var outputTensor = List<double>.filled(35, 0).reshape(outputShape);

      _interpreter.run(inputTensor, outputTensor);
      print('Interprete funcional');
      int maxIndex = 0;
      double maxValue = outputTensor[0][0];
      for (int i = 1; i < outputTensor[0].length; i++) {
        if (outputTensor[0][i] > maxValue) {
          maxValue = outputTensor[0][i];
          maxIndex = i;
        }
      }
      print('Output tensor: $outputTensor');
      print('Índice máximo: $maxIndex, Valor máximo: $maxValue');
      if (maxValue > 0.41) {
        // String prediction = classes[maxIndex];
        // if (prediction != _lastPrediction &&
        //     DateTime.now().difference(_lastPredictionTime).inSeconds >= 0.5) {
        //   _updatePrediction(prediction);
        //   _lastPrediction = prediction;
        //   _lastPredictionTime = DateTime.now();
        String prediction = classes[maxIndex];
        _addToPredictionBuffer(prediction);

        print('Predicción: $prediction, Confianza: $maxValue');
        // // Ajusta este valor según sea necesario
      } else {
        _showAlert('No se reconoce el gesto');
      }
    } catch (e) {
      print('Error al realizar la predicción: $e');
    } finally {
      if (!_isAlertShowing) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _addToPredictionBuffer(String prediction) {
    _predictionBuffer.add(prediction);
    if (_predictionBuffer.length > _bufferSize) {
      _predictionBuffer.removeAt(0);
    }
  }

  void _processPredictionBuffer() {
    if (_predictionBuffer.isEmpty) return;

    // Contar las ocurrencias de cada predicción en el buffer
    Map<String, int> predictionCounts = {};
    for (var prediction in _predictionBuffer) {
      predictionCounts[prediction] = (predictionCounts[prediction] ?? 0) + 1;
    }

    // Encontrar la predicción más común
    String? mostCommonPrediction;
    int maxCount = 0;
    predictionCounts.forEach((prediction, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonPrediction = prediction;
      }
    });

    // Si la predicción más común aparece más de la mitad de las veces en el buffer, actualizar el display
    if (mostCommonPrediction != null && maxCount > _bufferSize / 2) {
      _updatePrediction(mostCommonPrediction!);
      _predictionBuffer
          .clear(); // Limpiar el buffer después de una predicción exitosa
    }
  }

  void _updatePrediction(String prediction) {
    // setState(() {
    //   _displayText += (_displayText.isEmpty ? '' : ' ') + prediction;
    //   _isProcessing = false;
    // });
    setState(() {
      if (_displayText.isEmpty || _displayText.endsWith(' ')) {
        _displayText += prediction;
      } else {
        _displayText += ' $prediction';
      }
    });
  }

  void _clearLastCharacter() {
    setState(() {
      if (_displayText.isNotEmpty) {
        if (_displayText.endsWith(' ')) {
          _displayText =
              _displayText.substring(0, _displayText.lastIndexOf(' '));
        } else {
          _displayText = _displayText.substring(0, _displayText.length - 1);
        }
      }
    });
  }

  void _clearAllPredictions() {
    setState(() {
      _displayText = '';
      _predictionBuffer.clear();
    });
  }

  void _handleClearButtonPress() {
    _clearLastCharacter();
    _longPressTimer = Timer(const Duration(milliseconds: 500), () {
      _clearAllPredictions();
    });
  }

  void _handleClearButtonRelease() {
    _longPressTimer?.cancel();
  }

  Future<void> _speakPredictions() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.speak(_displayText);
  }

  void _clearPredictions() {
    setState(() {
      predictions.clear();
      _displayText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Predicción',
          style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[100]!, Colors.blue[400]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 350.0,
                height: 450.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _displayText,
                        style: GoogleFonts.roboto(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _speakPredictions,
                    icon: const Icon(Icons.campaign_outlined, size: 30),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 55),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue[700],
                    ),
                    label: Text('Reproducir',
                        style: GoogleFonts.roboto(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _clearPredictions,
                    icon: const Icon(Icons.cleaning_services_rounded, size: 30),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 55),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue[700],
                    ),
                    label: Text(
                      'Borrar',
                      style: GoogleFonts.roboto(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _toggleListening,
                icon: Icon(
                    _isListening
                        ? Icons.pause_circle_outline
                        : Icons.play_arrow_outlined,
                    size: 30),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 55),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: _isListening ? Colors.red : Colors.green,
                ),
                label: Text(
                  _isListening ? 'Detener' : 'Reanudar',
                  style: GoogleFonts.roboto(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bufferTimer?.cancel();
    _longPressTimer?.cancel();
    super.dispose();
  }
}
