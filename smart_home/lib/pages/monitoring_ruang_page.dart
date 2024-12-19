import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MonitoringRuangPage extends StatefulWidget {
  const MonitoringRuangPage({Key? key}) : super(key: key);

  @override
  _MonitoringRuangPageState createState() => _MonitoringRuangPageState();
}

class _MonitoringRuangPageState extends State<MonitoringRuangPage> {
  double? suhu;
  double? gasLevel;
  double? kelembapan;
  String? waktu;
  bool isLoading = true;
  bool hasError = false;

  // Referensi ke Firebase Realtime Database
  final DatabaseReference suhuRef = FirebaseDatabase.instance.ref('data/suhu');
  final DatabaseReference gasRef = FirebaseDatabase.instance.ref('data/gas');
  final DatabaseReference kelembapanRef = FirebaseDatabase.instance.ref('data/kelembapan');
  final DatabaseReference waktuRef = FirebaseDatabase.instance.ref('data/waktu');

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirebase();
  }

  Future<void> _fetchDataFromFirebase() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      // Listener untuk suhu
      suhuRef.onValue.listen((event) {
        setState(() {
          final value = event.snapshot.value;
          suhu = value != null ? double.tryParse(value.toString()) : null;
        });
      });

      // Listener untuk gas
      gasRef.onValue.listen((event) {
        setState(() {
          final value = event.snapshot.value;
          gasLevel = value != null ? double.tryParse(value.toString()) : null;
        });
      });

      // Listener untuk kelembapan
      kelembapanRef.onValue.listen((event) {
        setState(() {
          final value = event.snapshot.value;
          kelembapan = value != null ? double.tryParse(value.toString()) : null;
        });
      });

      // Listener untuk waktu
      waktuRef.onValue.listen((event) {
        setState(() {
          waktu = event.snapshot.value?.toString();
        });
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Ruang'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('Gagal memuat data'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data Ruangan', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 20),
                      Text('Suhu: ${suhu != null ? suhu!.toStringAsFixed(2) : '--'} °C'),
                      const SizedBox(height: 10),
                      Text('Gas Level: ${gasLevel ?? '--'}'),
                      const SizedBox(height: 10),
                      Text('Kelembapan: ${kelembapan != null ? kelembapan!.toStringAsFixed(2) : '--'} %'),
                      const SizedBox(height: 10),
                      Text('Waktu: ${waktu ?? '--'}'),
                    ],
                  ),
                ),
    );
  }
}
