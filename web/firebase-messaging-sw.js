importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyD6NeuqUhRusaCvXlSZAATHefGK7DzLSZw",
  authDomain: "projet-ec820.firebaseapp.com",
  projectId: "projet-ec820",
  storageBucket: "projet-ec820.firebasestorage.app",
  messagingSenderId: "531843061403",
  appId: "1:531843061403:web:6429872d7c13675fa3d83e",
  measurementId: "G-335D6QBGYD"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('Received background message ', payload);
});
