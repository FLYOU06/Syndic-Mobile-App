import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  ApiService
//
//  Covers every call made by assembly_dashboard_screen.dart:
//    • getAssemblees()          → GET  /api/assemblees
//    • createAssemblee(body)    → POST /api/assemblees
//    • updateAssemblee(id,body) → PUT  /api/assemblees/:id
//    • sendNotification(body)   → POST /api/notifications/send
//
//  Plus all other app endpoints (auth, habitants, charges, etc.)
// ─────────────────────────────────────────────────────────────────────────────

class ApiService {
  // ── Base URL — change to your server IP/domain ──────────────────────────
  static const String _baseUrl = 'http://192.168.1.100:3000/api';
  // For Android emulator use: 'http://10.0.2.2:3000/api'
  // For iOS simulator  use:   'http://127.0.0.1:3000/api'

  // ── Token management ────────────────────────────────────────────────────
  static String? _token;

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ── Common headers ───────────────────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Generic request helpers ──────────────────────────────────────────────
  static Future<dynamic> _get(String path) async {
    final headers = await _headers();
    final response = await http.get(Uri.parse('$_baseUrl$path'), headers: headers);
    return _handle(response);
  }

  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    final response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<dynamic> _delete(String path) async {
    final headers = await _headers();
    final response = await http.delete(Uri.parse('$_baseUrl$path'), headers: headers);
    return _handle(response);
  }

  static dynamic _handle(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final message = decoded['message'] ?? 'Erreur serveur (${response.statusCode})';
    throw Exception(message);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  AUTH
  // ══════════════════════════════════════════════════════════════════════════

  /// Login — returns { success, token, user: { id, email, role, profile } }
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _post('/auth/login', {'email': email, 'password': password});
    if (data['token'] != null) await setToken(data['token']);
    return data;
  }

  /// Current user + profile
  static Future<Map<String, dynamic>> getMe() async => await _get('/auth/me');

  /// Change password
  static Future<void> changePassword(String currentPassword, String newPassword) async {
    await _put('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  static Future<void> logout() async => await clearToken();

  // ══════════════════════════════════════════════════════════════════════════
  //  ASSEMBLÉES GÉNÉRALES
  //  Used by: assembly_dashboard_screen.dart
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /api/assemblees
  /// Flutter reads: data is List ? data : (data['assemblees'] ?? data['data'] ?? [])
  /// Each assemblee has: id, titre, type, date, heure, lieu, statut,
  ///                     ordreDuJour (List), presents, absents, procurations, pvGenere
  static Future<dynamic> getAssemblees() async => await _get('/assemblees');

  /// GET /api/assemblees/:id
  static Future<Map<String, dynamic>> getAssembleeById(int id) async =>
      await _get('/assemblees/$id');

  /// POST /api/assemblees
  /// Flutter body (_buildAssembleeBody()):
  ///   { titre, type, date (ISO), heure, lieu,
  ///     ordreDuJour: [{titre, description}], statut }
  /// Returns { success, data: { id, ... }, assemblee: { id, ... } }
  static Future<Map<String, dynamic>> createAssemblee(Map<String, dynamic> body) async =>
      await _post('/assemblees', body);

  /// PUT /api/assemblees/:id
  /// Flutter sends same body + optional: presents, absents, procurations, pvGenere
  /// Returns { success, data: { id, ... }, assemblee: { id, ... } }
  static Future<Map<String, dynamic>> updateAssemblee(
      int id, Map<String, dynamic> body) async =>
      await _put('/assemblees/$id', body);

  /// DELETE /api/assemblees/:id
  static Future<void> deleteAssemblee(int id) async => await _delete('/assemblees/$id');

  // ══════════════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS
  //  Used by: assembly_dashboard_screen.dart (convocation + PV)
  // ══════════════════════════════════════════════════════════════════════════

  /// POST /api/notifications/send
  /// Flutter convocation body:
  ///   { titre, message, type: "convocation_ag", assemblee_id }
  /// Flutter PV body:
  ///   { titre, message, type: "pv_ag", assemblee_id }
  /// Backend resolves immeubleId from assemblee_id automatically.
  static Future<Map<String, dynamic>> sendNotification(
      Map<String, dynamic> body) async =>
      await _post('/notifications/send', body);

  /// GET /api/notifications  (own notifications)
  /// Returns { success, data: [...], unreadCount }
  static Future<Map<String, dynamic>> getNotifications({bool? isRead}) async {
    final query = isRead != null ? '?isRead=$isRead' : '';
    return await _get('/notifications$query');
  }

  /// PUT /api/notifications/:id/read
  static Future<void> markNotificationAsRead(int id) async =>
      await _put('/notifications/$id/read', {});

  /// PUT /api/notifications/read-all
  static Future<void> markAllNotificationsAsRead() async =>
      await _put('/notifications/read-all', {});

  // ══════════════════════════════════════════════════════════════════════════
  //  HABITANTS
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /api/habitants  — syndic lists all residents
  /// Optional filters: ?type=proprietaire|locataire&immeubleId=1
  static Future<Map<String, dynamic>> getHabitants({String? type, int? immeubleId}) async {
    final params = <String>[];
    if (type != null)       params.add('type=$type');
    if (immeubleId != null) params.add('immeubleId=$immeubleId');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return await _get('/habitants$query');
  }

  /// GET /api/habitants/:id
  static Future<Map<String, dynamic>> getHabitantById(int id) async =>
      await _get('/habitants/$id');

  /// GET /api/habitants/profile/me  — habitant views own profile
  static Future<Map<String, dynamic>> getMyProfile() async =>
      await _get('/habitants/profile/me');

  /// POST /api/habitants  — syndic creates a resident
  /// body: { email, type, nom, prenom, telephone, immeubleId,
  ///         appartement, password (optional), sendEmail (bool) }
  /// Returns { success, data, credentials: { email, password } }
  static Future<Map<String, dynamic>> createHabitant(Map<String, dynamic> body) async =>
      await _post('/habitants', body);

  /// PUT /api/habitants/:id
  static Future<Map<String, dynamic>> updateHabitant(
      int id, Map<String, dynamic> body) async =>
      await _put('/habitants/$id', body);

  /// DELETE /api/habitants/:id
  static Future<void> deleteHabitant(int id) async => await _delete('/habitants/$id');

  /// PUT /api/habitants/:id/reset-password
  /// body: { newPassword (optional), sendEmail (bool) }
  static Future<Map<String, dynamic>> resetHabitantPassword(
      int id, {String? newPassword, bool sendEmail = false}) async =>
      await _put('/habitants/$id/reset-password', {
        if (newPassword != null) 'newPassword': newPassword,
        'sendEmail': sendEmail,
      });

  // ══════════════════════════════════════════════════════════════════════════
  //  CHARGES
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /api/charges
  static Future<Map<String, dynamic>> getCharges({
    String? statut, int? immeubleId, int page = 1, int limit = 20,
  }) async {
    final params = <String>['page=$page', 'limit=$limit'];
    if (statut != null)     params.add('statut=$statut');
    if (immeubleId != null) params.add('immeubleId=$immeubleId');
    return await _get('/charges?${params.join('&')}');
  }

  /// GET /api/charges/:id  — full detail with per-resident breakdown
  static Future<Map<String, dynamic>> getChargeById(int id) async =>
      await _get('/charges/$id');

  /// POST /api/charges  — auto-assigns to all habitants in the building
  /// body: { immeubleId, nom, description, montantTotal, dateEcheance, type }
  static Future<Map<String, dynamic>> createCharge(Map<String, dynamic> body) async =>
      await _post('/charges', body);

  /// PUT /api/charges/:id
  static Future<Map<String, dynamic>> updateCharge(
      int id, Map<String, dynamic> body) async =>
      await _put('/charges/$id', body);

  /// DELETE /api/charges/:id
  static Future<void> deleteCharge(int id) async => await _delete('/charges/$id');

  /// POST /api/charges/:id/paiement  — record payment for one habitant
  /// body: { habitantId, montantPaye, modePaiement, reference }
  static Future<Map<String, dynamic>> recordPaiement(
      int chargeId, Map<String, dynamic> body) async =>
      await _post('/charges/$chargeId/paiement', body);

  /// POST /api/charges/:id/notify-unpaid  — notify all unpaid habitants
  static Future<Map<String, dynamic>> notifyUnpaid(int chargeId) async =>
      await _post('/charges/$chargeId/notify-unpaid', {});

  /// GET /api/charges/impayes/dashboard
  static Future<Map<String, dynamic>> getImpayesDashboard() async =>
      await _get('/charges/impayes/dashboard');

  // ══════════════════════════════════════════════════════════════════════════
  //  IMMEUBLES
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getImmeubles() async => await _get('/immeubles');

  static Future<Map<String, dynamic>> getImmeubleById(int id) async =>
      await _get('/immeubles/$id');

  static Future<Map<String, dynamic>> createImmeuble(Map<String, dynamic> body) async =>
      await _post('/immeubles', body);

  static Future<Map<String, dynamic>> updateImmeuble(
      int id, Map<String, dynamic> body) async =>
      await _put('/immeubles/$id', body);

  static Future<void> deleteImmeuble(int id) async => await _delete('/immeubles/$id');

  // ══════════════════════════════════════════════════════════════════════════
  //  RAPPORTS
  // ══════════════════════════════════════════════════════════════════════════

  /// GET /api/rapports/financier?immeubleId=1&dateDebut=2026-01-01&dateFin=2026-12-31
  static Future<Map<String, dynamic>> getRapportFinancier({
    int? immeubleId, String? dateDebut, String? dateFin,
  }) async {
    final params = <String>[];
    if (immeubleId != null) params.add('immeubleId=$immeubleId');
    if (dateDebut  != null) params.add('dateDebut=$dateDebut');
    if (dateFin    != null) params.add('dateFin=$dateFin');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return await _get('/rapports/financier$query');
  }

  /// GET /api/rapports/impayes
  static Future<Map<String, dynamic>> getRapportImpayes({int? immeubleId}) async {
    final query = immeubleId != null ? '?immeubleId=$immeubleId' : '';
    return await _get('/rapports/impayes$query');
  }
}
