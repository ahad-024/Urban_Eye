from django.contrib import admin
from django.utils.html import format_html
from .models import Report


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "user",
        "issue_type",
        "severity",
        "confidence",
        "status",
        "image_preview",
        "created_at",
    )

    list_filter = (
        "issue_type",
        "severity",
        "status",
        "created_at",
    )

    search_fields = (
        "user__username",
        "description",
    )

    readonly_fields = (
        "user",
        "confidence",
        "created_at",
        "image_preview",
    )

    ordering = (
        "-created_at",
    )

    def image_preview(self, obj):
        if obj.image:
            return format_html(
                '<img src="{}" width="100" height="70" '
                'style="object-fit: cover; border-radius: 6px;" />',
                obj.image.url,
            )

        return "No image"

    image_preview.short_description = "Image"
