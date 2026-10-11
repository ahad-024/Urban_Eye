from django.contrib import admin
from .models import Complaint


@admin.register(Complaint)
class ComplaintAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "title",
        "user",
        "report",
        "status",
        "created_at",
        "updated_at",
    )

    list_filter = (
        "status",
        "created_at",
        "updated_at",
    )

    search_fields = (
        "title",
        "description",
        "user__username",
    )

    readonly_fields = (
        "user",
        "report",
        "created_at",
        "updated_at",
    )

    ordering = (
        "-created_at",
    )