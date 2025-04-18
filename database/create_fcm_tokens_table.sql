CREATE TABLE fcm_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL, -- ID de l'utilisateur (client ou chauffeur)
    user_type ENUM('client', 'chauffeur') NOT NULL, -- Type d'utilisateur
    fcm_token TEXT NOT NULL, -- Token FCM
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Date de mise à jour
    FOREIGN KEY (user_id) REFERENCES users(id) -- Assurez-vous que la table `users` existe
);
