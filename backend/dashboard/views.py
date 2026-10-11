from django.contrib.auth.models import User
from django.db.models import Count
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from reports.models import Report


class DashboardStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):

        total_reports = Report.objects.count()

        resolved_reports = Report.objects.filter(
            status="resolved"
        ).count()

        pending_reports = Report.objects.filter(
            status="pending"
        ).count()

        active_users = User.objects.filter(
            is_active=True
        ).count()

        issue_counts = Report.objects.values(
            "issue_type"
        ).annotate(
            total=Count("id")
        )

        issue_statistics = {
            "garbage": 0,
            "pothole": 0,
            "road_crack": 0,
            "street_light": 0,
            "water_overflow": 0,
        }

        for item in issue_counts:
            issue_type = item["issue_type"]

            if issue_type in issue_statistics:
                issue_statistics[issue_type] = item["total"]

        return Response({
            "total_reports": total_reports,
            "resolved_reports": resolved_reports,
            "pending_reports": pending_reports,
            "active_users": active_users,
            "issue_statistics": issue_statistics,
        })