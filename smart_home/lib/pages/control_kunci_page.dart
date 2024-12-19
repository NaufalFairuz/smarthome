import 'package:flutter/material.dart';
import 'package:smart_home/pages/esp_service.dart'; // Pastikan path ke esp_service benar

class ControlKunciPage extends StatefulWidget {
  final EspService espService;

  // Constructor menerima espService
  ControlKunciPage({required this.espService});

  @override
  _ControlKunciPageState createState() => _ControlKunciPageState();
}

class _ControlKunciPageState extends State<ControlKunciPage> with TickerProviderStateMixin {
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
      _isLoading = true; // Tampilkan indikator loading
    });

    final command = value ? 'kunci/close' : 'kunci/open'; // Tentukan perintah yang dikirim
    final success = await widget.espService.sendCommand(command);

    if (success) {
      setState(() {
        _isLocked = value;
        _isLoading = false;

        // Jalankan animasi
        if (_isLocked) {
          _controller.reverse(); // Kunci tertutup
        } else {
          _controller.forward(); // Kunci terbuka
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Tampilkan pesan kesalahan
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
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_offsetAnimation.value, 0),
                  child: Icon(
                    _isLocked ? Icons.lock : Icons.lock_open,
                    size: 100,
                    color: Colors.blue,
                  ),
                );
              },
            ),
            SwitchListTile(
              title: Text('Kunci/Buka Rumah'),
              value: _isLocked,
              onChanged: _isLoading ? null : _toggleLock, // Nonaktifkan saat loading
            ),
            if (_isLoading) CircularProgressIndicator(), // Tampilkan loading indicator
          ],
        ),
      ),
    );
  }
}
