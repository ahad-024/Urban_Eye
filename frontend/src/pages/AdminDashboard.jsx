import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";
import { toast } from "react-toastify";

const AdminDashboard = () => {
  const navigate = useNavigate();

  const [stats, setStats] = useState({
    total_reports: 0,
    resolved_reports: 0,
    pending_reports: 0,
    active_users: 0,
  });

  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);

  const accessToken = localStorage.getItem("access_token");

  useEffect(() => {
    const isAdmin = localStorage.getItem("is_admin");

    if (!accessToken || isAdmin !== "true") {
      navigate("/admin-login");
      return;
    }

    fetchAdminData();
  }, []);

  const fetchAdminData = async () => {
    try {
      setLoading(true);

      const config = {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      };

      const [statsResponse, reportsResponse] = await Promise.all([
        axios.get(
          "http://127.0.0.1:8000/api/dashboard/stats/",
          config
        ),

        axios.get(
          "http://127.0.0.1:8000/api/reports/admin/",
          config
        ),
      ]);

      setStats(statsResponse.data);

      setReports(
        Array.isArray(reportsResponse.data)
          ? reportsResponse.data.slice(0, 5)
          : []
      );
    } catch (error) {
      console.error("Admin dashboard error:", error);

      if (error.response?.status === 401) {
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");
        localStorage.removeItem("user");
        localStorage.removeItem("is_admin");

        toast.error("Admin session expired.");
        navigate("/admin-login");
        return;
      }

      if (error.response?.status === 403) {
        toast.error("Administrator access is required.");
        navigate("/admin-login");
        return;
      }

      toast.error("Failed to load admin dashboard.");
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("user");
    localStorage.removeItem("is_admin");

    toast.success("Admin logged out.");

    navigate("/admin-login");
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

  const getSeverityClass = (severity) => {
    if (severity === "high") {
      return "bg-red-100 text-red-700";
    }

    if (severity === "medium") {
      return "bg-yellow-100 text-yellow-700";
    }

    return "bg-green-100 text-green-700";
  };

  const getStatusClass = (status) => {
    if (status === "resolved") {
      return "bg-green-100 text-green-700";
    }

    return "bg-orange-100 text-orange-700";
  };

  return (
    <div className="min-h-screen bg-gray-50">

      <header className="bg-blue-600 text-white px-6 py-5 shadow-md">
        <div className="max-w-7xl mx-auto flex items-center justify-between">

          <div>
            <h1 className="text-2xl font-bold">
              UrbanEye Admin
            </h1>

            <p className="text-blue-100 text-sm mt-1">
              Administration Dashboard
            </p>
          </div>

          <div className="flex items-center gap-3">

            <button
              onClick={() => navigate("/admin-reports")}
              className="bg-white text-blue-600 px-4 py-2 rounded-lg font-semibold hover:bg-blue-50 transition"
            >
              Admin Reports
            </button>

            <button
              onClick={() => navigate("/admin-complaints")}
              className="bg-white text-blue-600 px-4 py-2 rounded-lg font-semibold hover:bg-blue-50 transition"
            >
              Complaints
            </button>

            <button
              onClick={handleLogout}
              className="bg-red-500 text-white px-4 py-2 rounded-lg font-semibold hover:bg-red-600 transition"
            >
              Logout
            </button>

          </div>

        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-8">

        <div className="mb-8">
          <h2 className="text-2xl font-bold text-gray-800">
            Dashboard Overview
          </h2>

          <p className="text-gray-500 mt-1">
            Monitor UrbanEye reports and civic issues.
          </p>
        </div>

        {loading ? (

          <div className="text-center py-10 text-gray-500">
            Loading dashboard...
          </div>

        ) : (

          <>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">

              <div className="bg-white rounded-2xl shadow-sm p-6 border border-gray-100">

                <p className="text-gray-500 text-sm">
                  Active Users
                </p>

                <h3 className="text-3xl font-bold text-blue-600 mt-2">
                  {stats.active_users}
                </h3>

              </div>

              <div className="bg-white rounded-2xl shadow-sm p-6 border border-gray-100">

                <p className="text-gray-500 text-sm">
                  Total Reports
                </p>

                <h3 className="text-3xl font-bold text-purple-600 mt-2">
                  {stats.total_reports}
                </h3>

              </div>

              <div className="bg-white rounded-2xl shadow-sm p-6 border border-gray-100">

                <p className="text-gray-500 text-sm">
                  Pending Reports
                </p>

                <h3 className="text-3xl font-bold text-orange-500 mt-2">
                  {stats.pending_reports}
                </h3>

              </div>

              <div className="bg-white rounded-2xl shadow-sm p-6 border border-gray-100">

                <p className="text-gray-500 text-sm">
                  Resolved Reports
                </p>

                <h3 className="text-3xl font-bold text-green-600 mt-2">
                  {stats.resolved_reports}
                </h3>

              </div>

            </div>

            <div className="bg-white rounded-2xl shadow-sm border border-gray-100">

              <div className="px-6 py-5 border-b border-gray-100 flex items-center justify-between">

                <div>
                  <h3 className="text-lg font-bold text-gray-800">
                    Recent Reports
                  </h3>

                  <p className="text-sm text-gray-500 mt-1">
                    Latest civic issue reports submitted by users.
                  </p>
                </div>

                <button
                  onClick={() => navigate("/admin-reports")}
                  className="text-sm font-semibold text-blue-600 hover:text-blue-700"
                >
                  View All
                </button>

              </div>

              {reports.length === 0 ? (

                <div className="p-8 text-center text-gray-500">
                  No reports found.
                </div>

              ) : (

                <div className="overflow-x-auto">

                  <table className="w-full">

                    <thead className="bg-gray-50">

                      <tr>

                        <th className="text-left px-6 py-4 text-sm font-semibold text-gray-600">
                          Image
                        </th>

                        <th className="text-left px-6 py-4 text-sm font-semibold text-gray-600">
                          User
                        </th>

                        <th className="text-left px-6 py-4 text-sm font-semibold text-gray-600">
                          Issue
                        </th>

                        <th className="text-left px-6 py-4 text-sm font-semibold text-gray-600">
                          Severity
                        </th>

                        <th className="text-left px-6 py-4 text-sm font-semibold text-gray-600">
                          Confidence
                        </th>

                        <th className="text-left px-6 py-4 text-sm font-semibold text-gray-600">
                          Status
                        </th>

                      </tr>

                    </thead>

                    <tbody>

                      {reports.map((report) => (

                        <tr
                          key={report.id}
                          className="border-t border-gray-100 hover:bg-gray-50"
                        >

                          <td className="px-6 py-4">

                            {report.image ? (

                              <img
                                src={report.image}
                                alt={getIssueName(report.issue_type)}
                                className="w-16 h-12 object-cover rounded-lg"
                              />

                            ) : (

                              <div className="w-16 h-12 bg-gray-100 rounded-lg flex items-center justify-center text-xs text-gray-400">
                                No image
                              </div>

                            )}

                          </td>

                          <td className="px-6 py-4">

                            <p className="font-medium text-gray-800">
                              {report.user}
                            </p>

                            <p className="text-xs text-gray-400">
                              Report #{report.id}
                            </p>

                          </td>

                          <td className="px-6 py-4">

                            <p className="font-semibold text-gray-800">
                              {getIssueName(report.issue_type)}
                            </p>

                          </td>

                          <td className="px-6 py-4">

                            <span
                              className={`px-3 py-1 rounded-full text-xs font-semibold ${getSeverityClass(
                                report.severity
                              )}`}
                            >
                              {report.severity}
                            </span>

                          </td>

                          <td className="px-6 py-4 text-gray-700">

                            {report.confidence !== null &&
                            report.confidence !== undefined
                              ? `${report.confidence}%`
                              : "N/A"}

                          </td>

                          <td className="px-6 py-4">

                            <span
                              className={`px-3 py-1 rounded-full text-xs font-semibold ${getStatusClass(
                                report.status
                              )}`}
                            >
                              {report.status}
                            </span>

                          </td>

                        </tr>

                      ))}

                    </tbody>

                  </table>

                </div>

              )}

            </div>

          </>

        )}

      </main>

    </div>
  );
};

export default AdminDashboard;