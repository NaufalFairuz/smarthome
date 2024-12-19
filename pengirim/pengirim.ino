#include <DHT.h>
#include <ArduinoJson.h>
#include <SoftwareSerial.h>
#include <Servo.h>


#define LDR_PIN A0
#define GAS_PIN A1
#define DHT_PIN 2
#define LED1_PIN 3
#define LED2_PIN 4
#define BUZZER_PIN 5
#define SERVO_PIN 6

// Konfigurasi DHT
#define DHTTYPE DHT11
DHT dht(DHT_PIN, DHTTYPE);

// Servo
Servo servo;

// SoftwareSerial untuk komunikasi dengan ESP8266
SoftwareSerial espSerial(10, 11); // RX, TX ke ESP8266

// Variabel
int ldrValue;
int gasValue;
float temperature;
float humidity;

// Threshold LDR
#define LDR_THRESHOLD 50

void setup() {
  Serial.begin(9600);
  espSerial.begin(9600); // Sesuaikan baud rate dengan ESP8266
  dht.begin();
  
  pinMode(LED1_PIN, OUTPUT);
  pinMode(LED2_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  
  servo.attach(SERVO_PIN);
  servo.write(0); // Gerbang tertutup secara default

  Serial.println("Smart Home Sistem Dimulai...");
}

void loop() {
  // Membaca data sensor
  ldrValue = analogRead(LDR_PIN);
  gasValue = analogRead(GAS_PIN);
  temperature = dht.readTemperature();
  humidity = dht.readHumidity();

  // Cek jika pembacaan sensor berhasil
  if (!isnan(temperature) && !isnan(humidity)) {
    // Membuat JSON data
    StaticJsonDocument<200> jsonDoc;
    jsonDoc["ldr"] = round((ldrValue / 1023.0) * 100.0); // Konversi ke persen
    jsonDoc["gas"] = gasValue;
    jsonDoc["temperature"] = temperature;
    jsonDoc["humidity"] = humidity;

    // Mengubah JSON menjadi string
    String jsonString;
    serializeJson(jsonDoc, jsonString);

    // Mengirimkan JSON ke ESP8266
    espSerial.println(jsonString);

    // Menampilkan data di Serial Monitor
    Serial.println("Data JSON dikirim ke ESP8266:");
    Serial.println(jsonString);
  } else {
    Serial.println("Gagal membaca data dari sensor DHT!");
  }

  // Kontrol otomatis LED dan Servo berdasarkan LDR
  if (ldrValue < LDR_THRESHOLD) {
    digitalWrite(LED1_PIN, HIGH);
    digitalWrite(LED2_PIN, HIGH);
    servo.write(90); // Gerbang terbuka
  } else {
    digitalWrite(LED1_PIN, LOW);
    digitalWrite(LED2_PIN, LOW);
    servo.write(0); // Gerbang tertutup
  }
/''
  // Kontrol buzzer berdasarkan gas dan suhu
  if (gasValue > 250 || temperature > 33) {
    digitalWrite(BUZZER_PIN, HIGH);
  } else {
    digitalWrite(BUZZER_PIN, LOW);
  }

  // Delay sebelum pembacaan berikutnya
  delay(3000); // 2 detik
}
