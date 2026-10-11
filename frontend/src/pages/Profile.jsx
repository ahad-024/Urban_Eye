import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {FaUserCircle,FaEnvelope,FaMapMarkerAlt,FaUserGraduate,FaChartBar,FaCheckCircle,FaClock,FaEdit,FaSignOutAlt,FaIdBadge,FaSave,FaTimes} from "react-icons/fa";
import { toast } from "react-toastify";
import api from "../api/axios";
import MainLayout from "../layouts/MainLayout";
import PageHeader from "../components/PageHeader";
import Card from "../components/Card";
import StatCard from "../components/StatCard";
import Badge from "../components/Badge";
import Button from "../components/Button";

const Profile = () => {
  const navigate = useNavigate();

  const [user, setUser] = useState(null);

  const [reportStats, setReportStats] = useState({
    total: 0,
    resolved: 0,
    pending: 0,
  });

  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);

  const [editData, setEditData] = useState({
    username: "",
    email: "",
  });

  
  useEffect(() => {
    const fetchProfileData = async () => {
      try {
        const accessToken = localStorage.getItem("access_token");

        if (!accessToken) {
          navigate("/login");
          return;
        }

        const headers = {
          Authorization: `Bearer ${accessToken}`,
        };

        
        const profileResponse = await api.get(
          "accounts/profile/",
          { headers }
        );

        const currentUser = profileResponse.data;

        setUser(currentUser);

        setEditData({
          username: currentUser.username || "",
          email: currentUser.email || "",
        });

        
        localStorage.setItem(
          "user",
          JSON.stringify(currentUser)
        );

      
        const reportsResponse = await api.get(
          "reports/",
          { headers }
        );

        const reports = reportsResponse.data;

        const resolved = reports.filter(
          (report) => report.status === "resolved"
        ).length;

        const pending = reports.filter(
          (report) => report.status === "pending"
        ).length;

        setReportStats({
          total: reports.length,
          resolved,
          pending,
        });
      } catch (error) {
        console.error(
          "Failed to load profile:",
          error.response?.data || error.message
        );

        if (error.response?.status === 401) {
          localStorage.removeItem("access_token");
          localStorage.removeItem("refresh_token");
          localStorage.removeItem("user");

          navigate("/login");
        }
      } finally {
        setLoading(false);
      }
    };

    fetchProfileData();
  }, [navigate]);


  const handleEdit = () => {
    setEditData({
      username: user?.username || "",
      email: user?.email || "",
    });

    setEditing(true);
  };

  
  const handleChange = (e) => {
    setEditData({
      ...editData,
      [e.target.name]: e.target.value,
    });
  };

  
  const handleCancel = () => {
    setEditData({
      username: user?.username || "",
      email: user?.email || "",
    });

    setEditing(false);
  };

  
  const handleSave = async () => {
    if (!editData.username.trim()) {
      toast.error("Username is required.");
      return;
    }

    if (!editData.email.trim()) {
      toast.error("Email is required.");
      return;
    }

    try {
      setSaving(true);

      const accessToken =
        localStorage.getItem("access_token");

      if (!accessToken) {
        navigate("/login");
        return;
      }

      const response = await api.patch(
        "accounts/profile/",
        {
          username: editData.username.trim(),
          email: editData.email.trim(),
        },
        {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        }
      );

      const updatedUser = response.data;

      setUser(updatedUser);

      setEditData({
        username: updatedUser.username,
        email: updatedUser.email,
      });

    
      localStorage.setItem(
        "user",
        JSON.stringify(updatedUser)
      );

      setEditing(false);

      toast.success("Profile updated successfully.");
    } catch (error) {
      console.error(
        "Profile update failed:",
        error.response?.data || error.message
      );

      if (error.response?.status === 401) {
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");
        localStorage.removeItem("user");

        navigate("/login");
        return;
      }

      const backendError = error.response?.data;

      if (backendError?.email) {
        toast.error(
          Array.isArray(backendError.email)
            ? backendError.email[0]
            : backendError.email
        );
      } else if (backendError?.username) {
        toast.error(
          Array.isArray(backendError.username)
            ? backendError.username[0]
            : backendError.username
        );
      } else if (backendError?.detail) {
        toast.error(backendError.detail);
      } else {
        toast.error(
          "Failed to update profile. Please try again."
        );
      }
    } finally {
      setSaving(false);
    }
  };

  
  const handleLogout = async () => {
    try {
      const accessToken =
        localStorage.getItem("access_token");

      const refreshToken =
        localStorage.getItem("refresh_token");

      if (refreshToken) {
        await api.post(
          "accounts/logout/",
          {
            refresh: refreshToken,
          },
          {
            headers: {
              Authorization: `Bearer ${accessToken}`,
            },
          }
        );
      }

      toast.success("Logged out successfully.");
    } catch (error) {
      console.error(
        "Logout failed:",
        error.response?.data || error.message
      );
    } finally {
      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      localStorage.removeItem("user");

      navigate("/login");
    }
  };

  if (loading) {
    return (
      <MainLayout>
        <div className="flex justify-center items-center py-20">
          <p className="text-gray-500">
            Loading profile...
          </p>
        </div>
      </MainLayout>
    );
  }

  const profile = {
    name: user?.username || "Guest User",
    email: user?.email || "No Email",
    location: "Hyderabad, Sindh",
    role: "Citizen",
    userId: user ? `UE-${user.id}` : "N/A",
  };

  return (
    <MainLayout>
      <PageHeader
        title="My Profile"
        backTo="/home"
      />

    
      <Card
        maxWidth="max-w-4xl"
        className="mx-auto text-center"
      >
        <div className="relative inline-block">
          <FaUserCircle className="text-9xl text-blue-600 mx-auto" />

          {!editing && (
            <button
              onClick={handleEdit}
              className="absolute bottom-2 right-0 bg-blue-600 text-white rounded-full p-2 hover:bg-blue-700 transition"
            >
              <FaEdit />
            </button>
          )}
        </div>

        {!editing ? (
          <>
            <h2 className="text-3xl font-bold mt-5">
              {profile.name}
            </h2>

            <div className="mt-3">
              <Badge type="info">
                {profile.role}
              </Badge>
            </div>

            <div className="space-y-4 mt-8 text-left">
              <div className="flex items-center gap-3">
                <FaEnvelope className="text-blue-600" />
                <span>{profile.email}</span>
              </div>

              <div className="flex items-center gap-3">
                <FaMapMarkerAlt className="text-blue-600" />
                <span>{profile.location}</span>
              </div>

              <div className="flex items-center gap-3">
                <FaIdBadge className="text-blue-600" />
                <span>{profile.userId}</span>
              </div>

              <div className="flex items-center gap-3">
                <FaUserGraduate className="text-blue-600" />
                <span>{profile.role}</span>
              </div>
            </div>
          </>
        ) : (
          
          <div className="mt-8 text-left space-y-5">

            <div>
              <label className="font-semibold text-gray-700">
                Username
              </label>

              <input
                type="text"
                name="username"
                value={editData.username}
                onChange={handleChange}
                className="w-full mt-2 border border-gray-300 rounded-xl p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter username"
              />
            </div>

            <div>
              <label className="font-semibold text-gray-700">
                Email
              </label>

              <input
                type="email"
                name="email"
                value={editData.email}
                onChange={handleChange}
                className="w-full mt-2 border border-gray-300 rounded-xl p-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter email"
              />
            </div>

            <div className="grid grid-cols-2 gap-4">

              <Button
                variant="secondary"
                onClick={handleCancel}
                disabled={saving}
              >
                <FaTimes className="inline mr-2" />
                Cancel
              </Button>

              <Button
                onClick={handleSave}
                disabled={saving}
              >
                <FaSave className="inline mr-2" />
                {saving
                  ? "Saving..."
                  : "Save Changes"}
              </Button>

            </div>
          </div>
        )}
      </Card>

      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5 mt-8">

        <StatCard
          title="Total Reports"
          value={reportStats.total}
          icon={FaChartBar}
          color="text-blue-600"
        />

        <StatCard
          title="Resolved"
          value={reportStats.resolved}
          icon={FaCheckCircle}
          color="text-green-600"
        />

        <StatCard
          title="Pending"
          value={reportStats.pending}
          icon={FaClock}
          color="text-yellow-500"
        />

      </div>

      
      <Card
        maxWidth="max-w-4xl"
        className="mx-auto mt-8"
      >
        <h2 className="text-2xl font-bold mb-6">
          Account
        </h2>

        <div className="space-y-4">

          {!editing && (
            <Button
              variant="secondary"
              onClick={handleEdit}
            >
              <FaEdit className="inline mr-2" />
              Edit Profile
            </Button>
          )}

          <Button
            variant="danger"
            onClick={handleLogout}
            disabled={saving}
          >
            <FaSignOutAlt className="inline mr-2" />
            Logout
          </Button>

        </div>
      </Card>

    </MainLayout>
  );
};

export default Profile;
