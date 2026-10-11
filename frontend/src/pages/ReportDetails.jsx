
import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import {
  FaArrowLeft,
  FaMapMarkerAlt,
  FaCalendarAlt,
  FaBrain,
  FaFileAlt,
  FaCheckCircle,
  FaClock,
  FaImage,
} from "react-icons/fa";

import api from "../api/axios";
import MainLayout from "../layouts/MainLayout";
import PageHeader from "../components/PageHeader";
import Card from "../components/Card";
import Badge from "../components/Badge";
import Button from "../components/Button";

const ReportDetails = () => {
  const navigate = useNavigate();
  const { id } = useParams();

  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const loadReport = async () => {
      try {
        setLoading(true);
        setError("");

        const accessToken =
          localStorage.getItem("access_token");

        if (!accessToken) {
          navigate("/login");
          return;
        }

        const response = await api.get(
          `reports/${id}/`,
          {
            headers: {
              Authorization:
                `Bearer ${accessToken}`,
            },
          }
        );

        setReport(response.data);
      } catch (err) {
        console.error(
          "Failed to load report:",
          err.response?.data ||
            err.message
        );

        if (
          err.response?.status === 401
        ) {
          localStorage.removeItem(
            "access_token"
          );

          localStorage.removeItem(
            "refresh_token"
          );

          localStorage.removeItem(
            "user"
          );

          navigate("/login");
          return;
        }

        if (
          err.response?.status === 404
        ) {
          setError(
            "Report not found."
          );
          return;
        }

        setError(
          "Failed to load report details."
        );
      } finally {
        setLoading(false);
      }
    };

    loadReport();
  }, [id, navigate]);

  // --------------------------------
  // Format issue type
  // --------------------------------

  const formatIssueType = (value) => {
    if (!value) return "Unknown";

    return value
      .split("_")
      .map(
        (word) =>
          word.charAt(0).toUpperCase() +
          word.slice(1)
      )
      .join(" ");
  };

  // --------------------------------
  // Format severity
  // --------------------------------

  const formatSeverity = (value) => {
    if (!value) return "Unknown";

    return (
      value.charAt(0).toUpperCase() +
      value.slice(1)
    );
  };

  // --------------------------------
  // Format status
  // --------------------------------

  const formatStatus = (value) => {
    if (!value) return "Pending";

    return (
      value.charAt(0).toUpperCase() +
      value.slice(1)
    );
  };

  // --------------------------------
  // Format date
  // --------------------------------

  const formatDate = (value) => {
    if (!value) return "Not available";

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      return "Not available";
    }

    return date.toLocaleString();
  };

  // --------------------------------
  // Severity badge
  // --------------------------------

  const getSeverityBadge = (severity) => {
    if (severity === "high") {
      return "danger";
    }

    if (severity === "medium") {
      return "warning";
    }

    return "success";
  };

  // --------------------------------
  // Status badge
  // --------------------------------

  const getStatusBadge = (status) => {
    return status === "resolved"
      ? "success"
      : "warning";
  };

  // --------------------------------
  // Readable location
  // --------------------------------

  const locationName =
    typeof report?.location_name === "string"
      ? report.location_name.trim()
      : "";

  const hasLocation =
    locationName !== "";

  // --------------------------------
  // Loading
  // --------------------------------

  if (loading) {
    return (
      <MainLayout>
        <PageHeader
          title="Report Details"
          backTo="/reports"
        />

        <Card
          maxWidth="max-w-4xl"
          className="mx-auto text-center"
        >
          <div className="py-12">

            <div className="w-12 h-12 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto" />

            <p className="text-gray-500 mt-5">
              Loading report details...
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
          title="Report Details"
          backTo="/reports"
        />

        <Card
          maxWidth="max-w-4xl"
          className="mx-auto text-center"
        >
          <div className="py-10">

            <p className="text-red-500 mb-6">
              {error}
            </p>

            <Button
              onClick={() =>
                navigate("/reports")
              }
            >
              Back to My Reports
            </Button>

          </div>
        </Card>
      </MainLayout>
    );
  }

  return (
    <MainLayout>

      <PageHeader
        title="Report Details"
        backTo="/reports"
      />

      <div className="max-w-4xl mx-auto space-y-6">

        {/* TOP SUMMARY */}
        <Card>

          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">

            <div>

              <p className="text-sm text-gray-500">
                Report ID
              </p>

              <h1 className="text-2xl font-bold mt-1">
                #{report.id}
              </h1>

            </div>

            <Badge
              type={getStatusBadge(
                report.status
              )}
            >
              {formatStatus(
                report.status
              )}
            </Badge>

          </div>

        </Card>

        {/* IMAGE */}
        <Card>

          <div className="flex items-center gap-3 mb-5">

            <FaImage className="text-blue-600 text-2xl" />

            <h2 className="text-xl font-bold">
              Report Image
            </h2>

          </div>

          {report.image ? (

            <img
              src={report.image}
              alt={formatIssueType(
                report.issue_type
              )}
              className="w-full max-h-[500px] object-cover rounded-3xl"
            />

          ) : (

            <div className="h-64 bg-gray-100 rounded-3xl flex items-center justify-center">

              <p className="text-gray-400">
                Image unavailable
              </p>

            </div>

          )}

        </Card>

        {/* AI ANALYSIS */}
        <Card>

          <div className="flex items-center gap-3 mb-6">

            <FaBrain className="text-purple-600 text-2xl" />

            <h2 className="text-xl font-bold">
              AI Analysis
            </h2>

          </div>

          <div className="space-y-5">

            {/* Issue Type */}
            <div className="flex justify-between items-center gap-4">

              <span className="text-gray-500">
                Issue Type
              </span>

              <strong className="text-right">
                {formatIssueType(
                  report.issue_type
                )}
              </strong>

            </div>

            {/* Severity */}
            <div className="flex justify-between items-center gap-4">

              <span className="text-gray-500">
                Severity
              </span>

              <Badge
                type={getSeverityBadge(
                  report.severity
                )}
              >
                {formatSeverity(
                  report.severity
                )}
              </Badge>

            </div>

            {/* Confidence */}
            <div className="flex justify-between items-center gap-4">

              <span className="text-gray-500">
                AI Confidence
              </span>

              <Badge type="success">
                {report.confidence !==
                  null &&
                report.confidence !==
                  undefined
                  ? `${report.confidence}%`
                  : "N/A"}
              </Badge>

            </div>

          </div>

        </Card>

        {/* LOCATION */}
        <Card>

          <div className="flex items-center gap-3 mb-5">

            <FaMapMarkerAlt className="text-red-500 text-2xl" />

            <h2 className="text-xl font-bold">
              Issue Location
            </h2>

          </div>

          {hasLocation ? (

            <div>

              {/* Location detected */}
              <div className="bg-green-50 border border-green-200 rounded-2xl p-5">

                <div className="flex items-start gap-3">

                  <FaCheckCircle className="text-green-600 text-xl mt-1 flex-shrink-0" />

                  <div className="flex-1 min-w-0">

                    <p className="font-semibold text-green-700">
                      Location detected
                    </p>

                    <p className="text-sm text-gray-500 mt-1">
                      Location was automatically captured when the report was submitted.
                    </p>

                  </div>

                </div>

              </div>

              {/* Detected Address */}
              <div className="mt-4 bg-gray-50 border border-gray-200 rounded-2xl p-5">

                <div className="flex items-start gap-3">

                  <FaMapMarkerAlt className="text-red-500 text-xl mt-1 flex-shrink-0" />

                  <div className="flex-1 min-w-0">

                    <p className="text-sm text-gray-500">
                      Detected Address
                    </p>

                    <p className="text-lg font-bold mt-1 text-gray-800 break-words">
                      {locationName}
                    </p>

                  </div>

                </div>

              </div>

            </div>

          ) : (

            <div className="bg-yellow-50 border border-yellow-200 rounded-2xl p-5">

              <p className="text-yellow-700 font-medium">
                Location is not available for this report.
              </p>

              <p className="text-sm text-yellow-600 mt-1">
                The report was submitted without a readable address.
              </p>

            </div>

          )}

        </Card>

        {/* DESCRIPTION */}
        <Card>

          <div className="flex items-center gap-3 mb-5">

            <FaFileAlt className="text-blue-600 text-xl" />

            <h2 className="text-xl font-bold">
              Description
            </h2>

          </div>

          <p className="text-gray-600 leading-7 whitespace-pre-line">
            {report.description ||
              "No description provided."}
          </p>

        </Card>

        {/* SUBMISSION INFORMATION */}
        <Card>

          <div className="flex items-center gap-3 mb-5">

            <FaCalendarAlt className="text-blue-600 text-xl" />

            <h2 className="text-xl font-bold">
              Submission Information
            </h2>

          </div>

          <div className="space-y-4">

            {/* Submitted */}
            <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2">

              <span className="text-gray-500">
                Submitted
              </span>

              <span className="flex items-center gap-2 font-medium">

                <FaClock className="text-blue-600" />

                {formatDate(
                  report.created_at
                )}

              </span>

            </div>

            {/* Status */}
            <div className="flex justify-between items-center">

              <span className="text-gray-500">
                Status
              </span>

              <Badge
                type={getStatusBadge(
                  report.status
                )}
              >
                {formatStatus(
                  report.status
                )}
              </Badge>

            </div>

          </div>

        </Card>

        {/* ACTIONS */}
        <div className="grid md:grid-cols-2 gap-4 pb-8">

          <Button
            variant="secondary"
            onClick={() =>
              navigate("/reports")
            }
          >
            <FaArrowLeft className="inline mr-2" />
            Back to My Reports
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

export default ReportDetails;
