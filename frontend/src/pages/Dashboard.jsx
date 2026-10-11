
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  FaFileAlt,
  FaCheckCircle,
  FaClock,
  FaUsers,
  FaRoad,
  FaTrash,
  FaLightbulb,
  FaTint,
  FaMapMarkerAlt,
} from "react-icons/fa";
import { toast } from "react-toastify";

import api from "../api/axios";
import MainLayout from "../layouts/MainLayout";
import PageHeader from "../components/PageHeader";
import StatCard from "../components/StatCard";
import Badge from "../components/Badge";

const Dashboard = () => {
  const navigate = useNavigate();

  const [stats, setStats] = useState({
    totalReports: 0,
    resolved: 0,
    pending: 0,
    activeUsers: 0,
  });

  const [issues, setIssues] = useState([]);
  const [recentReports, setRecentReports] = useState([]);
  const [loading, setLoading] = useState(true);

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

  const formatStatus = (value) => {
    if (!value) return "Unknown";

    return (
      value.charAt(0).toUpperCase() +
      value.slice(1)
    );
  };

  const formatLocation = (report) => {
    if (
      !report.location_name ||
      report.location_name.trim() === ""
    ) {
      return "Location unavailable";
    }

    return report.location_name;
  };

  const getIssueIcon = (issueType) => {
    switch (issueType) {
      case "Garbage":
        return FaTrash;

      case "Street Light":
        return FaLightbulb;

      case "Water Overflow":
        return FaTint;

      case "Pothole":
      case "Road Crack":
      default:
        return FaRoad;
    }
  };

  useEffect(() => {
    const loadDashboard = async () => {
      try {
        setLoading(true);

        const accessToken =
          localStorage.getItem("access_token");

        if (!accessToken) {
          navigate("/login");
          return;
        }

        const headers = {
          Authorization:
            `Bearer ${accessToken}`,
        };

        /* =========================
           DASHBOARD STATISTICS
        ========================= */

        const statsResponse =
          await api.get(
            "dashboard/stats/",
            { headers }
          );

        const data =
          statsResponse.data;

        setStats({
          totalReports:
            data.total_reports || 0,

          resolved:
            data.resolved_reports || 0,

          pending:
            data.pending_reports || 0,

          activeUsers:
            data.active_users || 0,
        });

        /* =========================
           USER REPORTS
        ========================= */

        const reportsResponse =
          await api.get(
            "reports/",
            { headers }
          );

        const reports =
          Array.isArray(
            reportsResponse.data
          )
            ? reportsResponse.data
            : [];

        /* =========================
           ISSUE STATISTICS
        ========================= */

        const issueCount = {};

        reports.forEach((report) => {
          const issue =
            formatIssueType(
              report.issue_type
            );

          issueCount[issue] =
            (issueCount[issue] || 0) + 1;
        });

        const issueData =
          Object.keys(issueCount).map(
            (item) => ({
              name: item,
              count:
                issueCount[item],
              icon:
                getIssueIcon(item),
            })
          );

        setIssues(issueData);

        /* =========================
           RECENT REPORTS
        ========================= */

        const recent =
          reports
            .slice(0, 5)
            .map((report) => ({
              ...report,

              issueType:
                formatIssueType(
                  report.issue_type
                ),

              status:
                formatStatus(
                  report.status
                ),

              location:
                formatLocation(
                  report
                ),
            }));

        setRecentReports(recent);

      } catch (error) {
        console.error(
          "Failed to load dashboard:",
          error.response?.data ||
            error.message
        );

        if (
          error.response?.status ===
          401
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

        toast.error(
          "Unable to load dashboard data."
        );

      } finally {
        setLoading(false);
      }
    };

    loadDashboard();
  }, [navigate]);

  return (
    <MainLayout>

      <PageHeader
        title="Dashboard"
        backTo="/home"
      />

      {/* =========================
          STAT CARDS
      ========================= */}

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">

        <StatCard
          title="Total Reports"
          value={
            loading
              ? "..."
              : stats.totalReports
          }
          icon={FaFileAlt}
          color="text-blue-600"
        />

        <StatCard
          title="Resolved"
          value={
            loading
              ? "..."
              : stats.resolved
          }
          icon={FaCheckCircle}
          color="text-green-600"
        />

        <StatCard
          title="Pending"
          value={
            loading
              ? "..."
              : stats.pending
          }
          icon={FaClock}
          color="text-yellow-500"
        />

        <StatCard
          title="Active Users"
          value={
            loading
              ? "..."
              : stats.activeUsers
          }
          icon={FaUsers}
          color="text-purple-600"
        />

      </div>

      {/* =========================
          ISSUE STATISTICS
      ========================= */}

      <div className="mt-10">

        <h2 className="text-2xl font-bold mb-5">
          Issue Statistics
        </h2>

        {loading ? (
          <p className="text-gray-500">
            Loading issue statistics...
          </p>
        ) : issues.length === 0 ? (
          <p className="text-gray-500">
            No reports submitted yet.
          </p>
        ) : (
          <div className="grid grid-cols-2 md:grid-cols-3 gap-5">

            {issues.map((item) => {
              const Icon = item.icon;

              return (
                <div
                  key={item.name}
                  className="bg-white rounded-2xl shadow-md p-5 hover:shadow-xl transition"
                >

                  <Icon className="text-blue-600 text-3xl" />

                  <h3 className="mt-4 font-semibold text-lg">
                    {item.name}
                  </h3>

                  <p className="text-gray-500">
                    {item.count} Reports
                  </p>

                </div>
              );
            })}

          </div>
        )}

      </div>

      {/* =========================
          RECENT REPORTS
      ========================= */}

      <div className="mt-10">

        <h2 className="text-2xl font-bold mb-5">
          Recent Reports
        </h2>

        <div className="bg-white rounded-2xl shadow-md p-6 space-y-5">

          {loading ? (
            <p className="text-gray-500">
              Loading recent reports...
            </p>
          ) : recentReports.length === 0 ? (
            <p className="text-gray-500">
              No reports available.
            </p>
          ) : (
            recentReports.map(
              (report) => (
                <div
                  key={report.id}
                  onClick={() =>
                    navigate(
                      `/reports/${report.id}`
                    )
                  }
                  className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-4 border-b pb-4 cursor-pointer hover:bg-blue-50 rounded-xl p-3 transition"
                >

                  <div>

                    <h3 className="font-semibold text-lg">
                      {report.issueType}
                    </h3>

                    <div className="flex items-start gap-2 text-gray-500 mt-1">

                      <FaMapMarkerAlt className="text-green-600 mt-1 flex-shrink-0" />

                      <p className="text-sm">
                        {report.location}
                      </p>

                    </div>

                  </div>

                  <Badge
                    type={
                      report.status ===
                      "Resolved"
                        ? "success"
                        : "warning"
                    }
                  >
                    {report.status}
                  </Badge>

                </div>
              )
            )
          )}

        </div>

      </div>

    </MainLayout>
  );
};

export default Dashboard;
