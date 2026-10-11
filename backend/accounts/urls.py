from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import (
    RegisterView,
    EmailLoginView,
    AdminLoginView,
    ProfileView,
    AdminUsersView,
    LogoutView,
)

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("login/", EmailLoginView.as_view(), name="login"),
    path("admin-login/", AdminLoginView.as_view(), name="admin-login"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("profile/", ProfileView.as_view(), name="profile"),
    path("admin/users/", AdminUsersView.as_view(), name="admin-users"),
    path("logout/", LogoutView.as_view(), name="logout"),
]
