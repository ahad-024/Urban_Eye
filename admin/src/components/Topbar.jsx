import { Bell, Search, ChevronDown } from 'lucide-react';
import { useLocation } from 'react-router-dom';

const pageTitles = {
  '/': 'Overview',
  '/reports': 'Civic Reports',
  '/complaints': 'Complaints',
  '/users': 'User Management',
  '/settings': 'Settings',
};

export default function Topbar() {
  const location = useLocation();
  const title = pageTitles[location.pathname] || 'UrbanEye Admin';

  return (
    <header
      className="topbar"
      style={{
        background: 'var(--topbar-bg, var(--app-bg, #000))',
        color: 'var(--text-primary, #f5f3ff)',
        borderBottom: '1px solid var(--border, rgba(255,255,255,0.08))',
        transition:
          'background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease',
      }}
    >
      <div className="topbar-heading">
        <span
          className="eyebrow"
          style={{ color: 'var(--muted, #92909d)' }}
        >
          WORKSPACE / ADMIN
        </span>

        <h2 style={{ color: 'var(--text-primary, #f5f3ff)' }}>
          {title}
        </h2>
      </div>

      <div className="topbar-actions">
        <label
          className="search-box"
          style={{
            background: 'var(--input-bg, #121214)',
            border: '1px solid var(--border, rgba(255,255,255,0.08))',
            color: 'var(--text-secondary, #c4c0ce)',
          }}
        >
          <Search size={17} />

          <input
            type="search"
            placeholder="Search workspace..."
            aria-label="Search workspace"
            style={{
              background: 'transparent',
              color: 'var(--text-primary, #f5f3ff)',
              border: 'none',
              outline: 'none',
            }}
          />

          <kbd
            style={{
              background: 'var(--surface-secondary, #1c1c1e)',
              color: 'var(--muted, #92909d)',
              border: '1px solid var(--border, rgba(255,255,255,0.08))',
            }}
          >
            ⌘ K
          </kbd>
        </label>

        <button
          type="button"
          className="icon-button"
          aria-label="Notifications"
          title="Notifications"
          style={{
            background: 'var(--surface, #111113)',
            color: 'var(--text-secondary, #c4c0ce)',
            border: '1px solid var(--border, rgba(255,255,255,0.08))',
          }}
        >
          <Bell size={19} />
          <span className="notification-dot" />
        </button>

        <div
          className="topbar-profile"
          style={{ color: 'var(--text-primary, #f5f3ff)' }}
        >
          <div
            className="avatar"
            style={{
              background: 'var(--avatar-bg, rgba(124,58,237,0.18))',
              color: 'var(--purple, #a78bfa)',
              border: '1px solid var(--border, rgba(255,255,255,0.08))',
            }}
          >
            A
          </div>

          <div className="profile-copy">
            <strong style={{ color: 'var(--text-primary, #f5f3ff)' }}>
              Administrator
            </strong>

            <span style={{ color: 'var(--muted, #92909d)' }}>
              System Admin
            </span>
          </div>

          <ChevronDown
            size={15}
            className="profile-chevron"
            color="var(--muted, #92909d)"
          />
        </div>
      </div>
    </header>
  );
}