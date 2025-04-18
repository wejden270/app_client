import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.FormBody

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("FCM", "New token: $token")
        sendTokenToServer(token) // Envoyer le token au backend
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.d("FCM", "Message received: ${remoteMessage.data}")
        // Gérer les notifications ici si nécessaire
    }

    private fun sendTokenToServer(token: String) {
        val client = OkHttpClient()
        val url = "https://your-backend-url.com/api/update-token" // Remplacez par l'URL de votre API

        val formBody = FormBody.Builder()
            .add("remember_token", token)
            .build()

        val request = Request.Builder()
            .url(url)
            .post(formBody)
            .build()

        client.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                Log.e("FCM", "Failed to send token to server: ${response.message}")
            } else {
                Log.d("FCM", "Token sent successfully to server")
            }
        }
    }
}
