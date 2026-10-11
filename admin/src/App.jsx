
import { useEffect, useState } from 'react';
import {
  BrowserRouter,
  Routes,
  Route,
  Navigate,
} from 'react-router-dom';

import AdminLayout from './layouts/AdminLayout';
import AdminLogin from './pages/AdminLogin';
import Dashboard from './pages/Dashboard';
import Reports from './pages/Reports';
import Complaints from './pages/Complaints';
import Users from './pages/Users';
import Settings from './pages/Settings';

import { authStorage } from './services/api';

const THEME_STORAGE_KEY = 'urbaneye_admin_preferences';

function getInitialTheme() {
  try {
    const saved = localStorage.getItem(THEME_STORAGE_KEY);

    if (saved) {
      const preferences = JSON.parse(saved);

      if (typeof preferences.darkMode === 'boolean') {
        return preferences.darkMode ? 'dark' : 'light';
      }
    }
  } catch (error) {
    console.error('Unable to read saved theme preference:', error);
  }

  return 'dark';
}

function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  document.documentElement.style.colorScheme = theme;
  document.body?.setAttribute('data-theme', theme);
}

function ThemeInitializer({ children }) {
  const [theme] = useState(getInitialTheme);

  useEffect(() => {
    applyTheme(theme);
  }, [theme]);

  return children;
}

function ProtectedRoute({ children }) {
  const token = authStorage.getAccessToken();
  const user = authStorage.getUser();

  if (!token || !user?.is_staff) {
    return <Navigate to="/login" replace />;
  }

  return children;
}

function LoginRoute() {
  const token = authStorage.getAccessToken();
  const user = authStorage.getUser();

  if (token && user?.is_staff) {
    return <Navigate to="/" replace />;
  }

  return <AdminLogin />;
}

export default function App() {
  return (
    <ThemeInitializer>
      <BrowserRouter>
        <Routes>
          {/* Login without the admin sidebar */}
          <Route
            path="/login"
            element={<LoginRoute />}
          />

          {/* Protected admin workspace */}
          <Route
            element={
              <ProtectedRoute>
                <AdminLayout />
              </ProtectedRoute>
            }
          >
            <Route path="/" element={<Dashboard />} />
            <Route path="/reports" element={<Reports />} />
            <Route path="/complaints" element={<Complaints />} />
            <Route path="/users" element={<Users />} />
            <Route path="/settings" element={<Settings />} />
          </Route>

          {/* Redirect unknown routes */}
          <Route
            path="*"
            element={<Navigate to="/" replace />}
          />
        </Routes>
      </BrowserRouter>
    </ThemeInitializer>
  );
}
