import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const AdminReports = () => {
  const navigate = useNavigate();

  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [updatingId, setUpdatingId] = useState(null);
  const [error, setError] = useState("");

  const accessToken = localStorage.getItem("access_token");
  const isAdmin = localStorage.getItem("is_admin");

  useEffect(() => {
    if (!accessToken || isAdmin !== "true") {
      navigate("/admin-login");
      return;
    }

    fetchReports();
  }, [accessToken, isAdmin, navigate]);

  const fetchReports = async () => {
    try {
      setLoading(true);
      setError("");

      const response = await axios.get(
        "http://127.0.0.1:8000/api/reports/admin/",
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        }
      );

      setReports(
        Array.isArray(response.data) ? response.data : []
      );
    } catch (err) {
      console.error("Error fetching reports:", err);

      if (err.response?.status === 401) {
        localStorage.clear();
        navigate("/admin-login");
        return;
      }

      if (err.response?.status === 403) {
        setError("Administrator access is required.");
      } else {
        setError("Failed to load reports.");
      }
    } finally {
      setLoading(false);
    }
  };

  const updateStatus = async (reportId, newStatus) => {
    try {
      setUpdatingId(reportId);
      setError("");

      const response = await axios.patch(
        `http://127.0.0.1:8000/api/reports/admin/${reportId}/`,
        {
          status: newStatus,
        },
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
        }
      );

      setReports((previousReports) =>
        previousReports.map((report) =>
          report.id === reportId ? response.data : report
        )
      );
    } catch (err) {
      console.error("Error updating status:", err);
      setError("Failed to update report status.");
    } finally {
      setUpdatingId(null);
    }
  };

  const getIssueName = (issueType) => {
    const names = {
      garbage: "Garbage",
      pothole: "Pothole",
      road_crack: "Road Crack",
      street_light: "Street Light",
      water_overflow: "Water Overflow",
    };

    return names[issueType] || issueType;
  };

  const getSeverityStyle = (severity) => {
    if (severity === "high") {
      return "bg-red-100 text-red-700";
    }

    if (severity === "medium") {
      return "bg-yellow-100 text-yellow-700";
    }

    return "bg-green-100 text-green-700";
  };

  const getStatusStyle = (status) => {
    if (status === "resolved") {
      return "bg-green-100 text-green-700";
    }

    return "bg-yellow-100 text-yellow-700";
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-blue-600 px-6 py-5 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold">Admin Reports</h1>
            <p className="mt-1 text-sm text-blue-100">
              Manage and update civic issue reports
            </p>
          </div>

          <button
            onClick={() => navigate("/admin-dashboard")}
            className="rounded-lg bg-white px-4 py-2 text-sm font-semibold text-blue-600 hover:bg-blue-50"
          >
            Dashboard
          </button>
        </div>
      </div>

      <div className="mx-auto max-w-7xl px-4 py-6">
        {error && (
          <div className="mb-5 rounded-lg bg-red-100 px-4 py-3 text-sm text-red-700">
            {error}
          </div>
        )}

        {loading ? (
          <div className="rounded-xl bg-white p-10 text-center shadow-sm">
            <p className="text-gray-500">
              Loading reports...
            </p>
          </div>
        ) : reports.length === 0 ? (
          <div className="rounded-xl bg-white p-10 text-center shadow-sm">
            <p className="text-gray-500">
              No reports found.
            </p>
          </div>
        ) : (
          <div className="overflow-hidden rounded-xl bg-white shadow-sm">
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <thead className="bg-gray-100">
                  <tr>
                    <th className="px-4 py-4 text-left text-sm font-semibold text-gray-700">
                      ID
                    </th>

                    <th className="px-4 py-4 text-left text-sm font-semibold text-gray-700">
                      Image
                    </th>

                    <th className="px-4 py-4 text-left text-sm font-semibold text-gray-700">
                      User
                    </th>

                    <th className="px-4 py-4 text-left text-sm font-semibold text-gray-700">
                      Issue
                    </th>

                    <th className="px-4 py-4 text-left text-sm font-semibold text-gray-700">
                      Severity
                    </th>

                    <th className="px-4 py-4 text-left text-sm font-semibold text-gray-700">
                      Confidence
                    </th>

                    <th className="px-4 py-4 text-left text-sm font-semibold text-gray-700">
                      Status
                    </th>

                    <th className="px-4 py-4 text-left text-sm font-semibold text-gray-700">
                      Action
                    </th>
                  </tr>
                </thead>

                <tbody className="divide-y divide-gray-100">
                  {reports.map((report) => (
                    <tr
                      key={report.id}
                      className="hover:bg-gray-50"
                    >
                      <td className="px-4 py-4 text-sm font-medium text-gray-800">
                        #{report.id}
                      </td>

                      {/* Image */}
                      <td className="px-4 py-4">
                        {report.image ? (
                          <img
                            src={report.image}
                            alt={getIssueName(report.issue_type)}
                            className="h-16 w-20 rounded-lg object-cover"
                          />
                        ) : (
                          <div className="flex h-16 w-20 items-center justify-center rounded-lg bg-gray-100 text-xs text-gray-400">
                            No Image
                          </div>
                        )}
                      </td>

                      <td className="px-4 py-4 text-sm text-gray-700">
                        {report.user}
                      </td>

                      <td className="px-4 py-4">
                        <span className="text-sm font-medium text-gray-800">
                          {getIssueName(report.issue_type)}
                        </span>
                      </td>

                      <td className="px-4 py-4">
                        <span
                          className={`rounded-full px-3 py-1 text-xs font-semibold capitalize ${getSeverityStyle(
                            report.severity
                          )}`}
                        >
                          {report.severity}
                        </span>
                      </td>

                      <td className="px-4 py-4 text-sm text-gray-700">
                        {report.confidence !== null &&
                        report.confidence !== undefined
                          ? `${report.confidence}%`
                          : "N/A"}
                      </td>

                      <td className="px-4 py-4">
                        <span
                          className={`rounded-full px-3 py-1 text-xs font-semibold capitalize ${getStatusStyle(
                            report.status
                          )}`}
                        >
                          {report.status}
                        </span>
                      </td>

                      <td className="px-4 py-4">
                        <select
                          value={report.status}
                          disabled={updatingId === report.id}
                          onChange={(e) =>
                            updateStatus(
                              report.id,
                              e.target.value
                            )
                          }
                          className="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 disabled:cursor-not-allowed disabled:bg-gray-100"
                        >
                          <option value="pending">
                            Pending
                          </option>

                          <option value="resolved">
                            Resolved
                          </option>
                        </select>

                        {updatingId === report.id && (
                          <p className="mt-1 text-xs text-blue-600">
                            Updating...
                          </p>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default AdminReports;