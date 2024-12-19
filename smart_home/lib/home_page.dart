import 'package:flutter/material.dart';
import 'package:smart_home/pages/control_gerbang_page.dart';
import 'package:smart_home/pages/control_kunci_page.dart';
import 'package:smart_home/pages/control_lampu_page.dart';
import 'package:smart_home/pages/monitoring_ruang_page.dart';
import 'package:smart_home/pages/settings_page.dart';
import 'package:smart_home/pages/esp_service.dart'; // Import EspService

class HomePage extends StatelessWidget {
  final EspService espService = EspService("http://192.168.43.233"); // Base URL ESP8266

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Image.asset('assets/images/logo.png', height: 80), // Logo di bagian atas
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  ControlTile(
                    iconPath: 'assets/images/light_icon.png',
                    label: 'Control Lampu',
                    onTap: () async {
                      bool isConnected = await espService.checkConnection();
                      if (isConnected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ControlLampuPage(espService: espService),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tidak dapat terhubung ke ESP')),
                        );
                      }
                    },
                  ),
                  ControlTile(
                    iconPath: 'assets/images/gate_icon.png',
                    label: 'Control Gerbang',
                    onTap: () async {
                      bool isConnected = await espService.checkConnection();
                      if (isConnected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ControlGerbangPage(espService: espService),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tidak dapat terhubung ke ESP')),
                        );
                      }
                    },
                  ),
                  ControlTile(
                    iconPath: 'assets/images/room_icon.png',
                    label: 'Monitoring Ruang',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MonitoringRuangPage(),
                        ),
                      );
                    },
                  ),
                  ControlTile(
                    iconPath: 'assets/images/key_icon.png',
                    label: 'Control Kunci',
                    onTap: () async {
                      bool isConnected = await espService.checkConnection();
                      if (isConnected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ControlKunciPage(espService: espService),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tidak dapat terhubung ke ESP')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/images/clock.png")),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/images/home.png")),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              child: ImageIcon(AssetImage("assets/images/setting.png")),
            ),
            label: '',
          ),
        ],
        currentIndex: 1, // Menandai Home sebagai halaman aktif
        selectedItemColor: Colors.grey[800],
        unselectedItemColor: Colors.grey[400],
      ),
    );
  }
}

class ControlTile extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const ControlTile({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              height: 50,
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
