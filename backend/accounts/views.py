from django.contrib.auth.models import User
from rest_framework import generics
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenBlacklistView

from reports.permissions import IsAdminUser

from .serializers import (
    RegisterSerializer,
    UserProfileSerializer,
    EmailLoginSerializer,
    AdminLoginSerializer,
)


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer
    permission_classes = [AllowAny]


class EmailLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = EmailLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response(serializer.validated_data)


class AdminLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = AdminLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response(serializer.validated_data)


class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class AdminUsersView(APIView):
    """Return registered accounts to authenticated staff users only."""

    permission_classes = [IsAdminUser]

    def get(self, request):
        users = User.objects.order_by("-date_joined")

        results = [
            {
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "is_staff": user.is_staff,
                "is_active": user.is_active,
                "date_joined": user.date_joined.isoformat(),
            }
            for user in users
        ]

        return Response({"users": results})


class LogoutView(TokenBlacklistView):
    pass
