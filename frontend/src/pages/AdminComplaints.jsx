import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const AdminComplaints = () => {
  const navigate = useNavigate();

  const [complaints, setComplaints] = useState([]);
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

    fetchComplaints();
  }, []);

  const fetchComplaints = async () => {
    try {
      setLoading(true);
      setError("");

      const response = await axios.get(
        "http://127.0.0.1:8000/api/complaints/admin/",
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        }
      );

      setComplaints(Array.isArray(response.data)? response.data: []);

    } catch (error) {
      console.error("Error fetching complaints:", error);

      if (error.response?.status === 401) {
        localStorage.clear();
        navigate("/admin-login");
        return;
      }

      if (error.response?.status === 403) {
        setError("Administrator access is required.");
      } else {
        setError("Failed to load complaints.");
      }
    } finally {
      setLoading(false);
    }
  };

  const updateStatus = async (complaintId, newStatus) => {
    try {
      setUpdatingId(complaintId);
      setError("");

      const response = await axios.patch(
        `http://127.0.0.1:8000/api/complaints/admin/${complaintId}/`,
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

      setComplaints((previousComplaints) =>
        previousComplaints.map((complaint) =>
          complaint.id === complaintId
            ? response.data
            : complaint
        )
      );
    } catch (error) {
      console.error("Error updating complaint:", error);
      setError("Failed to update complaint status.");
    } finally {
      setUpdatingId(null);
    }
  };

  const getStatusClass = (status) => {
    switch (status) {
      case "submitted":
        return "bg-blue-100 text-blue-700";

      case "in_progress":
        return "bg-yellow-100 text-yellow-700";

      case "resolved":
        return "bg-green-100 text-green-700";

      case "rejected":
        return "bg-red-100 text-red-700";

      default:
        return "bg-gray-100 text-gray-700";
    }
  };

  const getStatusName = (status) => {
    switch (status) {
      case "submitted":
        return "Submitted";

      case "in_progress":
        return "In Progress";

      case "resolved":
        return "Resolved";

      case "rejected":
        return "Rejected";

      default:
        return status;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">

      <header className="bg-blue-600 px-6 py-5 text-white shadow-md">
        <div className="mx-auto flex max-w-7xl items-center justify-between">

          <div>
            <h1 className="text-2xl font-bold">
              Admin Complaints
            </h1>

            <p className="mt-1 text-sm text-blue-100">
              Manage user complaints
            </p>
          </div>

          <button
            onClick={() => navigate("/admin-dashboard")}
            className="rounded-lg bg-white px-4 py-2 font-semibold text-blue-600 transition hover:bg-blue-50"
          >
            Dashboard
          </button>

        </div>
      </header>

      <main className="mx-auto max-w-7xl px-6 py-8">

        {error && (
          <div className="mb-5 rounded-lg bg-red-100 px-4 py-3 text-sm text-red-700">
            {error}
          </div>
        )}

        {loading ? (

          <div className="rounded-2xl bg-white py-12 text-center shadow-sm">
            <p className="text-gray-500">
              Loading complaints...
            </p>
          </div>

        ) : complaints.length === 0 ? (

          <div className="rounded-2xl bg-white py-12 text-center shadow-sm">
            <p className="text-gray-500">
              No complaints found.
            </p>
          </div>

        ) : (

          <div className="overflow-hidden rounded-2xl bg-white shadow-sm">

            <div className="overflow-x-auto">

              <table className="w-full">

                <thead className="bg-gray-50">

                  <tr>

                    <th className="px-6 py-4 text-left text-sm font-semibold text-gray-600">
                      ID
                    </th>

                    <th className="px-6 py-4 text-left text-sm font-semibold text-gray-600">
                      User
                    </th>

                    <th className="px-6 py-4 text-left text-sm font-semibold text-gray-600">
                      Report
                    </th>

                    <th className="px-6 py-4 text-left text-sm font-semibold text-gray-600">
                      Title
                    </th>

                    <th className="px-6 py-4 text-left text-sm font-semibold text-gray-600">
                      Description
                    </th>

                    <th className="px-6 py-4 text-left text-sm font-semibold text-gray-600">
                      Status
                    </th>

                    <th className="px-6 py-4 text-left text-sm font-semibold text-gray-600">
                      Action
                    </th>

                  </tr>

                </thead>

                <tbody>

                  {complaints.map((complaint) => (

                    <tr
                      key={complaint.id}
                      className="border-t border-gray-100 hover:bg-gray-50"
                    >

                      <td className="px-6 py-4 text-sm font-medium text-gray-800">
                        #{complaint.id}
                      </td>

                      <td className="px-6 py-4">

                        <p className="font-medium text-gray-800">
                          {complaint.user}
                        </p>

                      </td>

                      <td className="px-6 py-4">

                        <span className="rounded-lg bg-gray-100 px-3 py-1 text-sm text-gray-700">
                          Report #{complaint.report}
                        </span>

                      </td>

                      <td className="px-6 py-4">

                        <p className="max-w-xs font-semibold text-gray-800">
                          {complaint.title}
                        </p>

                      </td>

                      <td className="px-6 py-4">

                        <p className="max-w-sm text-sm text-gray-600">
                          {complaint.description}
                        </p>

                      </td>

                      <td className="px-6 py-4">

                        <span
                          className={`rounded-full px-3 py-1 text-xs font-semibold ${getStatusClass(
                            complaint.status
                          )}`}
                        >
                          {getStatusName(complaint.status)}
                        </span>

                      </td>

                      <td className="px-6 py-4">

                        <select
                          value={complaint.status}
                          disabled={
                            updatingId === complaint.id
                          }
                          onChange={(e) =>
                            updateStatus(
                              complaint.id,
                              e.target.value
                            )
                          }
                          className="rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 disabled:cursor-not-allowed disabled:bg-gray-100"
                        >

                          <option value="submitted">
                            Submitted
                          </option>

                          <option value="in_progress">
                            In Progress
                          </option>

                          <option value="resolved">
                            Resolved
                          </option>

                          <option value="rejected">
                            Rejected
                          </option>

                        </select>

                        {updatingId === complaint.id && (
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

      </main>

    </div>
  );
};

export default AdminComplaints;