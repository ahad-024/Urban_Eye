import { useState, useEffect } from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import {
  LayoutDashboard,
  FileText,
  MessageSquare,
  Users,
  Settings,
  ShieldCheck,
  Activity,
  ChevronLeft,
  LogOut,
  LoaderCircle,
  X,
  ShieldAlert,
} from 'lucide-react';

import { api, authStorage } from '../services/api';

const navigation = [
  { label: 'Overview', path: '/', icon: LayoutDashboard },
  { label: 'Reports', path: '/reports', icon: FileText },
  { label: 'Complaints', path: '/complaints', icon: MessageSquare },
  { label: 'Users', path: '/users', icon: Users },
  { label: 'Settings', path: '/settings', icon: Settings },
];

export default function Sidebar({ collapsed, onToggle }) {
  const navigate = useNavigate();
  const [loggingOut, setLoggingOut] = useState(false);
  const [showLogoutModal, setShowLogoutModal] = useState(false);

  useEffect(() => {
    if (!showLogoutModal) return;

    function handleKeyDown(event) {
      if (event.key === 'Escape' && !loggingOut) {
        setShowLogoutModal(false);
      }
    }

    document.addEventListener('keydown', handleKeyDown);

    return () => {
      document.removeEventListener('keydown', handleKeyDown);
    };
  }, [showLogoutModal, loggingOut]);

  async function handleLogout() {
    if (loggingOut) return;

    setLoggingOut(true);

    const refreshToken = authStorage.getRefreshToken();

    try {
      if (refreshToken) {
        await api.logout(refreshToken);
      }
    } catch (error) {
      console.error('Server logout request failed:', error);
    } finally {
      authStorage.clearSession();
      setShowLogoutModal(false);
      navigate('/login', { replace: true });
    }
  }

  return (
    <>
      <aside
        className={`sidebar ${collapsed ? 'sidebar-collapsed' : ''}`}
        style={{
          background: 'var(--sidebar-bg, var(--surface, #111113))',
          color: 'var(--text-primary, #f5f3ff)',
          borderRight: '1px solid var(--border, rgba(255,255,255,0.08))',
          transition:
            'background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease',
        }}
      >
        <div className="sidebar-brand">
          <div className="brand-icon">
            <ShieldCheck size={23} />
          </div>

          {!collapsed && (
            <div className="brand-copy">
              <strong>UrbanEye</strong>
              <span>ADMIN CONSOLE</span>
            </div>
          )}

          <button
            type="button"
            className="sidebar-toggle"
            onClick={onToggle}
            aria-label="Toggle sidebar"
            title={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
          >
            <ChevronLeft size={17} />
          </button>
        </div>

        <div
          className="sidebar-section-label"
          style={{ color: 'var(--muted, #92909d)' }}
        >
          {!collapsed && 'WORKSPACE'}
        </div>

        <nav className="sidebar-nav">
          {navigation.map(({ label, path, icon: Icon }) => (
            <NavLink
              key={path}
              to={path}
              end={path === '/'}
              title={collapsed ? label : undefined}
              className={({ isActive }) =>
                `sidebar-link ${isActive ? 'active' : ''}`
              }
              style={({ isActive }) => ({
                color: isActive
                  ? 'var(--purple, #7c3aed)'
                  : 'var(--text-secondary, #c4c0ce)',
                background: isActive
                  ? 'var(--active-nav-bg, rgba(124,58,237,0.12))'
                  : 'transparent',
                borderColor: isActive
                  ? 'var(--active-nav-border, rgba(124,58,237,0.22))'
                  : 'transparent',
                transition:
                  'background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease',
              })}
            >
              <Icon size={19} strokeWidth={1.8} />
              {!collapsed && <span>{label}</span>}
            </NavLink>
          ))}
        </nav>

        {!collapsed && (
          <div
            className="sidebar-status"
            style={{
              background: 'var(--surface-secondary, #1c1c1e)',
              border: '1px solid var(--border, rgba(255,255,255,0.08))',
              color: 'var(--text-primary, #f5f3ff)',
            }}
          >
            <div className="status-icon">
              <Activity size={18} />
            </div>

            <div>
              <strong>UrbanEye System</strong>
              <span>
                <i /> Admin workspace
              </span>
            </div>
          </div>
        )}

        <div
          className="sidebar-logout"
          style={{
            marginTop: 'auto',
            padding: collapsed ? '12px 8px' : '12px',
            borderTop: '1px solid var(--border, rgba(255,255,255,0.08))',
          }}
        >
          <button
            type="button"
            onClick={() => setShowLogoutModal(true)}
            disabled={loggingOut}
            title={collapsed ? 'Logout' : undefined}
            aria-label="Logout"
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: collapsed ? 'center' : 'flex-start',
              gap: 12,
              width: '100%',
              minHeight: 44,
              padding: 12,
              borderRadius: 10,
              border: '1px solid rgba(239,68,68,0.22)',
              background: 'var(--logout-bg, rgba(239,68,68,0.07))',
              color: 'var(--danger-text, #F87171)',
              fontSize: 14,
              fontWeight: 600,
              cursor: loggingOut ? 'wait' : 'pointer',
              opacity: loggingOut ? 0.65 : 1,
              transition: 'background-color 0.2s ease, border-color 0.2s ease',
            }}
          >
            <LogOut size={19} />
            {!collapsed && <span>Logout</span>}
          </button>
        </div>
      </aside>

      {showLogoutModal && (
        <div
          onMouseDown={(event) => {
            if (event.target === event.currentTarget && !loggingOut) {
              setShowLogoutModal(false);
            }
          }}
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 9999,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            padding: 20,
            background: 'rgba(0,0,0,0.68)',
            backdropFilter: 'blur(8px)',
          }}
        >
          <div
            role="dialog"
            aria-modal="true"
            aria-labelledby="logout-modal-title"
            aria-describedby="logout-modal-description"
            style={{
              width: '100%',
              maxWidth: 410,
              padding: 28,
              position: 'relative',
              background: 'var(--surface, #111113)',
              border: '1px solid var(--border, rgba(139,92,246,0.3))',
              borderRadius: 22,
              boxShadow: '0 25px 100px rgba(0,0,0,0.3)',
              color: 'var(--text-primary, #F4F4F5)',
              fontFamily: 'Inter, system-ui, sans-serif',
              animation: 'urbanEyeModalIn 180ms ease-out',
            }}
          >
            <button
              type="button"
              onClick={() => setShowLogoutModal(false)}
              disabled={loggingOut}
              aria-label="Close logout confirmation"
              style={{
                position: 'absolute',
                top: 17,
                right: 17,
                display: 'grid',
                placeItems: 'center',
                width: 34,
                height: 34,
                border: '1px solid var(--border, #292930)',
                borderRadius: 10,
                background: 'var(--surface-secondary, #1c1c1e)',
                color: 'var(--text-secondary, #A1A1AA)',
                cursor: loggingOut ? 'wait' : 'pointer',
              }}
            >
              <X size={17} />
            </button>

            <div
              style={{
                width: 58,
                height: 58,
                display: 'grid',
                placeItems: 'center',
                borderRadius: 18,
                background: 'linear-gradient(135deg, #3B1B70, #25113F)',
                border: '1px solid rgba(167,139,250,0.25)',
                marginBottom: 22,
              }}
            >
              <ShieldAlert size={27} color="#C4B5FD" />
            </div>

            <div
              style={{
                fontSize: 11,
                fontWeight: 800,
                letterSpacing: 2,
                color: 'var(--lavender, #A78BFA)',
                marginBottom: 9,
              }}
            >
              END ADMIN SESSION
            </div>

            <h2
              id="logout-modal-title"
              style={{
                margin: '0 0 12px',
                fontSize: 25,
                fontWeight: 750,
                letterSpacing: '-0.6px',
                color: 'var(--text-primary, #F4F4F5)',
              }}
            >
              Ready to leave?
            </h2>

            <p
              id="logout-modal-description"
              style={{
                color: 'var(--text-secondary, #A1A1AA)',
                fontSize: 14,
                lineHeight: 1.8,
                margin: '0 0 27px',
              }}
            >
              Are you sure you want to log out of UrbanEye Admin? You will need
              to sign in again to access your dashboard.
            </p>

            <div
              style={{
                display: 'flex',
                flexDirection: 'column',
                gap: 10,
              }}
            >
              <button
                type="button"
                onClick={handleLogout}
                disabled={loggingOut}
                style={{
                  display: 'flex',
                  justifyContent: 'center',
                  alignItems: 'center',
                  gap: 9,
                  minHeight: 47,
                  border: 'none',
                  borderRadius: 12,
                  background: 'linear-gradient(100deg, #7C3AED, #6D28D9)',
                  color: '#FFFFFF',
                  fontSize: 14,
                  fontWeight: 700,
                  cursor: loggingOut ? 'wait' : 'pointer',
                  boxShadow: '0 7px 24px rgba(124,58,237,0.23)',
                  opacity: loggingOut ? 0.7 : 1,
                }}
              >
                {loggingOut ? (
                  <LoaderCircle size={18} className="animate-spin" />
                ) : (
                  <LogOut size={18} />
                )}
                {loggingOut ? 'Logging out...' : 'Yes, log me out'}
              </button>

              <button
                type="button"
                onClick={() => setShowLogoutModal(false)}
                disabled={loggingOut}
                style={{
                  minHeight: 45,
                  border: '1px solid var(--border, #303038)',
                  borderRadius: 12,
                  background: 'var(--surface-secondary, #1A1A1F)',
                  color: 'var(--text-primary, #D4D4D8)',
                  fontSize: 14,
                  fontWeight: 600,
                  cursor: loggingOut ? 'wait' : 'pointer',
                }}
              >
                Stay logged in
              </button>
            </div>

            <div
              style={{
                marginTop: 20,
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                gap: 7,
                color: 'var(--muted, #71717A)',
                fontSize: 11,
              }}
            >
              <ShieldCheck size={14} />
              Your admin session is protected
            </div>
          </div>

          <style>
            {`
              @keyframes urbanEyeModalIn {
                from {
                  opacity: 0;
                  transform: translateY(8px) scale(0.98);
                }
                to {
                  opacity: 1;
                  transform: translateY(0) scale(1);
                }
              }
            `}
          </style>
        </div>
      )}
    </>
  );
}