
from rest_framework import serializers

from .models import Report


class ReportSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(
        source="user.username"
    )

    class Meta:
        model = Report

        fields = [
            "id",
            "user",
            "issue_type",
            "severity",
            "confidence",
            "image",
            "description",
            "latitude",
            "longitude",
            "location_name",
            "status",
            "created_at",
        ]

        read_only_fields = [
            "id",
            "user",
            "confidence",
            "location_name",
            "status",
            "created_at",
        ]


class AdminReportSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(
        source="user.username"
    )

    class Meta:
        model = Report

        fields = [
            "id",
            "user",
            "issue_type",
            "severity",
            "confidence",
            "image",
            "description",
            "latitude",
            "longitude",
            "location_name",
            "status",
            "created_at",
        ]

        read_only_fields = [
            "id",
            "user",
            "issue_type",
            "severity",
            "confidence",
            "image",
            "description",
            "latitude",
            "longitude",
            "location_name",
            "created_at",
        ]
