import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  Users as UsersIcon,
  Search,
  RefreshCw,
  ShieldCheck,
  UserRound,
  UserCheck,
  UserX,
  Mail,
  CalendarDays,
  AlertCircle,
  X,
} from 'lucide-react';
import { api } from '../services/api';

const colors = {
  background: 'var(--app-bg, #09090B)',
  card: 'var(--surface, #131318)',
  border: 'var(--border, #27272F)',
  purple: 'var(--purple, #8B5CF6)',
  purpleLight: 'var(--lavender, #A78BFA)',
  text: 'var(--text-primary, #F4F4F5)',
  secondary: 'var(--text-secondary, #D4D4D8)',
  muted: 'var(--muted, #A1A1AA)',
  green: '#34D399',
  red: '#F87171',
  blue: '#60A5FA',
  input: 'var(--input-bg, #0B0B0F)',
  subtle: 'var(--surface-secondary, #18181B)',
  hover: 'var(--hover-bg, rgba(139,92,246,0.055))',
};

function formatDate(value) {
  if (!value) return 'Not available';

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return 'Not available';

  return date.toLocaleDateString(undefined, {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

function initials(username = '') {
  return username.trim().slice(0, 2).toUpperCase() || 'U';
}

function StatusBadge({ active }) {
  const color = active ? colors.green : colors.red;

  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 6,
        borderRadius: 20,
        padding: '6px 10px',
        fontSize: 12,
        fontWeight: 600,
        color,
        background: active
          ? 'rgba(52,211,153,0.10)'
          : 'rgba(248,113,113,0.10)',
        whiteSpace: 'nowrap',
      }}
    >
      <span
        style={{
          width: 6,
          height: 6,
          borderRadius: '50%',
          background: color,
        }}
      />
      {active ? 'Active' : 'Inactive'}
    </span>
  );
}

function StatCard({ icon: Icon, label, value, color }) {
  return (
    <div
      style={{
        background: colors.card,
        border: `1px solid ${colors.border}`,
        borderRadius: 16,
        padding: 20,
        minWidth: 0,
        color: colors.text,
      }}
    >
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          gap: 12,
          marginBottom: 18,
        }}
      >
        <span style={{ color: colors.muted, fontSize: 13 }}>
          {label}
        </span>

        <span
          style={{
            display: 'grid',
            placeItems: 'center',
            width: 38,
            height: 38,
            borderRadius: 12,
            color,
            background: 'var(--lavender-bg, rgba(139,92,246,0.12))',
          }}
        >
          <Icon size={19} />
        </span>
      </div>

      <div
        style={{
          fontSize: 29,
          fontWeight: 750,
          color: colors.text,
          letterSpacing: '-0.8px',
        }}
      >
        {value}
      </div>
    </div>
  );
}

export default function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [roleFilter, setRoleFilter] = useState('all');
  const [selectedUser, setSelectedUser] = useState(null);

  const loadUsers = useCallback(async (isRefresh = false) => {
    if (isRefresh) {
      setRefreshing(true);
    } else {
      setLoading(true);
    }

    setError('');

    try {
      const response = await api.getUsers();

      const userList = Array.isArray(response)
        ? response
        : response?.users ?? response?.results ?? [];

      if (!Array.isArray(userList)) {
        throw new Error(
          'The backend returned an unexpected users response.'
        );
      }

      setUsers(userList);
    } catch (err) {
      setError(err.message || 'Unable to load registered users.');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    loadUsers();
  }, [loadUsers]);

  const filteredUsers = useMemo(() => {
    const query = search.trim().toLowerCase();

    return users.filter((user) => {
      const matchesSearch =
        !query ||
        String(user.id ?? '').includes(query) ||
        String(user.username ?? '').toLowerCase().includes(query) ||
        String(user.email ?? '').toLowerCase().includes(query);

      const matchesStatus =
        statusFilter === 'all' ||
        (statusFilter === 'active' && Boolean(user.is_active)) ||
        (statusFilter === 'inactive' && !user.is_active);

      const matchesRole =
        roleFilter === 'all' ||
        (roleFilter === 'admin' && Boolean(user.is_staff)) ||
        (roleFilter === 'citizen' && !user.is_staff);

      return matchesSearch && matchesStatus && matchesRole;
    });
  }, [users, search, statusFilter, roleFilter]);

  const activeUsers = users.filter(
    (user) => user.is_active
  ).length;

  const inactiveUsers = users.length - activeUsers;

  const adminUsers = users.filter(
    (user) => user.is_staff
  ).length;

  const inputStyle = {
    width: '100%',
    minWidth: 0,
    boxSizing: 'border-box',
    background: colors.input,
    border: `1px solid ${colors.border}`,
    color: colors.text,
    borderRadius: 10,
    padding: '11px 12px',
    outline: 'none',
    fontSize: 13,
  };

  const buttonStyle = {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
    border: `1px solid ${colors.border}`,
    background: colors.subtle,
    color: colors.text,
    borderRadius: 10,
    padding: '10px 13px',
    fontSize: 13,
    fontWeight: 600,
    cursor: 'pointer',
    whiteSpace: 'nowrap',
  };

  return (
    <div
      className="urbaneye-users-padding"
      style={{
        minHeight: '100%',
        background: colors.background,
        color: colors.text,
        padding: 28,
        boxSizing: 'border-box',
        display: 'flex',
        flexDirection: 'column',
        gap: 24,
      }}
    >
      <style>{`
        @keyframes urbaneye-spin {
          to { transform: rotate(360deg); }
        }

        .urbaneye-user-row {
          transition: background 150ms ease;
        }

        .urbaneye-user-row:hover {
          background: var(--hover-bg, rgba(139,92,246,0.055));
        }

        .urbaneye-user-details:hover {
          border-color: var(--purple, #8B5CF6) !important;
        }

        .urbaneye-users-padding input::placeholder {
          color: var(--muted, #A1A1AA);
          opacity: 0.85;
        }

        .urbaneye-users-padding select option {
          background: var(--surface, #131318);
          color: var(--text-primary, #F4F4F5);
        }

        @media (max-width: 700px) {
          .urbaneye-users-padding {
            padding: 16px !important;
          }
        }
      `}</style>

      {/* Page heading */}
      <div
        style={{
          display: 'flex',
          alignItems: 'flex-start',
          justifyContent: 'space-between',
          flexWrap: 'wrap',
          gap: 16,
        }}
      >
        <div>
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 10,
              marginBottom: 8,
            }}
          >
            <div
              style={{
                display: 'grid',
                placeItems: 'center',
                width: 42,
                height: 42,
                flexShrink: 0,
                borderRadius: 13,
                background: 'var(--lavender-bg, rgba(139,92,246,0.14))',
                color: colors.purpleLight,
              }}
            >
              <UsersIcon size={22} />
            </div>

            <h1
              style={{
                margin: 0,
                fontSize: 'clamp(23px, 3vw, 27px)',
                fontWeight: 750,
                letterSpacing: '-0.8px',
                color: colors.text,
              }}
            >
              User Management
            </h1>
          </div>

          <p
            style={{
              margin: 0,
              color: colors.muted,
              fontSize: 14,
              lineHeight: 1.6,
            }}
          >
            Manage and review registered UrbanEye accounts.
          </p>
        </div>

        <button
          type="button"
          onClick={() => loadUsers(true)}
          disabled={loading || refreshing}
          style={{
            ...buttonStyle,
            opacity: loading || refreshing ? 0.65 : 1,
            cursor: loading || refreshing ? 'wait' : 'pointer',
          }}
        >
          <RefreshCw
            size={15}
            style={{
              animation: refreshing
                ? 'urbaneye-spin 1s linear infinite'
                : 'none',
            }}
          />
          {refreshing ? 'Refreshing...' : 'Refresh users'}
        </button>
      </div>

      {/* Summary cards */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns:
            'repeat(auto-fit, minmax(min(100%, 175px), 1fr))',
          gap: 16,
        }}
      >
        <StatCard
          icon={UsersIcon}
          label="Total accounts"
          value={loading && users.length === 0 ? '—' : users.length}
          color={colors.purpleLight}
        />

        <StatCard
          icon={UserCheck}
          label="Active accounts"
          value={loading && users.length === 0 ? '—' : activeUsers}
          color={colors.green}
        />

        <StatCard
          icon={UserX}
          label="Inactive accounts"
          value={loading && users.length === 0 ? '—' : inactiveUsers}
          color={colors.red}
        />

        <StatCard
          icon={ShieldCheck}
          label="Staff accounts"
          value={loading && users.length === 0 ? '—' : adminUsers}
          color={colors.blue}
        />
      </div>

      {/* Registered users */}
      <section
        style={{
          background: colors.card,
          border: `1px solid ${colors.border}`,
          borderRadius: 16,
          overflow: 'hidden',
          minWidth: 0,
        }}
      >
        <div
          style={{
            padding: 20,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            flexWrap: 'wrap',
            gap: 14,
            borderBottom: `1px solid ${colors.border}`,
          }}
        >
          <div>
            <h2
              style={{
                margin: 0,
                fontSize: 16,
                fontWeight: 700,
                color: colors.text,
              }}
            >
              Registered accounts
            </h2>

            <p
              style={{
                color: colors.muted,
                fontSize: 12,
                margin: '6px 0 0',
              }}
            >
              Showing {filteredUsers.length} of {users.length} accounts
            </p>
          </div>

          <div
            style={{
              display: 'flex',
              flexWrap: 'wrap',
              gap: 10,
              flex: '1 1 420px',
              justifyContent: 'flex-end',
            }}
          >
            <div
              style={{
                position: 'relative',
                flex: '1 1 180px',
                maxWidth: 300,
                minWidth: 0,
              }}
            >
              <Search
                size={16}
                style={{
                  position: 'absolute',
                  top: 12,
                  left: 12,
                  color: colors.muted,
                  pointerEvents: 'none',
                }}
              />

              <input
                aria-label="Search users"
                placeholder="Search name, email or ID..."
                value={search}
                onChange={(event) => setSearch(event.target.value)}
                style={{
                  ...inputStyle,
                  paddingLeft: 37,
                }}
              />
            </div>

            <select
              aria-label="Filter account status"
              value={statusFilter}
              onChange={(event) => setStatusFilter(event.target.value)}
              style={{
                ...inputStyle,
                width: 'auto',
                minWidth: 120,
                flex: '0 1 auto',
              }}
            >
              <option value="all">All statuses</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>

            <select
              aria-label="Filter account role"
              value={roleFilter}
              onChange={(event) => setRoleFilter(event.target.value)}
              style={{
                ...inputStyle,
                width: 'auto',
                minWidth: 120,
                flex: '0 1 auto',
              }}
            >
              <option value="all">All roles</option>
              <option value="admin">Staff</option>
              <option value="citizen">Citizens</option>
            </select>
          </div>
        </div>

        {/* Error state */}
        {error && (
          <div
            role="alert"
            style={{
              margin: 20,
              padding: 15,
              borderRadius: 12,
              border: '1px solid rgba(248,113,113,0.3)',
              background: 'rgba(248,113,113,0.07)',
              display: 'flex',
              alignItems: 'flex-start',
              gap: 10,
            }}
          >
            <AlertCircle
              color={colors.red}
              size={19}
              style={{ flexShrink: 0 }}
            />

            <div style={{ flex: 1, minWidth: 0 }}>
              <div
                style={{
                  fontWeight: 650,
                  marginBottom: 5,
                  color: colors.text,
                }}
              >
                Couldn't load users
              </div>

              <div
                style={{
                  color: colors.muted,
                  fontSize: 13,
                  overflowWrap: 'anywhere',
                }}
              >
                {error}
              </div>

              <button
                type="button"
                onClick={() => loadUsers()}
                style={{ ...buttonStyle, marginTop: 12 }}
              >
                Try again
              </button>
            </div>
          </div>
        )}

        {/* Loading state */}
        {loading ? (
          <div
            style={{
              padding: 60,
              display: 'grid',
              placeItems: 'center',
              gap: 14,
              color: colors.muted,
              textAlign: 'center',
            }}
          >
            <RefreshCw
              size={24}
              color={colors.purpleLight}
              style={{
                animation: 'urbaneye-spin 1s linear infinite',
              }}
            />
            Loading registered accounts...
          </div>
        ) : !error && filteredUsers.length === 0 ? (
          /* Empty state */
          <div
            style={{
              padding: '60px 20px',
              display: 'grid',
              placeItems: 'center',
              textAlign: 'center',
            }}
          >
            <Search size={30} color={colors.muted} />

            <h3
              style={{
                margin: '15px 0 7px',
                fontSize: 16,
                color: colors.text,
              }}
            >
              No users found
            </h3>

            <p
              style={{
                margin: 0,
                color: colors.muted,
                fontSize: 13,
              }}
            >
              {users.length === 0
                ? 'Registered accounts will appear here when available.'
                : 'Try changing your search or filters.'}
            </p>
          </div>
        ) : !error ? (
          /* Users table */
          <div style={{ overflowX: 'auto' }}>
            <table
              style={{
                width: '100%',
                minWidth: 760,
                borderCollapse: 'collapse',
                textAlign: 'left',
              }}
            >
              <thead>
                <tr
                  style={{
                    background: 'var(--surface-secondary, #101015)',
                  }}
                >
                  {[
                    'User',
                    'Email address',
                    'Role',
                    'Status',
                    'Joined',
                    '',
                  ].map((heading, index) => (
                    <th
                      key={`${heading}-${index}`}
                      style={{
                        padding: '14px 18px',
                        color: colors.muted,
                        fontSize: 11,
                        fontWeight: 650,
                        textTransform: 'uppercase',
                        letterSpacing: '0.6px',
                        whiteSpace: 'nowrap',
                        borderBottom: `1px solid ${colors.border}`,
                      }}
                    >
                      {heading}
                    </th>
                  ))}
                </tr>
              </thead>

              <tbody>
                {filteredUsers.map((user) => (
                  <tr
                    className="urbaneye-user-row"
                    key={user.id}
                    style={{
                      borderBottom: `1px solid ${colors.border}`,
                    }}
                  >
                    <td style={{ padding: '15px 18px' }}>
                      <div
                        style={{
                          display: 'flex',
                          alignItems: 'center',
                          gap: 11,
                        }}
                      >
                        <div
                          style={{
                            width: 39,
                            height: 39,
                            flexShrink: 0,
                            display: 'grid',
                            placeItems: 'center',
                            borderRadius: 12,
                            background: 'var(--lavender-bg, rgba(139,92,246,0.15))',
                            color: colors.purpleLight,
                            fontSize: 12,
                            fontWeight: 750,
                          }}
                        >
                          {initials(user.username)}
                        </div>

                        <div>
                          <div
                            style={{
                              fontSize: 13,
                              fontWeight: 650,
                              color: colors.text,
                            }}
                          >
                            {user.username || 'Unnamed user'}
                          </div>

                          <div
                            style={{
                              fontSize: 11,
                              color: colors.muted,
                              marginTop: 4,
                            }}
                          >
                            ID #{user.id}
                          </div>
                        </div>
                      </div>
                    </td>

                    <td
                      style={{
                        padding: '15px 18px',
                        fontSize: 13,
                        color: colors.muted,
                      }}
                    >
                      <span
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: 7,
                        }}
                      >
                        <Mail size={14} />
                        {user.email || 'No email'}
                      </span>
                    </td>

                    <td style={{ padding: '15px 18px' }}>
                      <span
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: 6,
                          color: user.is_staff
                            ? colors.purpleLight
                            : colors.muted,
                          fontSize: 12,
                          fontWeight: 600,
                        }}
                      >
                        {user.is_staff ? (
                          <ShieldCheck size={15} />
                        ) : (
                          <UserRound size={15} />
                        )}

                        {user.is_staff ? 'Staff' : 'Citizen'}
                      </span>
                    </td>

                    <td style={{ padding: '15px 18px' }}>
                      <StatusBadge active={Boolean(user.is_active)} />
                    </td>

                    <td
                      style={{
                        padding: '15px 18px',
                        color: colors.muted,
                        fontSize: 12,
                        whiteSpace: 'nowrap',
                      }}
                    >
                      <span
                        style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: 7,
                        }}
                      >
                        <CalendarDays size={14} />
                        {formatDate(user.date_joined)}
                      </span>
                    </td>

                    <td style={{ padding: '15px 18px' }}>
                      <button
                        type="button"
                        className="urbaneye-user-details"
                        onClick={() => setSelectedUser(user)}
                        style={{
                          ...buttonStyle,
                          padding: '8px 11px',
                          fontSize: 12,
                        }}
                      >
                        View
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : null}

        {!loading && !error && users.length > 0 && (
          <div
            style={{
              padding: '14px 20px',
              color: colors.muted,
              fontSize: 12,
              borderTop: `1px solid ${colors.border}`,
            }}
          >
            Account information is read-only on this page.
          </div>
        )}
      </section>

      {/* User details modal */}
      {selectedUser && (
        <div
          onClick={() => setSelectedUser(null)}
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 1000,
            display: 'grid',
            placeItems: 'center',
            padding: 20,
            background: 'rgba(0,0,0,0.70)',
            backdropFilter: 'blur(7px)',
          }}
        >
          <section
            role="dialog"
            aria-modal="true"
            aria-labelledby="urbaneye-user-modal-title"
            onClick={(event) => event.stopPropagation()}
            style={{
              width: '100%',
              maxWidth: 440,
              maxHeight: '85vh',
              overflowY: 'auto',
              background: colors.card,
              color: colors.text,
              border: `1px solid ${colors.border}`,
              borderRadius: 20,
              padding: 24,
              boxSizing: 'border-box',
              boxShadow: '0 25px 80px rgba(0,0,0,0.35)',
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                gap: 12,
                marginBottom: 24,
              }}
            >
              <h2
                id="urbaneye-user-modal-title"
                style={{
                  margin: 0,
                  fontSize: 19,
                  color: colors.text,
                }}
              >
                Account details
              </h2>

              <button
                type="button"
                aria-label="Close account details"
                onClick={() => setSelectedUser(null)}
                style={{
                  ...buttonStyle,
                  padding: 8,
                }}
              >
                <X size={17} />
              </button>
            </div>

            <div
              style={{
                textAlign: 'center',
                marginBottom: 25,
              }}
            >
              <div
                style={{
                  width: 68,
                  height: 68,
                  margin: '0 auto 14px',
                  display: 'grid',
                  placeItems: 'center',
                  borderRadius: 22,
                  background: 'var(--lavender-bg, rgba(139,92,246,0.16))',
                  color: colors.purpleLight,
                  fontSize: 21,
                  fontWeight: 750,
                }}
              >
                {initials(selectedUser.username)}
              </div>

              <h3
                style={{
                  margin: '0 0 6px',
                  fontSize: 19,
                  color: colors.text,
                }}
              >
                {selectedUser.username || 'Unnamed user'}
              </h3>

              <div style={{ color: colors.muted, fontSize: 13 }}>
                Account ID #{selectedUser.id}
              </div>
            </div>

            {[
              ['Email address', selectedUser.email || 'Not provided'],
              ['Role', selectedUser.is_staff ? 'Staff' : 'Citizen'],
              [
                'Account status',
                selectedUser.is_active ? 'Active' : 'Inactive',
              ],
              ['Registration date', formatDate(selectedUser.date_joined)],
              [
                'Administrator',
                selectedUser.is_superuser ? 'Yes' : 'No',
              ],
            ].map(([label, value]) => (
              <div
                key={label}
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  gap: 16,
                  padding: '13px 0',
                  borderBottom: `1px solid ${colors.border}`,
                  fontSize: 13,
                }}
              >
                <span style={{ color: colors.muted }}>{label}</span>

                <span
                  style={{
                    color: colors.text,
                    fontWeight: 600,
                    textAlign: 'right',
                    overflowWrap: 'anywhere',
                  }}
                >
                  {value}
                </span>
              </div>
            ))}

            <button
              type="button"
              onClick={() => setSelectedUser(null)}
              style={{
                width: '100%',
                marginTop: 22,
                padding: 12,
                border: 0,
                borderRadius: 11,
                background: colors.purple,
                color: '#FFFFFF',
                fontSize: 13,
                fontWeight: 700,
                cursor: 'pointer',
              }}
            >
              Close details
            </button>
          </section>
        </div>
      )}
    </div>
  );
}
