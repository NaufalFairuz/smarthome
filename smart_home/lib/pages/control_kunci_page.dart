import 'package:flutter/material.dart';
import 'package:smart_home/pages/esp_service.dart'; // Pastikan path ke esp_service benar

class ControlKunciPage extends StatefulWidget {
  final EspService espService;

  // Constructor menerima espService
  ControlKunciPage({required this.espService});

  @override
  _ControlKunciPageState createState() => _ControlKunciPageState();
}

class _ControlKunciPageState extends State<ControlKunciPage>
    with TickerProviderStateMixin {
  bool _isLocked = true;
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _offsetAnimation = Tween<double>(begin: 0, end: 50).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleLock(bool value) async {
    setState(() {
      _isLoading = true;
    });

    final command = value ? 'kunci/close' : 'kunci/open';
    final success = await widget.espService.sendCommand(command);

    if (success) {
      setState(() {
        _isLocked = value;
        _isLoading = false;

        if (_isLocked) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim perintah ke kunci')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Kunci Rumah'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.3),
                        Colors.blueAccent.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_offsetAnimation.value, 0),
                      child: Icon(
                        _isLocked ? Icons.lock : Icons.lock_open,
                        size: 80,
                        color: _isLocked ? Colors.red : Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _isLoading ? null : () => _toggleLock(!_isLocked),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  color: _isLocked ? Colors.redAccent : Colors.greenAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  _isLocked ? 'Kunci Rumah' : 'Buka Rumah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
