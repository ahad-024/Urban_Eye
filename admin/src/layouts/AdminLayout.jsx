import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from '../components/Sidebar.jsx';
import Topbar from '../components/Topbar.jsx';

export default function AdminLayout() {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <div
      className={`admin-shell ${
        collapsed ? 'admin-shell-collapsed' : ''
      }`}
      style={{
        minHeight: '100vh',
        width: '100%',
        background: 'var(--app-bg, #000000)',
        color: 'var(--text-primary, #f5f3ff)',
        transition: 'background-color 0.2s ease, color 0.2s ease',
      }}
    >
      <Sidebar
        collapsed={collapsed}
        onToggle={() => setCollapsed((value) => !value)}
      />

      <div
        className={`admin-main ${
          collapsed ? 'admin-main-collapsed' : ''
        }`}
        style={{
          minHeight: '100vh',
          background: 'var(--app-bg, #000000)',
          color: 'var(--text-primary, #f5f3ff)',
          transition: 'background-color 0.2s ease, color 0.2s ease',
        }}
      >
        <Topbar />

        <main
          className="admin-content"
          style={{
            flex: 1,
            width: '100%',
            color: 'var(--text-primary, #f5f3ff)',
          }}
        >
          <Outlet />
        </main>

        <footer
          className="admin-footer"
          style={{
            color: 'var(--muted, #92909d)',
            borderTopColor: 'var(--border, rgba(255,255,255,0.08))',
          }}
        >
          <span>© {new Date().getFullYear()} UrbanEye</span>
          <span>AI-Powered Civic Issue Intelligence</span>
        </footer>
      </div>
    </div>
  );
}
