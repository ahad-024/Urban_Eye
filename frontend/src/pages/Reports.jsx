
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  FaMapMarkerAlt,
  FaEye,
  FaClipboardList,
  FaClock,
} from "react-icons/fa";

import api from "../api/axios";
import MainLayout from "../layouts/MainLayout";
import PageHeader from "../components/PageHeader";
import Card from "../components/Card";
import Badge from "../components/Badge";
import Button from "../components/Button";

const Reports = () => {
  const navigate = useNavigate();

  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const loadReports = async () => {
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
          "reports/",
          {
            headers: {
              Authorization:
                `Bearer ${accessToken}`,
            },
          }
        );

        setReports(
          Array.isArray(response.data)
            ? response.data
            : []
        );
      } catch (err) {
        console.error(
          "Failed to load reports:",
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

        setError(
          "Failed to load your reports."
        );
      } finally {
        setLoading(false);
      }
    };

    loadReports();
  }, [navigate]);

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
  // Format date
  // --------------------------------

  const formatDate = (date) => {
    if (!date) return "Not available";

    const parsedDate = new Date(date);

    if (Number.isNaN(parsedDate.getTime())) {
      return "Not available";
    }

    return parsedDate.toLocaleString();
  };

  // --------------------------------
  // Readable location
  // --------------------------------

  const getLocationName = (report) => {
    if (
      !report?.location_name ||
      typeof report.location_name !== "string"
    ) {
      return "";
    }

    return report.location_name.trim();
  };

  // --------------------------------
  // Loading
  // --------------------------------

  if (loading) {
    return (
      <MainLayout>
        <PageHeader
          title="My Reports"
          backTo="/home"
        />

        <Card
          maxWidth="max-w-5xl"
          className="mx-auto text-center"
        >
          <div className="py-12">

            <div className="w-12 h-12 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin mx-auto" />

            <p className="text-gray-500 mt-5">
              Loading your reports...
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
          title="My Reports"
          backTo="/home"
        />

        <Card
          maxWidth="max-w-5xl"
          className="mx-auto text-center"
        >
          <p className="text-red-500 mb-5">
            {error}
          </p>

          <Button
            onClick={() =>
              window.location.reload()
            }
          >
            Try Again
          </Button>
        </Card>
      </MainLayout>
    );
  }

  // --------------------------------
  // Main
  // --------------------------------

  return (
    <MainLayout>
      <PageHeader
        title="My Reports"
        backTo="/home"
      />

      <div className="max-w-5xl mx-auto">

        {reports.length === 0 ? (
          <Card className="text-center">

            <div className="py-12">

              <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-5">

                <FaClipboardList className="text-blue-600 text-3xl" />

              </div>

              <h2 className="text-2xl font-bold">
                No Reports Yet
              </h2>

              <p className="text-gray-500 mt-3 mb-6">
                You have not submitted any civic issue reports yet.
              </p>

              <Button
                onClick={() =>
                  navigate("/capture")
                }
              >
                Create Your First Report
              </Button>

            </div>

          </Card>
        ) : (

          <div className="space-y-5">

            {reports.map((report) => {

              const locationName =
                getLocationName(report);

              return (
                <Card
                  key={report.id}
                  className="hover:shadow-lg transition-shadow"
                >

                  <div className="flex flex-col md:flex-row gap-5">

                    {/* IMAGE */}
                    <div className="w-full md:w-48 h-40 flex-shrink-0">

                      {report.image ? (
                        <img
                          src={report.image}
                          alt={formatIssueType(
                            report.issue_type
                          )}
                          className="w-full h-full object-cover rounded-2xl"
                        />
                      ) : (
                        <div className="w-full h-full bg-gray-100 rounded-2xl flex items-center justify-center">

                          <FaClipboardList className="text-gray-400 text-3xl" />

                        </div>
                      )}

                    </div>

                    {/* CONTENT */}
                    <div className="flex-1 min-w-0">

                      <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3">

                        <div>

                          <h2 className="text-xl font-bold">
                            {formatIssueType(
                              report.issue_type
                            )}
                          </h2>

                          <p className="text-sm text-gray-500 mt-1">
                            Report #{report.id}
                          </p>

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

                      {/* REPORT INFO */}
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mt-5">

                        {/* Severity */}
                        <div>

                          <p className="text-sm text-gray-500">
                            Severity
                          </p>

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
                        <div>

                          <p className="text-sm text-gray-500">
                            AI Confidence
                          </p>

                          <p className="font-semibold mt-1">
                            {report.confidence !==
                              null &&
                            report.confidence !==
                              undefined
                              ? `${report.confidence}%`
                              : "N/A"}
                          </p>

                        </div>

                      </div>

                      {/* LOCATION */}
                      <div className="mt-5 bg-green-50 border border-green-200 rounded-xl p-3">

                        <div className="flex items-center gap-2">

                          <FaMapMarkerAlt className="text-green-600 flex-shrink-0" />

                          <p className="font-semibold text-green-700">
                            Issue Location
                          </p>

                        </div>

                        {locationName ? (

                          <div className="flex items-start gap-2 mt-2">

                            <FaMapMarkerAlt className="text-red-500 mt-1 flex-shrink-0" />

                            <p className="text-sm text-gray-700 break-words">
                              {locationName}
                            </p>

                          </div>

                        ) : (

                          <p className="text-sm text-gray-500 mt-2">
                            Location unavailable
                          </p>

                        )}

                      </div>

                      {/* DATE + BUTTON */}
                      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mt-5">

                        <div className="flex items-center gap-2 text-sm text-gray-500">

                          <FaClock className="text-blue-600 flex-shrink-0" />

                          <span>
                            {formatDate(
                              report.created_at
                            )}
                          </span>

                        </div>

                        <Button
                          onClick={() =>
                            navigate(
                              `/reports/${report.id}`
                            )
                          }
                        >
                          <FaEye className="inline mr-2" />
                          View Details
                        </Button>

                      </div>

                    </div>

                  </div>

                </Card>
              );
            })}

          </div>
        )}

      </div>
    </MainLayout>
  );
};

export default Reports;
