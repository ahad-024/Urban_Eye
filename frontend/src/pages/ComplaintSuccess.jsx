
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  FaCheckCircle,
  FaMapMarkerAlt,
  FaClipboardList,
  FaClock,
  FaFileAlt,
} from "react-icons/fa";

import api from "../api/axios";
import MainLayout from "../layouts/MainLayout";
import PageHeader from "../components/PageHeader";
import Card from "../components/Card";
import Badge from "../components/Badge";
import Button from "../components/Button";

const ComplaintSuccess = () => {
  const navigate = useNavigate();

  const [report, setReport] = useState(null);
  const [complaint, setComplaint] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const loadComplaintData = async () => {
      try {
        setLoading(true);
        setError("");

        const accessToken =
          localStorage.getItem("access_token");

        if (!accessToken) {
          navigate("/login");
          return;
        }

        const savedReport = JSON.parse(
          localStorage.getItem("urbaneye_last_report")
        );

        if (!savedReport?.id) {
          setError(
            "Report information could not be found."
          );
          return;
        }

        // --------------------------------
        // Get report
        // --------------------------------

        const reportResponse = await api.get(
          `reports/${savedReport.id}/`,
          {
            headers: {
              Authorization: `Bearer ${accessToken}`,
            },
          }
        );

        const reportData = reportResponse.data;

        // --------------------------------
        // Location fallback
        // --------------------------------
        // Prefer the latest value from the backend.
        // If unavailable, use the value saved after
        // report creation.

        if (
          !reportData.location_name &&
          savedReport.location_name
        ) {
          reportData.location_name =
            savedReport.location_name;
        }

        setReport(reportData);

        // --------------------------------
        // Get complaints
        // --------------------------------

        const complaintsResponse = await api.get(
          "complaints/",
          {
            headers: {
              Authorization: `Bearer ${accessToken}`,
            },
          }
        );

        const complaints =
          complaintsResponse.data;

        // --------------------------------
        // Find complaint for this report
        // --------------------------------

        const foundComplaint =
          Array.isArray(complaints)
            ? complaints.find(
                (item) =>
                  item.report === reportData.id
              )
            : null;

        setComplaint(
          foundComplaint || null
        );
      } catch (err) {
        console.error(
          "Failed to load complaint:",
          err.response?.data || err.message
        );

        if (err.response?.status === 401) {
          localStorage.removeItem(
            "access_token"
          );

          localStorage.removeItem(
            "refresh_token"
          );

          localStorage.removeItem("user");

          navigate("/login");
          return;
        }

        setError(
          "Failed to load complaint information."
        );
      } finally {
        setLoading(false);
      }
    };

    loadComplaintData();
  }, [navigate]);

  // --------------------------------
  // Loading
  // --------------------------------

  if (loading) {
    return (
      <MainLayout>
        <PageHeader
          title="Complaint Submitted"
          backTo="/home"
        />

        <Card
          maxWidth="max-w-3xl"
          className="mx-auto text-center"
        >
          <div className="py-10">
            <div className="w-12 h-12 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto" />

            <p className="text-gray-500 mt-5">
              Loading complaint details...
            </p>
          </div>
        </Card>
      </MainLayout>
    );
  }

  // --------------------------------
  // Error
  // --------------------------------

  if (error) {
    return (
      <MainLayout>
        <PageHeader
          title="Complaint Submitted"
          backTo="/home"
        />

        <Card
          maxWidth="max-w-3xl"
          className="mx-auto text-center"
        >
          <div className="py-8">
            <p className="text-red-500 mb-6">
              {error}
            </p>

            <Button
              onClick={() =>
                navigate("/home")
              }
            >
              Go to Home
            </Button>
          </div>
        </Card>
      </MainLayout>
    );
  }

  // --------------------------------
  // Format data
  // --------------------------------

  const issueType =
    report?.issue_type
      ? report.issue_type
          .split("_")
          .map(
            (word) =>
              word.charAt(0).toUpperCase() +
              word.slice(1)
          )
          .join(" ")
      : "Unknown";

  const severity =
    report?.severity
      ? report.severity.charAt(0).toUpperCase() +
        report.severity.slice(1)
      : "Unknown";

  const confidence =
    report?.confidence !== null &&
    report?.confidence !== undefined
      ? `${report.confidence}%`
      : "N/A";

  const status =
    report?.status
      ? report.status.charAt(0).toUpperCase() +
        report.status.slice(1)
      : "Pending";

  // --------------------------------
  // Readable location
  // --------------------------------

  const locationName =
    report?.location_name?.trim() ||
    "";

  const hasLocation =
    locationName !== "";

  // --------------------------------
  // Date
  // --------------------------------

  const formattedDate =
    report?.created_at
      ? new Date(
          report.created_at
        ).toLocaleString()
      : "Not available";

  return (
    <MainLayout>
      <PageHeader
        title="Complaint Submitted"
        backTo="/home"
      />

      <div className="max-w-4xl mx-auto">

        {/* Success Header */}
        <div className="bg-green-50 border border-green-200 rounded-3xl p-8 text-center mb-6">

          <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-5">
            <FaCheckCircle className="text-green-600 text-5xl" />
          </div>

          <h1 className="text-3xl font-bold text-green-700">
            Complaint Submitted Successfully
          </h1>

          <p className="text-gray-600 mt-3">
            Your civic issue has been reported to UrbanEye.
          </p>

        </div>

        {/* Complaint ID */}
        <Card className="mb-6">

          <div className="flex items-center gap-4">

            <div className="w-14 h-14 bg-blue-100 rounded-2xl flex items-center justify-center">
              <FaClipboardList className="text-blue-600 text-2xl" />
            </div>

            <div>

              <p className="text-sm text-gray-500">
                Complaint ID
              </p>

              <h2 className="text-2xl font-bold">
                {complaint?.id
                  ? `UE-${complaint.id}`
                  : `UE-${report?.id}`}
              </h2>

            </div>

          </div>

        </Card>

        {/* Report Summary */}
        <Card className="mb-6">

          <h2 className="text-xl font-bold mb-5">
            Report Summary
          </h2>

          <div className="space-y-4">

            {/* Issue */}
            <div className="flex justify-between items-center">

              <span className="text-gray-500">
                Issue Type
              </span>

              <strong>
                {issueType}
              </strong>

            </div>

            {/* Severity */}
            <div className="flex justify-between items-center">

              <span className="text-gray-500">
                Severity
              </span>

              <Badge
                type={
                  severity === "High"
                    ? "danger"
                    : severity === "Medium"
                    ? "warning"
                    : "success"
                }
              >
                {severity}
              </Badge>

            </div>

            {/* Confidence */}
            <div className="flex justify-between items-center">

              <span className="text-gray-500">
                AI Confidence
              </span>

              <Badge type="success">
                {confidence}
              </Badge>

            </div>

            {/* Status */}
            <div className="flex justify-between items-center">

              <span className="text-gray-500">
                Status
              </span>

              <Badge
                type={
                  report?.status === "resolved"
                    ? "success"
                    : "warning"
                }
              >
                {status}
              </Badge>

            </div>

            {/* Date */}
            <div className="flex justify-between items-center">

              <span className="text-gray-500">
                Submitted
              </span>

              <span className="flex items-center gap-2 font-medium">

                <FaClock className="text-blue-600" />

                {formattedDate}

              </span>

            </div>

          </div>

        </Card>

        {/* Location */}
        <Card className="mb-6">

          <div className="flex items-center gap-3 mb-5">

            <FaMapMarkerAlt className="text-red-500 text-2xl" />

            <h2 className="text-xl font-bold">
              Issue Location
            </h2>

          </div>

          {hasLocation ? (

            <div>

              {/* Location detected */}
              <div className="bg-green-50 border border-green-200 rounded-2xl p-4 mb-4">

                <div className="flex items-start gap-3">

                  <FaCheckCircle className="text-green-600 mt-1" />

                  <div>

                    <p className="font-semibold text-green-700">
                      Location detected
                    </p>

                    <p className="text-sm text-gray-500 mt-1">
                      Automatically captured when the image was analyzed.
                    </p>

                  </div>

                </div>

              </div>

              {/* Detected address */}
              <div className="bg-gray-50 border border-gray-200 rounded-2xl p-5">

                <div className="flex items-start gap-3">

                  <FaMapMarkerAlt className="text-red-500 text-xl mt-1 flex-shrink-0" />

                  <div className="min-w-0">

                    <p className="text-sm text-gray-500">
                      Detected Address
                    </p>

                    <p className="text-lg font-bold text-gray-800 mt-1 break-words">
                      {locationName}
                    </p>

                  </div>

                </div>

              </div>

            </div>

          ) : (

            <div className="bg-yellow-50 border border-yellow-200 rounded-2xl p-4">

              <p className="text-yellow-700 font-medium">
                Location address is not available for this report.
              </p>

            </div>

          )}

        </Card>

        {/* Description */}
        <Card className="mb-8">

          <div className="flex items-center gap-3 mb-4">

            <FaFileAlt className="text-blue-600 text-xl" />

            <h2 className="text-xl font-bold">
              Description
            </h2>

          </div>

          <p className="text-gray-600 leading-7 whitespace-pre-line">
            {report?.description ||
              complaint?.description ||
              "No description provided."}
          </p>

        </Card>

        {/* Actions */}
        <div className="grid md:grid-cols-2 gap-4 mb-8">

          <Button
            variant="secondary"
            onClick={() =>
              navigate("/reports")
            }
          >
            View My Reports
          </Button>

          <Button
            onClick={() =>
              navigate("/home")
            }
          >
            Back to Home
          </Button>

        </div>

      </div>
    </MainLayout>
  );
};

export default ComplaintSuccess;
