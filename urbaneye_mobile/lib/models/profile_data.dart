import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';

class ProfileData extends ChangeNotifier {
  ProfileData._();

  static final ProfileData instance = ProfileData._();

  String _name = 'Ahad Ali';
  String _email = 'ahadali@email.com';

  bool _isLoading = false;
  String? _errorMessage;

  String get name => _name;
  String get email => _email;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateProfile({
    required String name,
    required String email,
  }) {
    _name = name;
    _email = email;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await ApiClient.getProfile();

      final username = profile['username']?.toString();
      final email = profile['email']?.toString();

      updateProfile(
        name: username != null && username.isNotEmpty
            ? username
            : _name,
        email: email != null && email.isNotEmpty
            ? email
            : _email,
      );
    } catch (error) {
      _errorMessage = error is ApiException
          ? error.message
          : 'Unable to load your profile. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
