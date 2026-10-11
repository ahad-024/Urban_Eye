
from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .ai_service import analyze_image
from .models import Report
from .serializers import ReportSerializer, AdminReportSerializer
from .permissions import IsAdminUser
from .geocoding import get_location_name


class ReportListCreateView(generics.ListCreateAPIView):
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = Report.objects.filter(
            user=self.request.user
        ).order_by("-created_at")

        search = self.request.query_params.get("search")
        status = self.request.query_params.get("status")
        issue_type = self.request.query_params.get("issue_type")

        if search:
            queryset = queryset.filter(
                description__icontains=search
            )

        if status:
            queryset = queryset.filter(
                status=status
            )

        if issue_type:
            queryset = queryset.filter(
                issue_type=issue_type
            )

        return queryset

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class ReportDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Report.objects.filter(
            user=self.request.user
        )


class AIAnalysisView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        # --------------------------------
        # Get image
        # --------------------------------

        image = request.FILES.get("image")

        if not image:
            return Response(
                {"error": "Image is required."},
                status=400
            )

        # --------------------------------
        # Get GPS coordinates
        # --------------------------------

        latitude = request.data.get("latitude")
        longitude = request.data.get("longitude")

        # --------------------------------
        # Validate latitude
        # --------------------------------

        if latitude is None or latitude == "":
            return Response(
                {"error": "Latitude is required."},
                status=400
            )

        try:
            latitude = float(latitude)

        except (TypeError, ValueError):
            return Response(
                {"error": "Latitude must be a number."},
                status=400
            )

        if latitude < -90 or latitude > 90:
            return Response(
                {"error": "Latitude must be between -90 and 90."},
                status=400
            )

        # --------------------------------
        # Validate longitude
        # --------------------------------

        if longitude is None or longitude == "":
            return Response(
                {"error": "Longitude is required."},
                status=400
            )

        try:
            longitude = float(longitude)

        except (TypeError, ValueError):
            return Response(
                {"error": "Longitude must be a number."},
                status=400
            )

        if longitude < -180 or longitude > 180:
            return Response(
                {"error": "Longitude must be between -180 and 180."},
                status=400
            )

        # --------------------------------
        # AI image analysis
        # --------------------------------

        result = analyze_image(image)

        # --------------------------------
        # Reverse geocode location
        # --------------------------------

        location_name = get_location_name(
            latitude,
            longitude
        )

        # --------------------------------
        # Add location information
        # --------------------------------
        # AI result is preserved.
        # We only add the readable address.

        result["location_name"] = location_name

        # Also return coordinates internally
        # for the next frontend screen.

        result["latitude"] = latitude
        result["longitude"] = longitude

        return Response(result)


class AnalyzeAndCreateReportView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        image = request.FILES.get("image")
        description = request.data.get("description", "")

        issue_type = request.data.get("issue_type")
        severity = request.data.get("severity")
        confidence = request.data.get("confidence")

        # --------------------------------
        # Get GPS coordinates
        # --------------------------------

        latitude = request.data.get("latitude")
        longitude = request.data.get("longitude")

        # --------------------------------
        # Validate image
        # --------------------------------

        if not image:
            return Response(
                {"error": "Image is required."},
                status=400
            )

        # --------------------------------
        # Validate issue type
        # --------------------------------

        if not issue_type:
            return Response(
                {"error": "Issue type is required."},
                status=400
            )

        # --------------------------------
        # Validate severity
        # --------------------------------

        if not severity:
            return Response(
                {"error": "Severity is required."},
                status=400
            )

        # --------------------------------
        # Validate confidence
        # --------------------------------

        if confidence is None:
            return Response(
                {"error": "Confidence is required."},
                status=400
            )

        # --------------------------------
        # Validate issue type
        # --------------------------------

        valid_issue_types = dict(
            Report.ISSUE_TYPE_CHOICES
        ).keys()

        if issue_type not in valid_issue_types:
            return Response(
                {"error": "Invalid issue type."},
                status=400
            )

        # --------------------------------
        # Validate severity
        # --------------------------------

        valid_severities = dict(
            Report.SEVERITY_CHOICES
        ).keys()

        if severity not in valid_severities:
            return Response(
                {"error": "Invalid severity."},
                status=400
            )

        # --------------------------------
        # Convert confidence
        # --------------------------------

        try:
            confidence = float(confidence)

        except (TypeError, ValueError):
            return Response(
                {"error": "Confidence must be a number."},
                status=400
            )

        # --------------------------------
        # Validate latitude
        # --------------------------------

        if latitude is None or latitude == "":
            return Response(
                {"error": "Latitude is required."},
                status=400
            )

        try:
            latitude = float(latitude)

        except (TypeError, ValueError):
            return Response(
                {"error": "Latitude must be a number."},
                status=400
            )

        if latitude < -90 or latitude > 90:
            return Response(
                {"error": "Latitude must be between -90 and 90."},
                status=400
            )

        # --------------------------------
        # Validate longitude
        # --------------------------------

        if longitude is None or longitude == "":
            return Response(
                {"error": "Longitude is required."},
                status=400
            )

        try:
            longitude = float(longitude)

        except (TypeError, ValueError):
            return Response(
                {"error": "Longitude must be a number."},
                status=400
            )

        if longitude < -180 or longitude > 180:
            return Response(
                {"error": "Longitude must be between -180 and 180."},
                status=400
            )

        # --------------------------------
        # Reverse geocode GPS coordinates
        # --------------------------------

        location_name = get_location_name(
            latitude,
            longitude
        )

        # --------------------------------
        # Create report
        # --------------------------------

        report = Report.objects.create(
            user=request.user,
            issue_type=issue_type,
            severity=severity,
            confidence=confidence,
            image=image,
            description=description,
            latitude=latitude,
            longitude=longitude,
            location_name=location_name,
        )

        # --------------------------------
        # Return created report
        # --------------------------------

        serializer = ReportSerializer(report)

        return Response(
            serializer.data,
            status=201
        )


class AdminReportListView(generics.ListAPIView):
    """
    Returns all reports to administrator users.
    """

    serializer_class = ReportSerializer
    permission_classes = [IsAdminUser]

    def get_queryset(self):
        return Report.objects.all().order_by("-created_at")


class AdminReportDetailView(generics.RetrieveUpdateAPIView):
    """
    Allows administrator users to view and update any report.
    """

    serializer_class = AdminReportSerializer
    permission_classes = [IsAdminUser]

    def get_queryset(self):
        return Report.objects.all()