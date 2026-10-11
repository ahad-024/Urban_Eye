import { useCallback, useEffect, useState } from 'react';
import {
  Activity,
  AlertCircle,
  CheckCircle2,
  Clock3,
  Users,
  RefreshCw,
  TrendingUp,
  ShieldCheck,
} from 'lucide-react';
import { api } from '../services/api';

const COLORS = {
  purple: '#7C3AED',
  lavender: 'var(--lavender, #B78BEA)',
  green: '#4ADE80',
  orange: '#FBBF24',
  red: '#FB7185',
  blue: '#60A5FA',
};

const ISSUE_LABELS = {
  garbage: 'Garbage',
  pothole: 'Potholes',
  road_crack: 'Road cracks',
  street_light: 'Street lights',
  water_overflow: 'Water overflow',
};

const STAT_CARDS = [
  {
    key: 'total_reports',
    title: 'Total Reports',
    icon: Activity,
    color: COLORS.lavender,
    description: 'All submitted civic reports',
  },
  {
    key: 'pending_reports',
    title: 'Pending Reports',
    icon: Clock3,
    color: COLORS.orange,
    description: 'Awaiting resolution',
  },
  {
    key: 'resolved_reports',
    title: 'Resolved Reports',
    icon: CheckCircle2,
    color: COLORS.green,
    description: 'Successfully resolved',
  },
  {
    key: 'active_users',
    title: 'Active Users',
    icon: Users,
    color: COLORS.blue,
    description: 'Registered active accounts',
  },
];

const cardStyle = {
  background: 'var(--surface, #141416)',
  color: 'var(--text-primary, #F7F5FA)',
  border: '1px solid var(--border, #29272F)',
  borderRadius: 18,
  transition:
    'background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease',
};

const formatNumber = (value) =>
  Number(value ?? 0).toLocaleString();

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const loadDashboard = useCallback(async () => {
    setLoading(true);
    setError('');

    try {
      const data = await api.getDashboardStats();
      setStats(data);
    } catch (err) {
      setError(err.message || 'Unable to load dashboard statistics.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadDashboard();
  }, [loadDashboard]);

  const issueStatistics = stats?.issue_statistics ?? {};

  const issueEntries = Object.entries(ISSUE_LABELS).map(
    ([key, label]) => ({
      key,
      label,
      value: Number(issueStatistics[key] ?? 0),
    })
  );

  const maximumIssueCount = Math.max(
    1,
    ...issueEntries.map((item) => item.value)
  );

  const totalReports = Number(stats?.total_reports ?? 0);
  const resolvedReports = Number(stats?.resolved_reports ?? 0);

  const resolutionRate =
    totalReports > 0
      ? Math.round((resolvedReports / totalReports) * 100)
      : 0;

  const mutedText = {
    color: 'var(--muted, #92909D)',
  };

  const headingText = {
    color: 'var(--text-primary, #F7F5FA)',
  };

  const subtleSurface = {
    background: 'var(--surface-secondary, #1C1C1E)',
    border: '1px solid var(--border, #29272F)',
  };

  return (
    <section
      style={{
        color: 'var(--text-primary, #F7F5FA)',
        display: 'flex',
        flexDirection: 'column',
        gap: 28,
        paddingBottom: 24,
      }}
    >
      {/* Page heading */}
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          flexWrap: 'wrap',
          gap: 16,
        }}
      >
        <div>
          <p
            style={{
              color: COLORS.lavender,
              fontSize: 11,
              fontWeight: 700,
              letterSpacing: 2,
              margin: '0 0 10px',
            }}
          >
            OVERVIEW
          </p>

          <h1
            style={{
              ...headingText,
              fontSize: 'clamp(25px, 3vw, 32px)',
              fontWeight: 700,
              letterSpacing: -1,
              margin: 0,
            }}
          >
            Welcome to UrbanEye
          </h1>

          <p
            style={{
              ...mutedText,
              fontSize: 14,
              margin: '10px 0 0',
              lineHeight: 1.6,
            }}
          >
            Monitor civic issues and manage your city's reports.
          </p>
        </div>

        <button
          type="button"
          onClick={loadDashboard}
          disabled={loading}
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 9,
            padding: '11px 15px',
            borderRadius: 12,
            ...subtleSurface,
            color: 'var(--text-primary, #F7F5FA)',
            cursor: loading ? 'wait' : 'pointer',
            fontSize: 13,
            opacity: loading ? 0.7 : 1,
          }}
        >
          <RefreshCw size={15} />
          {loading ? 'Refreshing...' : 'Refresh data'}
        </button>
      </div>

      {/* API error */}
      {error && (
        <div
          role="alert"
          style={{
            ...cardStyle,
            padding: 18,
            display: 'flex',
            alignItems: 'flex-start',
            gap: 12,
            borderColor: 'rgba(251,113,133,0.4)',
            background: 'var(--error-surface, var(--surface, #141416))',
          }}
        >
          <AlertCircle size={20} color={COLORS.red} />

          <div style={{ flex: 1 }}>
            <p
              style={{
                ...headingText,
                margin: '0 0 6px',
                fontWeight: 600,
              }}
            >
              Could not load dashboard data
            </p>

            <p
              style={{
                color: 'var(--text-secondary, #D6B7BF)',
                fontSize: 13,
                lineHeight: 1.6,
                margin: 0,
              }}
            >
              {error}
            </p>
          </div>

          <button
            type="button"
            onClick={loadDashboard}
            style={{
              background: 'transparent',
              border: 'none',
              color: COLORS.lavender,
              cursor: 'pointer',
              fontWeight: 600,
            }}
          >
            Retry
          </button>
        </div>
      )}

      {/* Statistics cards */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns:
            'repeat(auto-fit, minmax(min(100%, 210px), 1fr))',
          gap: 16,
        }}
      >
        {STAT_CARDS.map((item) => {
          const Icon = item.icon;

          return (
            <div
              key={item.key}
              style={{
                ...cardStyle,
                padding: 22,
                minWidth: 0,
                position: 'relative',
                overflow: 'hidden',
              }}
            >
              <div
                style={{
                  position: 'absolute',
                  width: 100,
                  height: 100,
                  borderRadius: '50%',
                  background: item.color,
                  opacity: 0.06,
                  filter: 'blur(35px)',
                  right: -25,
                  top: -25,
                  pointerEvents: 'none',
                }}
              />

              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  gap: 10,
                  marginBottom: 22,
                }}
              >
                <span
                  style={{
                    ...mutedText,
                    fontSize: 13,
                    fontWeight: 500,
                  }}
                >
                  {item.title}
                </span>

                <span
                  style={{
                    display: 'grid',
                    placeItems: 'center',
                    width: 40,
                    height: 40,
                    borderRadius: 12,
                    color: item.color,
                    background: 'var(--icon-tint, rgba(124,58,237,0.10))',
                  }}
                >
                  <Icon size={20} />
                </span>
              </div>

              <div
                style={{
                  ...headingText,
                  fontSize: 32,
                  fontWeight: 750,
                  letterSpacing: -1,
                  marginBottom: 9,
                }}
              >
                {loading && !stats ? '—' : formatNumber(stats?.[item.key])}
              </div>

              <p
                style={{
                  ...mutedText,
                  fontSize: 12,
                  margin: 0,
                }}
              >
                {item.description}
              </p>
            </div>
          );
        })}
      </div>

      {/* Analytics */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns:
            'repeat(auto-fit, minmax(min(100%, 300px), 1fr))',
          gap: 18,
        }}
      >
        {/* Issue distribution */}
        <div style={{ ...cardStyle, padding: 24, minWidth: 0 }}>
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'flex-start',
              gap: 12,
              marginBottom: 26,
            }}
          >
            <div>
              <h2
                style={{
                  ...headingText,
                  fontSize: 16,
                  margin: 0,
                  fontWeight: 650,
                }}
              >
                Issue Distribution
              </h2>

              <p
                style={{
                  ...mutedText,
                  fontSize: 12,
                  margin: '8px 0 0',
                }}
              >
                Reports by detected civic issue
              </p>
            </div>

            <div
              style={{
                background: 'var(--badge-bg, rgba(124,58,237,0.12))',
                color: COLORS.lavender,
                padding: '7px 10px',
                borderRadius: 9,
                fontSize: 11,
              }}
            >
              AI Analytics
            </div>
          </div>

          {loading && !stats ? (
            <p style={{ ...mutedText, fontSize: 13 }}>
              Loading issue statistics...
            </p>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 23 }}>
              {issueEntries.map((issue) => {
                const percentage =
                  totalReports > 0
                    ? Math.round((issue.value / totalReports) * 100)
                    : 0;

                return (
                  <div key={issue.key}>
                    <div
                      style={{
                        display: 'flex',
                        justifyContent: 'space-between',
                        gap: 12,
                        marginBottom: 10,
                      }}
                    >
                      <span
                        style={{
                          color: 'var(--text-secondary, #DAD7E1)',
                          fontSize: 13,
                        }}
                      >
                        {issue.label}
                      </span>

                      <span
                        style={{
                          ...mutedText,
                          fontSize: 12,
                          whiteSpace: 'nowrap',
                        }}
                      >
                        {formatNumber(issue.value)} · {percentage}%
                      </span>
                    </div>

                    <div
                      style={{
                        height: 7,
                        borderRadius: 20,
                        background: 'var(--progress-track, #29272F)',
                        overflow: 'hidden',
                      }}
                    >
                      <div
                        style={{
                          height: '100%',
                          width: `${Math.min(
                            100,
                            (issue.value / maximumIssueCount) * 100
                          )}%`,
                          borderRadius: 20,
                          background:
                            'linear-gradient(90deg, #6D28D9, #B78BEA)',
                          transition: 'width 300ms ease',
                        }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* Resolution overview */}
        <div style={{ ...cardStyle, padding: 24, minWidth: 0 }}>
          <h2
            style={{
              ...headingText,
              fontSize: 16,
              margin: 0,
              fontWeight: 650,
            }}
          >
            Resolution Overview
          </h2>

          <p
            style={{
              ...mutedText,
              fontSize: 12,
              margin: '8px 0 25px',
            }}
          >
            Current report resolution progress
          </p>

          <div
            style={{
              borderRadius: 15,
              background: 'var(--highlight-surface, rgba(124,58,237,0.08))',
              border: '1px solid var(--highlight-border, rgba(124,58,237,0.22))',
              padding: 20,
              marginBottom: 16,
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                marginBottom: 18,
              }}
            >
              <div
                style={{
                  width: 43,
                  height: 43,
                  display: 'grid',
                  placeItems: 'center',
                  borderRadius: 13,
                  background: 'var(--icon-tint, rgba(124,58,237,0.12))',
                  color: COLORS.lavender,
                }}
              >
                <TrendingUp size={21} />
              </div>

              <div>
                <p
                  style={{
                    ...mutedText,
                    fontSize: 12,
                    margin: '0 0 5px',
                  }}
                >
                  Resolution rate
                </p>

                <p
                  style={{
                    ...headingText,
                    fontSize: 25,
                    fontWeight: 750,
                    margin: 0,
                  }}
                >
                  {loading && !stats ? '—' : `${resolutionRate}%`}
                </p>
              </div>
            </div>

            <div
              style={{
                height: 8,
                borderRadius: 20,
                background: 'var(--progress-track, #342B3D)',
                overflow: 'hidden',
              }}
            >
              <div
                style={{
                  height: '100%',
                  width: `${resolutionRate}%`,
                  borderRadius: 20,
                  background: 'linear-gradient(90deg, #7C3AED, #B78BEA)',
                  transition: 'width 300ms ease',
                }}
              />
            </div>
          </div>

          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '15px 0',
              borderBottom: '1px solid var(--border, #29272F)',
              gap: 12,
            }}
          >
            <span
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 9,
                ...mutedText,
                fontSize: 13,
              }}
            >
              <CheckCircle2 size={17} color={COLORS.green} />
              Resolved
            </span>

            <strong style={{ ...headingText, fontSize: 14 }}>
              {loading && !stats
                ? '—'
                : formatNumber(stats?.resolved_reports)}
            </strong>
          </div>

          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '15px 0',
              gap: 12,
            }}
          >
            <span
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 9,
                ...mutedText,
                fontSize: 13,
              }}
            >
              <Clock3 size={17} color={COLORS.orange} />
              Pending
            </span>

            <strong style={{ ...headingText, fontSize: 14 }}>
              {loading && !stats
                ? '—'
                : formatNumber(stats?.pending_reports)}
            </strong>
          </div>
        </div>
      </div>

      {/* System status */}
      <div
        style={{
          ...cardStyle,
          padding: '17px 20px',
          display: 'flex',
          alignItems: 'center',
          gap: 13,
          flexWrap: 'wrap',
        }}
      >
        <div
          style={{
            width: 40,
            height: 40,
            display: 'grid',
            placeItems: 'center',
            borderRadius: 12,
            background: 'var(--success-surface, rgba(74,222,128,0.12))',
            color: COLORS.green,
          }}
        >
          <ShieldCheck size={20} />
        </div>

        <div style={{ flex: 1, minWidth: 150 }}>
          <p
            style={{
              ...headingText,
              fontSize: 13,
              fontWeight: 650,
              margin: '0 0 5px',
            }}
          >
            Dashboard connection
          </p>

          <p
            style={{
              ...mutedText,
              fontSize: 12,
              margin: 0,
            }}
          >
            {error
              ? 'Unable to retrieve the latest backend data.'
              : loading
                ? 'Connecting to the UrbanEye backend...'
                : 'Statistics retrieved from your Django API.'}
          </p>
        </div>

        <span
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 7,
            color: error
              ? COLORS.red
              : loading
                ? COLORS.orange
                : COLORS.green,
            fontSize: 12,
            fontWeight: 600,
          }}
        >
          <span
            style={{
              width: 7,
              height: 7,
              borderRadius: '50%',
              background: error
                ? COLORS.red
                : loading
                  ? COLORS.orange
                  : COLORS.green,
            }}
          />

          {error ? 'Connection error' : loading ? 'Connecting' : 'Data loaded'}
        </span>
      </div>
    </section>
  );
}