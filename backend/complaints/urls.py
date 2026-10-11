from django.urls import path
from .views import (ComplaintListCreateView,ComplaintDetailView,AdminComplaintListView,AdminComplaintDetailView)


urlpatterns = [
    path(
        "",
        ComplaintListCreateView.as_view(),
        name="complaint-list-create",
    ),

    path(
        "admin/",
        AdminComplaintListView.as_view(),
        name="admin-complaint-list",
    ),

    path(
        "admin/<int:pk>/",
        AdminComplaintDetailView.as_view(),
        name="admin-complaint-detail",
    ),

    path(
        "<int:pk>/",
        ComplaintDetailView.as_view(),
        name="complaint-detail",
    ),
]