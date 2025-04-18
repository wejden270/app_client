use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

Route::post('/api/update-token', function (Request $request) {
    // Valider les données entrantes
    $validated = $request->validate([
        'user_id' => 'required|exists:users,id', // Vérifie que l'user_id existe dans la table users
        'remember_token' => 'required|string', // Le token est obligatoire et doit être une chaîne
    ]);

    // Mettre à jour la colonne remember_token pour l'utilisateur spécifié
    DB::table('users')
        ->where('id', $validated['user_id'])
        ->update(['remember_token' => $validated['remember_token']]);

    return response()->json(['message' => 'Token updated successfully']);
});
