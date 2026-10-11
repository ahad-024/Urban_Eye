import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import Splash from "../pages/Splash";
import Register from "../pages/Register";
import Login from "../pages/Login";
import AdminLogin from "../pages/AdminLogin";
import AdminDashboard from "../pages/AdminDashboard";
import AdminReports from "../pages/AdminReports";
import AdminComplaints from "../pages/AdminComplaints";
import Home from "../pages/Home";
import Dashboard from "../pages/Dashboard";
import CaptureImage from "../pages/CaptureImage";
import AIResult from "../pages/AIResult";
import CreateComplaint from "../pages/CreateComplaint";
import ComplaintSuccess from "../pages/ComplaintSuccess";
import MyComplaints from "../pages/MyComplaints";
import Reports from "../pages/Reports";
import Profile from "../pages/Profile";
import ReportDetails from "../pages/ReportDetails";
import ProtectedRoute from "./ProtectedRoute";

const AppRoutes = () => {
  return (
    <BrowserRouter>
      <Routes>

        <Route
          path="/"
          element={<Splash />}
        />

        <Route
          path="/register"
          element={<Register />}
        />

        <Route
          path="/login"
          element={<Login />}
        />


        <Route
          path="/admin-login"
          element={<AdminLogin />}
        />

        <Route
          path="/admin-dashboard"
          element={<AdminDashboard />}
        />

        <Route
          path="/admin-reports"
          element={<AdminReports />}
        />

        <Route
          path="/admin-complaints"
          element={<AdminComplaints />}
        />

        <Route
          path="/home"
          element={
            <ProtectedRoute>
              <Home />
            </ProtectedRoute>
          }
        />

        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          }
        />

        <Route
          path="/capture"
          element={
            <ProtectedRoute>
              <CaptureImage />
            </ProtectedRoute>
          }
        />

        <Route
          path="/analysis"
          element={
            <ProtectedRoute>
              <AIResult />
            </ProtectedRoute>
          }
        />

        <Route
          path="/create-complaint"
          element={
            <ProtectedRoute>
              <CreateComplaint />
            </ProtectedRoute>
          }
        />

        <Route
          path="/success"
          element={
            <ProtectedRoute>
              <ComplaintSuccess />
            </ProtectedRoute>
          }
        />

      
        <Route
          path="/complaints"
          element={
            <ProtectedRoute>
              <MyComplaints />
            </ProtectedRoute>
          }
        />

        <Route
          path="/reports"
          element={
            <ProtectedRoute>
              <Reports />
            </ProtectedRoute>
          }
        />

        <Route
          path="/reports/:id"
          element={
            <ProtectedRoute>
              <ReportDetails />
            </ProtectedRoute>
          }
        />

        <Route
          path="/profile"
          element={
            <ProtectedRoute>
              <Profile />
            </ProtectedRoute>
          }
        />


        <Route
          path="*"
          element={<Navigate to="/" replace />}
        />

      </Routes>
    </BrowserRouter>
  );
};

export default AppRoutes;