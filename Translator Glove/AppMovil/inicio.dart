import 'package:appmovil/Firebase/sensores.dart';
import 'package:appmovil/Pages/pagina2.dart';
import 'package:appmovil/models/model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});
  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gesture Predict',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
              _buildButton(
                icon: Icons.back_hand_outlined,
                label: 'Traducir Señas',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ModelPredictor())),
              ),
              const SizedBox(height: 20),
              _buildButton(
                icon: Icons.build_outlined,
                label: 'Datos de Sensores',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RelTimeData())),
              ),
              const SizedBox(height: 20),
              _buildButton(
                icon: Icons.local_library_outlined,
                label: 'Aprende Señas',
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AprendeSenas())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 30),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(250, 60),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[700],
      ),
      label: Text(
        label,
        style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }
}
