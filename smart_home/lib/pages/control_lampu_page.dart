import 'package:flutter/material.dart';
import 'esp_service.dart'; // Pastikan EspService diimport dengan benar

class ControlLampuPage extends StatefulWidget {
  final EspService espService;

  ControlLampuPage({required this.espService});

  @override
  _ControlLampuPageState createState() => _ControlLampuPageState();
}

class _ControlLampuPageState extends State<ControlLampuPage> {
  bool _lampu1On = false;
  bool _lampu2On = false;
  double _brightnessLampu1 = 0.5;
  double _brightnessLampu2 = 0.5;

  // Fungsi untuk menyalakan semua lampu
  void _turnOnAllLights() async {
    try {
      await Future.wait([
        widget.espService.sendCommand('lampu1?value=255'),
        widget.espService.sendCommand('lampu2?value=255'),
      ]);
      setState(() {
        _lampu1On = true;
        _lampu2On = true;
        _brightnessLampu1 = 1.0;
        _brightnessLampu2 = 1.0;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal menyalakan semua lampu: $e');
    }
  }

  // Fungsi untuk mematikan semua lampu
  void _turnOffAllLights() async {
    try {
      await Future.wait([
        widget.espService.sendCommand('lampu1?value=0'),
        widget.espService.sendCommand('lampu2?value=0'),
      ]);
      setState(() {
        _lampu1On = false;
        _lampu2On = false;
        _brightnessLampu1 = 0.0;
        _brightnessLampu2 = 0.0;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal mematikan semua lampu: $e');
    }
  }

  // Menampilkan SnackBar jika terjadi error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Lampu'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kontrol Lampu 1
            _buildLampControl(
              lampuOn: _lampu1On,
              brightness: _brightnessLampu1,
              onToggle: (value) async {
                try {
                  if (value) {
                    await widget.espService.sendCommand('lampu1?value=255');
                  } else {
                    await widget.espService.sendCommand('lampu1?value=0');
                  }
                  setState(() {
                    _lampu1On = value;
                  });
                } catch (e) {
                  _showErrorSnackBar('Gagal mengubah status Lampu 1: $e');
                }
              },
              onBrightnessChange: (value) async {
                try {
                  int brightnessValue = (value * 255).toInt();
                  await widget.espService.sendCommand('lampu1?value=$brightnessValue');
                  setState(() {
                    _brightnessLampu1 = value;
                  });
                } catch (e) {
                  _showErrorSnackBar('Gagal mengubah kecerahan Lampu 1: $e');
                }
              },
              title: 'Lampu 1',
              color: Colors.yellow,
            ),
            SizedBox(height: 20),
            // Kontrol Lampu 2
            _buildLampControl(
              lampuOn: _lampu2On,
              brightness: _brightnessLampu2,
              onToggle: (value) async {
                try {
                  if (value) {
                    await widget.espService.sendCommand('lampu2?value=255');
                  } else {
                    await widget.espService.sendCommand('lampu2?value=0');
                  }
                  setState(() {
                    _lampu2On = value;
                  });
                } catch (e) {
                  _showErrorSnackBar('Gagal mengubah status Lampu 2: $e');
                }
              },
              onBrightnessChange: (value) async {
                try {
                  int brightnessValue = (value * 255).toInt();
                  await widget.espService.sendCommand('lampu2?value=$brightnessValue');
                  setState(() {
                    _brightnessLampu2 = value;
                  });
                } catch (e) {
                  _showErrorSnackBar('Gagal mengubah kecerahan Lampu 2: $e');
                }
              },
              title: 'Lampu 2',
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            // Tombol Matikan dan Nyalakan Semua Lampu
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _turnOnAllLights,
                  child: Text('Nyalakan Semua Lampu'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _turnOffAllLights,
                  child: Text('Matikan Semua Lampu'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLampControl({
    required bool lampuOn,
    required double brightness,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onBrightnessChange,
    required String title,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: lampuOn ? color.withOpacity(0.3) : Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: lampuOn,
                onChanged: onToggle,
              ),
            ],
          ),
          AnimatedOpacity(
            opacity: lampuOn ? 1.0 : 0.3,
            duration: Duration(milliseconds: 300),
            child: Icon(
              Icons.lightbulb,
              color: lampuOn ? color : Colors.grey,
              size: 50,
            ),
          ),
          Slider(
            value: brightness,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(brightness * 100).toInt()}%',
            onChanged: lampuOn ? onBrightnessChange : null,
          ),
        ],
      ),
    );
  }
}
