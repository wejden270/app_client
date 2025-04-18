INSERT INTO fcm_tokens (user_id, user_type, fcm_token)
VALUES (?, ?, ?)
ON DUPLICATE KEY UPDATE
    fcm_token = VALUES(fcm_token),
    updated_at = CURRENT_TIMESTAMP;
