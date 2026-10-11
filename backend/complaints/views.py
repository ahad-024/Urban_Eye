from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from reports.permissions import IsAdminUser
from .models import Complaint
from .serializers import (ComplaintSerializer,AdminComplaintSerializer)


class ComplaintListCreateView(generics.ListCreateAPIView):
    serializer_class = ComplaintSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Complaint.objects.filter(
            user=self.request.user
        ).order_by("-created_at")

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class ComplaintDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ComplaintSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Complaint.objects.filter(
            user=self.request.user
        )

    def perform_update(self, serializer):
        serializer.save(
            status=self.get_object().status
        )


class AdminComplaintListView(generics.ListAPIView):
    """
    Returns all complaints to administrator users.
    """

    serializer_class = AdminComplaintSerializer
    permission_classes = [IsAdminUser]

    def get_queryset(self):
        return Complaint.objects.all().order_by("-created_at")


class AdminComplaintDetailView(generics.RetrieveUpdateAPIView):
    """
    Allows administrator users to view and update complaints.
    """

    serializer_class = AdminComplaintSerializer
    permission_classes = [IsAdminUser]

    def get_queryset(self):
        return Complaint.objects.all()