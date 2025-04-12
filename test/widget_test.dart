import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clients_app/main.dart'; // Assure-toi que le bon package est utilisé

void main() {
  testWidgets('Vérifier l\'affichage et la navigation des boutons', (WidgetTester tester) async {
    // Construire l'application et déclencher un frame
    await tester.pumpWidget(const MyApp()); // Remplace `MyApp` si ton widget principal a un autre nom

    // Vérifier que les boutons sont affichés avec les bons textes
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('S\'inscrire'), findsOneWidget);

    // Simuler un appui sur le bouton "Se connecter"
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle(); // Attendre que l'interface soit mise à jour

    // Vérifier la présence du champ email (ou tout autre élément spécifique à l'écran de connexion)
    expect(find.byType(TextField), findsWidgets); // Vérifie s'il y a un champ texte (email, mot de passe, etc.)
  });
}
