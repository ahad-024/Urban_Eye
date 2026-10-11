from django.contrib.auth.models import User
from django.db import models
from reports.models import Report


class Complaint(models.Model):

    STATUS_CHOICES = [
        ("submitted", "Submitted"),
        ("in_progress", "In Progress"),
        ("resolved", "Resolved"),
        ("rejected", "Rejected"),
    ]

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="complaints"
    )

    report = models.ForeignKey(
        Report,
        on_delete=models.CASCADE,
        related_name="complaints"
    )

    title = models.CharField(
        max_length=200
    )

    description = models.TextField()

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default="submitted"
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    updated_at = models.DateTimeField(
        auto_now=True
    )

    def __str__(self):
        return f"{self.title} - {self.user.username}"