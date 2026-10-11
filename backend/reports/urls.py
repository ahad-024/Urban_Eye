from django.urls import path
from .views import (ReportListCreateView,ReportDetailView,AIAnalysisView,AnalyzeAndCreateReportView,AdminReportListView,AdminReportDetailView)


urlpatterns = [
    path(
        "",
        ReportListCreateView.as_view(),
        name="report-list-create",
    ),

    path(
        "admin/",
        AdminReportListView.as_view(),
        name="admin-report-list",
    ),

    path(
        "admin/<int:pk>/",
        AdminReportDetailView.as_view(),
        name="admin-report-detail",
    ),

    path(
        "analyze/",
        AIAnalysisView.as_view(),
        name="ai-analysis",
    ),

    path(
        "analyze-and-create/",
        AnalyzeAndCreateReportView.as_view(),
        name="analyze-and-create",
    ),

    path(
        "<int:pk>/",
        ReportDetailView.as_view(),
        name="report-detail",
    ),
]
