class ApiConfig {
// Flutter Web running in Chrome on the same computer as Django
static const String baseUrl = 'http://127.0.0.1:8000';

// Django REST API endpoints
static const String login = '/api/accounts/login/';
static const String register = '/api/accounts/register/';
static const String refresh = '/api/accounts/token/refresh/';
static const String profile = '/api/accounts/profile/';
}
