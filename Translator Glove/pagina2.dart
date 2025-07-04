import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AprendeSenas extends StatelessWidget {
  const AprendeSenas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aprende Señas',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 100,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[100]!, Colors.blue[400]!],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: [
            _buildSection(
              title: 'Tutoriales',
              icon: Icons.play_circle_outline,
              onTap: () {
                _showVideoLinks(context);
              },
            ),
            _buildSection(
              title: 'Diccionario de Señas',
              icon: Icons.book,
              onTap: () {
                _linksDicc(context);
              },
            ),
            _buildSection(
              title: 'Cultura Sorda',
              icon: Icons.people,
              onTap: () {
                _culturaSorda(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoLinks(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue[100], // Color azul claro
          title: Text('Videos Tutoriales',
              style: GoogleFonts.roboto(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogItem('Saludos Formales',
                    'https://www.youtube.com/watch?v=a616tBRvPgk&pp=ygUTc2XDsWFzIGVjdWF0b3JpYW5hcw%3D%3D'),
                const SizedBox(height: 5),
                _buildDialogItem('Abecedario',
                    'https://www.youtube.com/watch?v=K6tuWefifxc&pp=ygUTc2XDsWFzIGVjdWF0b3JpYW5hcw%3D%3D'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cerrar',
                  style: GoogleFonts.roboto(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogItem(String title, String url) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.blue[700],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
        onTap: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            print('No se pudo abrir la URL');
          }
        },
      ),
    );
  }

  void _culturaSorda(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue[100], // Color azul claro
          title: Text('Cultura Sorda',
              style: GoogleFonts.roboto(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogItem(
                    'Página Oficial', 'https://cultura-sorda.org/'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cerrar',
                  style: GoogleFonts.roboto(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _linksDicc(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue[100], // Color azul claro
          title: Text('Diccionario de Señas',
              style: GoogleFonts.roboto(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogItem('Diccionario Gabriel Román',
                    'http://www.plataformaconadis.gob.ec/~platafor/diccionario/'),
                const SizedBox(height: 5),
                _buildDialogItem('Lengua de Señas Ecuatoriana',
                    'https://www.vicepresidencia.gob.ec/wp-content/uploads/downloads/2013/04/Compilacion-Final-Interactivo.pdf'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cerrar',
                  style: GoogleFonts.roboto(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 36, color: Colors.blue[700]),
        title: Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.blue[700],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
        onTap: onTap,
      ),
    );
  }
}
