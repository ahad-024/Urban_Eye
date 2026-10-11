
from django.contrib.auth.models import User
from django.db import models


class Report(models.Model):

    ISSUE_TYPE_CHOICES = [
        ("garbage", "Garbage"),
        ("pothole", "Pothole"),
        ("road_crack", "Road Crack"),
        ("street_light", "Street Light"),
        ("water_overflow", "Water Overflow"),
    ]

    SEVERITY_CHOICES = [
        ("low", "Low"),
        ("medium", "Medium"),
        ("high", "High"),
    ]

    STATUS_CHOICES = [
        ("pending", "Pending"),
        ("resolved", "Resolved"),
    ]

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="reports"
    )

    issue_type = models.CharField(
        max_length=50,
        choices=ISSUE_TYPE_CHOICES
    )

    severity = models.CharField(
        max_length=20,
        choices=SEVERITY_CHOICES
    )

    confidence = models.FloatField(
        null=True,
        blank=True
    )

    image = models.ImageField(
        upload_to="reports/"
    )

    description = models.TextField(
        blank=True
    )

    latitude = models.FloatField(
        null=True,
        blank=True
    )

    longitude = models.FloatField(
        null=True,
        blank=True
    )

    location_name = models.CharField(
        max_length=500,
        blank=True,
        default=""
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default="pending"
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    def __str__(self):
        return f"{self.issue_type} - {self.user.username}"

