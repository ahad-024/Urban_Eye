import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import {FaCamera,FaChartLine,FaFileAlt,FaMapMarkerAlt,FaRobot,FaRoad,FaTrash,FaLightbulb,FaTint,FaClipboardList} from "react-icons/fa";
import { toast } from "react-toastify";
import api from "../api/axios";
import MainLayout from "../layouts/MainLayout";
import Card from "../components/Card";
import StatCard from "../components/StatCard";

const Home = () => {
  const navigate = useNavigate();

  const [stats, setStats] = useState({
    totalReports: 0,
    resolvedReports: 0,
  });

  const [loading, setLoading] = useState(true);

  const issues = [
    {
      title: "Road Damage",
      icon: FaRoad,
    },
    {
      title: "Garbage",
      icon: FaTrash,
    },
    {
      title: "Street Light",
      icon: FaLightbulb,
    },
    {
      title: "Water Overflow",
      icon: FaTint,
    },
  ];

  useEffect(() => {
    const fetchDashboardStats = async () => {
      try {
        const accessToken = localStorage.getItem("access_token");

        if (!accessToken) {
          navigate("/login");
          return;
        }

        const response = await api.get("dashboard/stats/", {
          headers: {
            Authorization: `Bearer ${accessToken}`,
          },
        });

        setStats({
          totalReports: response.data.total_reports || 0,
          resolvedReports: response.data.resolved_reports || 0,
        });
      } catch (error) {
        console.error(
          "Failed to load dashboard stats:",
          error.response?.data || error.message
        );

        if (error.response?.status === 401) {
          localStorage.removeItem("access_token");
          localStorage.removeItem("refresh_token");
          localStorage.removeItem("user");

          navigate("/login");
          return;
        }

        toast.error("Unable to load dashboard statistics.");
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardStats();
  }, [navigate]);

  return (
    <MainLayout>
      <div className="bg-gradient-to-r from-blue-600 to-cyan-500 rounded-3xl p-6 text-white shadow-xl mb-8">
        <div className="flex items-center gap-4">
          <FaRobot className="text-5xl" />

          <div>
            <h1 className="text-2xl font-bold">
              UrbanEye AI
            </h1>

            <p className="text-blue-100 mt-1">
              Detect and report city problems instantly
            </p>
          </div>
        </div>

        <Link
          to="/capture"
          className="mt-6 bg-white text-blue-600 rounded-2xl py-3 px-6 font-bold inline-flex items-center gap-3 hover:scale-105 transition"
        >
          <FaCamera />
          Analyze Issue
        </Link>
      </div>

      
      <div className="grid grid-cols-2 gap-4 mb-8">
        <StatCard
          title="Reports"
          value={loading ? "..." : stats.totalReports}
          icon={FaFileAlt}
        />

        <StatCard
          title="Resolved"
          value={loading ? "..." : stats.resolvedReports}
          icon={FaChartLine}
          color="text-green-600"
        />
      </div>

      
      <h2 className="text-2xl font-bold mb-5">
        Report Issues
      </h2>

      <div className="grid grid-cols-2 gap-4">
        {issues.map((item) => {
          const Icon = item.icon;

          return (
            <Link
              to="/capture"
              key={item.title}
            >
              <Card className="hover:-translate-y-1 transition cursor-pointer h-full">
                <Icon className="text-blue-600 text-4xl" />

                <h3 className="mt-4 font-semibold">
                  {item.title}
                </h3>
              </Card>
            </Link>
          );
        })}
      </div>

    
      <Card className="mt-8">
        <button
          onClick={() => navigate("/complaints")}
          className="w-full text-left"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-100">
                <FaClipboardList className="text-blue-600 text-xl" />
              </div>

              <div>
                <h3 className="font-bold text-lg">
                  My Complaints
                </h3>

                <p className="text-gray-500 text-sm mt-1">
                  Track the status of your submitted complaints
                </p>
              </div>
            </div>

            <span className="text-blue-600 font-semibold">
              View →
            </span>
          </div>
        </button>
      </Card>

      
      <Card className="mt-8">
        <div className="flex items-center gap-3">
          <FaMapMarkerAlt className="text-blue-600 text-2xl" />

          <div>
            <h3 className="font-bold">
              Current Location
            </h3>

            <p className="text-gray-500">
              Hyderabad, Sindh
            </p>
          </div>
        </div>
      </Card>
    </MainLayout>
  );
};

export default Home;