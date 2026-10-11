from django.contrib.auth.models import User
from rest_framework import serializers
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.serializers import TokenBlacklistSerializer


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ["username", "email", "password"]

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data["username"],
            email=validated_data["email"],
            password=validated_data["password"],
        )

        return user


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username", "email"]
        read_only_fields = ["id"]

    def validate_email(self, value):
        user = self.instance

        if User.objects.filter(
            email__iexact=value
        ).exclude(id=user.id).exists():
            raise serializers.ValidationError(
                "This email is already registered."
            )

        return value


class EmailLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(
        write_only=True
    )

    def validate(self, attrs):
        email = attrs["email"]
        password = attrs["password"]

        try:
            user = User.objects.get(
                email__iexact=email
            )
        except User.DoesNotExist:
            raise AuthenticationFailed(
                "No active account found with the given credentials"
            )

        if not user.check_password(password):
            raise AuthenticationFailed(
                "No active account found with the given credentials"
            )

        if not user.is_active:
            raise AuthenticationFailed(
                "This account is inactive."
            )

        refresh = RefreshToken.for_user(user)

        return {
            "refresh": str(refresh),
            "access": str(refresh.access_token),
        }


class LogoutSerializer(TokenBlacklistSerializer):
    pass


class AdminLoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(
        write_only=True
    )

    def validate(self, attrs):
        email = attrs["email"]
        password = attrs["password"]

        try:
            user = User.objects.get(
                email__iexact=email
            )
        except User.DoesNotExist:
            raise AuthenticationFailed(
                "Invalid admin credentials."
            )

        if not user.check_password(password):
            raise AuthenticationFailed(
                "Invalid admin credentials."
            )

        if not user.is_active:
            raise AuthenticationFailed(
                "This account is inactive."
            )

        if not user.is_staff:
            raise AuthenticationFailed(
                "You do not have administrator access."
            )

        refresh = RefreshToken.for_user(user)

        return {
            "refresh": str(refresh),
            "access": str(refresh.access_token),
            "user": {
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "is_staff": user.is_staff,
                "is_superuser": user.is_superuser,
            },
        }
