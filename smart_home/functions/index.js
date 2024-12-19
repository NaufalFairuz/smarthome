const {onRequest} = require(
    "firebase-functions/v2/https",
);
const {getDatabase} = require(
    "firebase-admin/database",
);
const admin = require("firebase-admin");

admin.initializeApp();

exports.monitorEnvironment = onRequest(
    async (request, response) => {
      try {
        // Referensi ke Realtime Database
        const db = getDatabase();
        const ref = db.ref(
            "environment",
        ); // Ganti "environment" dengan nama path database kamu

        // Ambil data suhu dan gas
        const snapshot = await ref.once("value");
        const data = snapshot.val();
        const temperature = data.temperature || 0;
        const gasLevel = data.gas || 0;

        // Ambang batas suhu dan gas
        const temperatureThreshold = 33; // Ganti sesuai kebutuhan
        const gasThreshold = 600; // Ganti sesuai kebutuhan

        // Cek apakah ada pelanggaran ambang batas
        let notificationTitle = "";
        let notificationBody = "";

        if (temperature > temperatureThreshold) {
          notificationTitle =
            "Peringatan Suhu Tinggi!";
          notificationBody =
            `Suhu telah mencapai ${temperature}°C.`;
        } else if (gasLevel > gasThreshold) {
          notificationTitle =
            "Peringatan Gas Berbahaya!";
          notificationBody =
            `Kadar gas telah mencapai ` +
            `${gasLevel}.`;
        }

        if (notificationTitle && notificationBody) {
          // Kirim notifikasi ke perangkat
          const message = {
            notification: {
              title: notificationTitle,
              body: notificationBody,
            },
            topic: "environmentAlerts",
          };
          await admin.messaging().send(message);
          response.status(200).send(
              "Notifikasi berhasil dikirim!",
          );
        } else {
          response.status(200).send(
              "Tidak ada pelanggaran ambang batas.",
          );
        }
      } catch (error) {
        console.error("Error:", error);
        response.status(500).send(
            "Terjadi kesalahan.",
        );
      }
    },
);
