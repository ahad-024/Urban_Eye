from rest_framework import serializers
from .models import Complaint


class ComplaintSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source="user.username")

    class Meta:
        model = Complaint

        fields = [
            "id",
            "user",
            "report",
            "title",
            "description",
            "status",
            "created_at",
            "updated_at",
        ]

        read_only_fields = [
            "id",
            "user",
            "status",
            "created_at",
            "updated_at",
        ]


class AdminComplaintSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source="user.username")

    class Meta:
        model = Complaint

        fields = [
            "id",
            "user",
            "report",
            "title",
            "description",
            "status",
            "created_at",
            "updated_at",
        ]

        read_only_fields = [
            "id",
            "user",
            "report",
            "title",
            "description",
            "created_at",
            "updated_at",
        ]