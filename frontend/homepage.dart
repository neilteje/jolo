import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Challenge',
      home: VoiceRecorderPage(),
    );
  }
}

class VoiceRecorderPage extends StatefulWidget {
  @override
  _VoiceRecorderPageState createState() => _VoiceRecorderPageState();
}

class _VoiceRecorderPageState extends State<VoiceRecorderPage> {
  bool _isRecording = false;
  Timer? _timer;
  double _amplitude = 50;

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _amplitude = (50 + (timer.tick % 10) * 10).toDouble();
      });
    });
  }

  void _stopRecording() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _isRecording = false;
        _amplitude = 50;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JOLO'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Text('Good afternoon, Neil'),
          Text('Welcome back to JOLO.'),
          SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What do I need to change about myself?'),
                  Text('Lorem ipsum dolor sit amet consectetur...'),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: CustomPaint(
                      painter: WaveformPainter(_isRecording, _amplitude),
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  if (_isRecording) Text('Recording... tap to stop') else Text('Tap to record'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Archive'),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final bool isRecording;
  final double amplitude;

  WaveformPainter(this.isRecording, this.amplitude);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = isRecording ? Colors.red : Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    var path = Path();
    for (int i = 0; i < size.width; i++) {
      double x = i.toDouble();
      double y = size.height / 2 + amplitude * (i % 2 == 0 ? 1 : -1) * (isRecording ? (i / size.width) : 1);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
