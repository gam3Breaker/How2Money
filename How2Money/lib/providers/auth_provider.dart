import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/local_storage_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    _user = await _storage.getUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding({
    required String displayName,
    FinancialBackground? background,
  }) async {
    _user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      displayName: displayName,
      background: background,
      hasCompletedOnboarding: true,
    );

    await _storage.saveUser(_user!);
    await _storage.setOnboardingCompleted(true);
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    await _storage.saveUser(_user!);
    notifyListeners();
  }

  Future<void> setPremium(bool isPremium) async {
    if (_user != null) {
      _user = _user!.copyWith(isPremium: isPremium);
      await _storage.saveUser(_user!);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    await _storage.clearAll();
    notifyListeners();
  }
}


