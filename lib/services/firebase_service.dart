import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class FirebaseService {
  static final _db = FirebaseDatabase.instance;
  static const _uuid = Uuid();

  // ── Refs ─────────────────────────────────────────────────────────────────
  static DatabaseReference get _matches  => _db.ref('matches');
  static DatabaseReference get _teams    => _db.ref('teams');
  static DatabaseReference get _players  => _db.ref('players');
  static DatabaseReference get _tourns   => _db.ref('tournaments');
  static DatabaseReference get _innings  => _db.ref('innings');
  static DatabaseReference get _balls    => _db.ref('balls');
  static DatabaseReference get _users    => _db.ref('users');

  // ── Helpers ───────────────────────────────────────────────────────────────
  static String newId() => _uuid.v4().replaceAll('-','').substring(0,16);

  static Map<String,dynamic> _snap(DataSnapshot s) =>
      s.exists ? Map<String,dynamic>.from(s.value as Map) : {};

  // ── Tournaments ───────────────────────────────────────────────────────────
  static Future<List<Tournament>> getTournaments() async {
    final s = await _tourns.get();
    if (!s.exists) return [];
    final map = Map<String,dynamic>.from(s.value as Map);
    return map.entries.map((e) {
      final d = Map<String,dynamic>.from(e.value as Map);
      return Tournament.fromMap(e.key, d);
    }).toList();
  }

  static Future<String> createTournament(Tournament t) async {
    final id = newId();
    await _tourns.child(id).set(t.toMap());
    return id;
  }

  // ── Teams ─────────────────────────────────────────────────────────────────
  static Future<List<CricketTeam>> getTeams({String? tournamentId}) async {
    final s = await _teams.get();
    if (!s.exists) return [];
    final map = Map<String,dynamic>.from(s.value as Map);
    return map.entries
      .map((e) => CricketTeam.fromMap(e.key, Map<String,dynamic>.from(e.value as Map)))
      .where((t) => tournamentId == null || t.tournamentId == tournamentId)
      .toList();
  }

  static Future<CricketTeam?> getTeam(String id) async {
    final s = await _teams.child(id).get();
    if (!s.exists) return null;
    return CricketTeam.fromMap(id, _snap(s));
  }

  static Future<String> createTeam(CricketTeam t) async {
    final id = newId();
    await _teams.child(id).set(t.toMap());
    return id;
  }

  // ── Players ───────────────────────────────────────────────────────────────
  static Future<List<Player>> getPlayers(String teamId) async {
    final s = await _players.orderByChild('team_id').equalTo(teamId).get();
    if (!s.exists) return [];
    final map = Map<String,dynamic>.from(s.value as Map);
    return map.entries
      .map((e) => Player.fromMap(e.key, Map<String,dynamic>.from(e.value as Map)))
      .toList();
  }

  static Future<String> addPlayer(Player p) async {
    final id = newId();
    await _players.child(id).set(p.toMap());
    return id;
  }

  // ── Matches ───────────────────────────────────────────────────────────────
  static Future<List<CricketMatch>> getMatches({String? tournamentId}) async {
    final s = await _matches.get();
    if (!s.exists) return [];
    final map = Map<String,dynamic>.from(s.value as Map);
    return map.entries
      .map((e) => CricketMatch.fromMap(e.key, Map<String,dynamic>.from(e.value as Map)))
      .where((m) => tournamentId == null || m.tournamentId == tournamentId)
      .toList();
  }

  static Future<CricketMatch?> getMatch(String id) async {
    final s = await _matches.child(id).get();
    if (!s.exists) return null;
    return CricketMatch.fromMap(id, _snap(s));
  }

  static Future<String> createMatch(CricketMatch m) async {
    final id = newId();
    await _matches.child(id).set(m.toMap());
    return id;
  }

  static Future<void> updateMatch(String id, Map<String,dynamic> data) async {
    await _matches.child(id).update(data);
  }

  // ── Innings ───────────────────────────────────────────────────────────────
  static Future<Innings?> getInnings(String id) async {
    final s = await _innings.child(id).get();
    if (!s.exists) return null;
    return Innings.fromMap(id, _snap(s));
  }

  static Future<String> createInnings(Innings inn) async {
    final id = newId();
    await _innings.child(id).set(inn.toMap());
    // Link to match
    await _matches.child(inn.matchId).child('innings_ids').child(id).set(true);
    return id;
  }

  static Future<void> updateInnings(String id, Map<String,dynamic> data) async {
    await _innings.child(id).update(data);
  }

  // ── Balls (Event Ledger) ──────────────────────────────────────────────────
  static Future<String> recordBall(BallEvent ball) async {
    final id = newId();
    await _balls.child(ball.inningsId).child(id).set(ball.toMap());
    return id;
  }

  static Future<void> deleteBall(String inningsId, String ballId) async {
    await _balls.child(inningsId).child(ballId).remove();
  }

  static Future<List<BallEvent>> getBalls(String inningsId) async {
    final s = await _balls.child(inningsId).orderByChild('timestamp').get();
    if (!s.exists) return [];
    final map = Map<String,dynamic>.from(s.value as Map);
    return map.entries
      .map((e) => BallEvent.fromMap(e.key, inningsId, Map<String,dynamic>.from(e.value as Map)))
      .toList()
      ..sort((a,b) => a.timestamp.compareTo(b.timestamp));
  }

  // ── Realtime stream for live scoring ──────────────────────────────────────
  static Stream<List<BallEvent>> ballStream(String inningsId) {
    return _balls.child(inningsId).orderByChild('timestamp').onValue.map((event) {
      if (!event.snapshot.exists) return [];
      final map = Map<String,dynamic>.from(event.snapshot.value as Map);
      return map.entries
        .map((e) => BallEvent.fromMap(e.key, inningsId, Map<String,dynamic>.from(e.value as Map)))
        .toList()
        ..sort((a,b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  static Stream<CricketMatch?> matchStream(String matchId) {
    return _matches.child(matchId).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return CricketMatch.fromMap(matchId, _snap(event.snapshot));
    });
  }

  // ── Users ─────────────────────────────────────────────────────────────────
  static Future<AppUser?> getUser(String uid) async {
    final s = await _users.child(uid).get();
    if (!s.exists) return null;
    return AppUser.fromMap(uid, _snap(s));
  }

  static Future<void> createUser(AppUser u) async {
    await _users.child(u.id).set(u.toMap());
  }

  static Future<void> updateUser(String uid, Map<String,dynamic> data) async {
    await _users.child(uid).update(data);
  }

  static Future<List<AppUser>> getAllUsers() async {
    final s = await _users.get();
    if (!s.exists) return [];
    final map = Map<String,dynamic>.from(s.value as Map);
    return map.entries
      .map((e) => AppUser.fromMap(e.key, Map<String,dynamic>.from(e.value as Map)))
      .toList();
  }
}
