#include <ESP8266WiFi.h>
#include <Firebase_ESP_Client.h>
#include <ArduinoJson.h>
#include <time.h>
#include <addons/TokenHelper.h>

// Konfigurasi WiFi
#define WIFI_SSID "Teras JTI"
#define WIFI_PASSWORD "12345678910"

// Konfigurasi Firebase
#define DATABASE_URL "https://aplikasimobile-15049-default-rtdb.asia-southeast1.firebasedatabase.app/" 
#define API_KEY "AIzaSyDWlM-cGKFt4JZteTumAaEIGlfbu46YZaM"
#define USER_EMAIL "kleponracing@gmail.com"
#define USER_PASSWORD "adminklepon"

// NTP server untuk timestamp
const char* ntpServer = "pool.ntp.org";
const long gmtOffset_sec = 25200; // GMT+7 (WITA)
const int daylightOffset_sec = 0;

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool isAuthenticated = false;

void connectToWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Menghubungkan ke Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);
  }
  Serial.println("\nTerhubung ke Wi-Fi.");
}

void loginToFirebase() {
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  if (Firebase.ready()) {
    Serial.println("Login ke Firebase berhasil.");
    isAuthenticated = true;
  } else {
    Serial.println("Gagal login ke Firebase.");
    Serial.println("Error: " + String(config.signer.tokens.error.message.c_str()));
  }
}

void setupNTP() {
  configTime(gmtOffset_sec, daylightOffset_sec, ntpServer);
  Serial.println("NTP diinisialisasi.");
}

String getFormattedTime() {
  struct tm timeInfo;
  if (!getLocalTime(&timeInfo)) {
    Serial.println("Gagal mendapatkan waktu.");
    return "";
  }

  char timeString[50];
  strftime(timeString, sizeof(timeString), "%Y-%m-%d %H:%M:%S", &timeInfo);
  return String(timeString);
}

void setup() {
  Serial.begin(9600); // Serial untuk debugging
  Serial.println("Menginisialisasi ESP8266...");

  connectToWiFi();
  loginToFirebase();
  setupNTP();
}

void loop() {
  // Mengecek apakah Firebase siap dan data tersedia di Serial
  if (isAuthenticated && Serial.available()) {
    String jsonData = Serial.readStringUntil('\n');
    Serial.println("Data diterima dari Arduino: " + jsonData);

    // Parsing JSON menggunakan ArduinoJson
    StaticJsonDocument<200> doc;
    DeserializationError error = deserializeJson(doc, jsonData);

    if (error) {
      Serial.print("Gagal mem-parse JSON: ");
      Serial.println(error.c_str());
      return;
    }


    FirebaseJson json;
    String formattedTime = getFormattedTime();
    json.setJsonData(jsonData);
    json.add("timestamp", formattedTime);

    // Mengirim data ke Firebase
    if (Firebase.RTDB.pushJSON(&fbdo, "/sensorData", &json)) {
      Serial.println("Data berhasil dikirim ke Firebase.");
    } else {
      Serial.println("Gagal mengirim data ke Firebase.");
      Serial.print("Error: ");
      Serial.println(fbdo.errorReason());
    }
  }


  delay(3000); // Interval pendek untuk loop
}
