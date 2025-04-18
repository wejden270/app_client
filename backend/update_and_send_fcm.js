const mysql = require('mysql2/promise');
const admin = require('firebase-admin');

// Configuration Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: 'password',
  database: 'your_database',
});

// Mise à jour du token FCM
async function updateFcmToken(userId, userType, fcmToken) {
  const query = `
    INSERT INTO fcm_tokens (user_id, user_type, fcm_token)
    VALUES (?, ?, ?)
    ON DUPLICATE KEY UPDATE
      fcm_token = VALUES(fcm_token),
      updated_at = CURRENT_TIMESTAMP;
  `;
  await db.execute(query, [userId, userType, fcmToken]);
}

// Envoi de la notification
async function sendNotification(userId, userType, title, body) {
  const [rows] = await db.execute(
    'SELECT fcm_token FROM fcm_tokens WHERE user_id = ? AND user_type = ?',
    [userId, userType]
  );

  if (rows.length > 0) {
    const token = rows[0].fcm_token;
    const message = {
      token,
      notification: {
        title,
        body,
      },
    };

    try {
      await admin.messaging().send(message);
      console.log('Notification envoyée avec succès');
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification :', error);
    }
  } else {
    console.log('Aucun token FCM trouvé pour cet utilisateur.');
  }
}
