import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class AppState extends ChangeNotifier {
  AppUser? currentUser;
  bool isLoading = false;
  String? error;

  bool get isLoggedIn => currentUser != null;
  bool get isDeveloper => currentUser?.isDeveloper ?? false;
  bool get isOrganizer => currentUser?.isOrganizer ?? false;
  bool get isCaptain => currentUser?.isCaptain ?? false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid != null) {
      currentUser = await FirebaseService.getUser(uid);
      notifyListeners();
    }
  }

  Future<String?> login(String username, String password) async {
    isLoading = true; error = null; notifyListeners();
    try {
      // Use email-style login with Firebase Auth
      final email = '$username@cricket-a7.app';
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      currentUser = await FirebaseService.getUser(uid);
      if (currentUser == null) {
        // Create user record if doesn't exist
        currentUser = AppUser(id: uid, username: username, role: 'viewer');
        await FirebaseService.createUser(currentUser!);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);
      isLoading = false; notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      error = e.toString().contains('wrong-password') ? 'Wrong password'
          : e.toString().contains('user-not-found') ? 'User not found'
          : 'Login failed';
      notifyListeners();
      return error;
    }
  }

  Future<String?> register(String username, String password, String role) async {
    isLoading = true; error = null; notifyListeners();
    try {
      final email = '$username@cricket-a7.app';
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;
      currentUser = AppUser(id: uid, username: username, role: role);
      await FirebaseService.createUser(currentUser!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);
      isLoading = false; notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      error = e.toString().contains('email-already-in-use') ? 'Username taken' : 'Register failed';
      notifyListeners();
      return error;
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    currentUser = null;
    notifyListeners();
  }

  // Check if user can score a specific match (scoped to own team only)
  bool canScoreMatch(CricketMatch match) {
    if (isDeveloper || isOrganizer) return true;
    if (isCaptain && currentUser?.teamId != null) {
      return match.team1Id == currentUser!.teamId ||
             match.team2Id == currentUser!.teamId;
    }
    return false;
  }
}
