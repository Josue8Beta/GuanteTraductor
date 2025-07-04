import 'package:flutter/material.dart';
import 'dart:math' as math;

class SensorAnimation extends StatefulWidget {
  final String sensorType;
  final double value;
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;

  const SensorAnimation({
    super.key,
    required this.sensorType,
    this.value = 0,
    this.accelX = 0,
    this.accelY = 0,
    this.accelZ = 0,
    this.gyroX = 0,
    this.gyroY = 0,
  });

  @override
  SensorAnimationState createState() => SensorAnimationState();
}

class SensorAnimationState extends State<SensorAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Center(
          child: CustomPaint(
            size: const Size(200, 200),
            painter: _getSensorPainter(),
          ),
        );
      },
    );
  }

  CustomPainter _getSensorPainter() {
    switch (widget.sensorType) {
      case 'Flex':
        return FlexSensorPainter(_animation.value, widget.value);
      case 'Acelerómetro':
        return AccelerometerPainter(
            _animation.value, widget.accelX, widget.accelY, widget.accelZ);
      case 'Giroscopio':
        return GyroscopePainter(_animation.value, widget.gyroX, widget.gyroY);
      default:
        return FlexSensorPainter(_animation.value, widget.value);
    }
  }
}

class FlexSensorPainter extends CustomPainter {
  final double animationValue;
  final double flexValue;

  FlexSensorPainter(this.animationValue, this.flexValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Normalizar el valor de flexión (asumiendo un rango de 0 a 4095)
    final normalizedFlex = flexValue / 4095;

    final fingerPath = Path()
      ..moveTo(center.dx - radius, center.dy)
      ..quadraticBezierTo(
        center.dx,
        center.dy - (radius * normalizedFlex),
        center.dx + radius,
        center.dy,
      );

    canvas.drawPath(fingerPath, paint);
  }

  @override
  bool shouldRepaint(FlexSensorPainter oldDelegate) => true;
}

class AccelerometerPainter extends CustomPainter {
  final double animationValue;
  final double accelX;
  final double accelY;
  final double accelZ;

  AccelerometerPainter(
      this.animationValue, this.accelX, this.accelY, this.accelZ);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 4;

    // Normalizar los valores de aceleración (asumiendo un rango de -10 a 10 m/s²)
    final normalizedX = (accelX + 10) / 20;
    final normalizedY = (accelY + 10) / 20;
    final normalizedZ = (accelZ + 10) / 20;

    final x = radius * normalizedX;
    final y = radius * normalizedY;

    // Usar el valor Z para el tamaño del círculo
    final circleRadius = 5 + (normalizedZ * 10);

    canvas.drawCircle(
        center + Offset(x - radius / 2, y - radius / 2), circleRadius, paint);
  }

  @override
  bool shouldRepaint(AccelerometerPainter oldDelegate) => true;
}

class GyroscopePainter extends CustomPainter {
  final double animationValue;
  final double gyroX;
  final double gyroY;

  GyroscopePainter(this.animationValue, this.gyroX, this.gyroY);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;

    // Normalizar los valores del giroscopio (asumiendo un rango de -500 a 500 grados/s)
    final normalizedX = (gyroX + 500) / 1000;
    final normalizedY = (gyroY + 500) / 1000;

    final angleX = normalizedX * 2 * math.pi;
    final angleY = normalizedY * 2 * math.pi;

    final x1 = radius * math.cos(angleX);
    final y1 = radius * math.sin(angleY);
    final x2 = -x1;
    final y2 = -y1;

    canvas.drawLine(center + Offset(x1, y1), center + Offset(x2, y2), paint);
  }

  @override
  bool shouldRepaint(GyroscopePainter oldDelegate) => true;
}
