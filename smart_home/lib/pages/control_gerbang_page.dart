import 'package:flutter/material.dart';
import 'package:smart_home/pages/esp_service.dart'; // Pastikan path ke esp_service benar

class ControlGerbangPage extends StatefulWidget {
  final EspService espService;

  // Constructor menerima espService
  ControlGerbangPage({required this.espService});

  @override
  _ControlGerbangPageState createState() => _ControlGerbangPageState();
}

class _ControlGerbangPageState extends State<ControlGerbangPage> with TickerProviderStateMixin {
  bool _isGateOpen = false;
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

  Future<void> _toggleGate(bool value) async {
    setState(() {
      _isLoading = true; // Tampilkan indikator loading
    });

    final command = value ? 'gerbang/open' : 'gerbang/close'; // Tentukan perintah yang dikirim
    final success = await widget.espService.sendCommand(command);

    if (success) {
      setState(() {
        _isGateOpen = value;
        _isLoading = false;

        // Jalankan animasi gerbang
        if (_isGateOpen) {
          _controller.forward(); // Gerbang terbuka
        } else {
          _controller.reverse(); // Gerbang tertutup
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Tampilkan pesan kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim perintah ke gerbang')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Gerbang'),
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
                  child: Image.asset(
                    'assets/images/gate.png',
                    height: 100,
                  ),
                );
              },
            ),
            SwitchListTile(
              title: Text('Buka/Tutup Gerbang'),
              value: _isGateOpen,
              onChanged: _isLoading ? null : _toggleGate,
            ),
            if (_isLoading) CircularProgressIndicator(), // Indikator loading
          ],
        ),
      ),
    );
  }
}
