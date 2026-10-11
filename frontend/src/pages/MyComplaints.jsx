import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const MyComplaints = () => {
  const navigate = useNavigate();

  const [complaints, setComplaints] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const accessToken = localStorage.getItem("access_token");

  useEffect(() => {
    if (!accessToken) {
      navigate("/login");
      return;
    }

    fetchComplaints();
  }, []);

  const fetchComplaints = async () => {
    try {
      setLoading(true);
      setError("");

      const response = await axios.get(
        "http://127.0.0.1:8000/api/complaints/",
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        }
      );

      setComplaints(Array.isArray(response.data) ? response.data : []);
    } catch (error) {
      console.error("Error fetching complaints:", error);

      if (error.response?.status === 401) {
        localStorage.clear();
        navigate("/login");
        return;
      }

      setError("Failed to load complaints.");
    } finally {
      setLoading(false);
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
        <div className="mx-auto flex max-w-5xl items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold">My Complaints</h1>
            <p className="mt-1 text-sm text-blue-100">
              Track the status of your complaints
            </p>
          </div>

          <button
            onClick={() => navigate("/home")}
            className="rounded-lg bg-white px-4 py-2 font-semibold text-blue-600 transition hover:bg-blue-50"
          >
            Home
          </button>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-6 py-8">
        {error && (
          <div className="mb-5 rounded-lg bg-red-100 px-4 py-3 text-sm text-red-700">
            {error}
          </div>
        )}

        {loading ? (
          <div className="rounded-2xl bg-white py-12 text-center shadow-sm">
            <p className="text-gray-500">Loading complaints...</p>
          </div>
        ) : complaints.length === 0 ? (
          <div className="rounded-2xl bg-white py-12 text-center shadow-sm">
            <p className="text-lg font-semibold text-gray-700">
              No complaints found
            </p>

            <p className="mt-2 text-sm text-gray-500">
              Your submitted complaints will appear here.
            </p>
          </div>
        ) : (
          <div className="space-y-5">
            {complaints.map((complaint) => (
              <div
                key={complaint.id}
                className="rounded-2xl bg-white p-6 shadow-sm"
              >
                <div className="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-400">
                      Complaint #{complaint.id}
                    </p>

                    <h2 className="mt-1 text-xl font-bold text-gray-800">
                      {complaint.title}
                    </h2>
                  </div>

                  <span
                    className={`w-fit rounded-full px-4 py-2 text-sm font-semibold ${getStatusClass(
                      complaint.status
                    )}`}
                  >
                    {getStatusName(complaint.status)}
                  </span>
                </div>

                <div className="mt-5 grid gap-4 md:grid-cols-2">
                  <div>
                    <p className="text-sm font-medium text-gray-500">
                      Report
                    </p>

                    <p className="mt-1 text-gray-800">
                      Report #{complaint.report}
                    </p>
                  </div>

                  <div>
                    <p className="text-sm font-medium text-gray-500">
                      Submitted
                    </p>

                    <p className="mt-1 text-gray-800">
                      {new Date(complaint.created_at).toLocaleString()}
                    </p>
                  </div>
                </div>

                <div className="mt-5">
                  <p className="text-sm font-medium text-gray-500">
                    Description
                  </p>

                  <p className="mt-1 text-gray-700">
                    {complaint.description}
                  </p>
                </div>

                <div className="mt-5 border-t border-gray-100 pt-4">
                  <p className="text-sm text-gray-500">
                    Last updated
                  </p>

                  <p className="mt-1 text-sm text-gray-700">
                    {new Date(complaint.updated_at).toLocaleString()}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
};

export default MyComplaints;