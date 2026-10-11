import { useCallback, useEffect, useState } from 'react';
import {
  AlertCircle,
  RefreshCw,
  Search,
  MapPin,
  CalendarDays,
  Image as ImageIcon,
  ClipboardList,
  CheckCircle2,
  Clock3,
  X,
} from 'lucide-react';
import { api } from '../services/api';

const C = {
  purple: '#7C3AED',
  lavender: 'var(--lavender, #B78BEA)',
  green: '#4ADE80',
  orange: '#FBBF24',
  red: '#FB7185',
  muted: 'var(--muted, #92909D)',
  text: 'var(--text-primary, #F7F5FA)',
  secondary: 'var(--text-secondary, #C4C0CE)',
  border: 'var(--border, #29272F)',
  surface: 'var(--surface, #141416)',
  surfaceSecondary: 'var(--surface-secondary, #1C1C1E)',
  input: 'var(--input-bg, #0C0C0E)',
  hover: 'var(--hover-bg, rgba(255,255,255,0.045))',
  badge: 'var(--badge-bg, rgba(124,58,237,0.12))',
};

const ISSUE_LABELS = {
  garbage: 'Garbage',
  pothole: 'Pothole',
  road_crack: 'Road Crack',
  street_light: 'Street Light',
  water_overflow: 'Water Overflow',
};

const SEVERITY_COLORS = {
  low: C.green,
  medium: C.orange,
  high: C.red,
};

const STATUS_COLORS = {
  pending: C.orange,
  resolved: C.green,
};

const cardStyle = {
  background: C.surface,
  color: C.text,
  border: `1px solid ${C.border}`,
  borderRadius: 16,
  transition: 'background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease',
};

const selectStyle = {
  minWidth: 145,
  maxWidth: '100%',
  padding: '12px 13px',
  borderRadius: 11,
  background: C.input,
  border: `1px solid ${C.border}`,
  color: C.text,
  fontSize: 12,
  outline: 'none',
};

const thStyle = {
  padding: '14px 16px',
  color: C.muted,
  fontSize: 10,
  fontWeight: 650,
  letterSpacing: 0.8,
  whiteSpace: 'nowrap',
  background: C.surfaceSecondary,
};

const tdStyle = {
  padding: '15px 16px',
  fontSize: 12,
  verticalAlign: 'middle',
  color: C.text,
};

const smallButtonStyle = {
  padding: '8px 10px',
  borderRadius: 8,
  border: `1px solid ${C.border}`,
  background: C.surfaceSecondary,
  color: C.secondary,
  fontSize: 11,
  fontWeight: 600,
  whiteSpace: 'nowrap',
  cursor: 'pointer',
};

const emptyStateStyle = {
  minHeight: 180,
  padding: 28,
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  justifyContent: 'center',
  textAlign: 'center',
  gap: 10,
};

function formatDate(value) {
  if (!value) return '—';

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '—';

  return date.toLocaleString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

function normalizeReports(data) {
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.results)) return data.results;
  if (Array.isArray(data?.reports)) return data.reports;
  return [];
}

function getImageUrl(image) {
  if (!image) return '';
  if (typeof image === 'string') return image;
  return image.url || '';
}

function getIssueLabel(value) {
  if (!value) return 'Unknown';
  return ISSUE_LABELS[value] || value.replaceAll('_', ' ');
}

function getLocation(report) {
  if (report.location_name) return report.location_name;

  if (report.latitude != null && report.longitude != null) {
    return `${report.latitude}, ${report.longitude}`;
  }

  return 'Location unavailable';
}

function getReportUser(report) {
  if (report.username) return report.username;
  if (report.user_name) return report.user_name;

  if (report.user && typeof report.user === 'object') {
    return report.user.username || report.user.email || 'User';
  }

  if (report.user != null) return `User #${report.user}`;

  return 'Unknown user';
}

function formatConfidence(value) {
  if (value === null || value === undefined || value === '') return '—';

  const number = Number(value);
  if (!Number.isFinite(number)) return '—';

  return `${(number <= 1 ? number * 100 : number).toFixed(1)}%`;
}

export default function Reports() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [severityFilter, setSeverityFilter] = useState('all');
  const [updatingId, setUpdatingId] = useState(null);
  const [selectedReport, setSelectedReport] = useState(null);

  const loadReports = useCallback(async () => {
    setLoading(true);
    setError('');

    try {
      const data = await api.getReports();
      setReports(normalizeReports(data));
    } catch (err) {
      setError(err.message || 'Unable to load civic reports.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadReports();
  }, [loadReports]);

  useEffect(() => {
    if (!selectedReport) return;

    function handleKeyDown(event) {
      if (event.key === 'Escape' && updatingId !== selectedReport.id) {
        setSelectedReport(null);
      }
    }

    document.addEventListener('keydown', handleKeyDown);

    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [selectedReport, updatingId]);

  const updateStatus = async (report, nextStatus) => {
    if (report.status === nextStatus || updatingId !== null) return;

    setUpdatingId(report.id);
    setError('');

    try {
      await api.updateReport(report.id, { status: nextStatus });

      setReports((current) =>
        current.map((item) =>
          item.id === report.id ? { ...item, status: nextStatus } : item
        )
      );

      setSelectedReport((current) =>
        current?.id === report.id
          ? { ...current, status: nextStatus }
          : current
      );
    } catch (err) {
      setError(err.message || 'Could not update the report status.');
    } finally {
      setUpdatingId(null);
    }
  };

  const filteredReports = reports.filter((report) => {
    const searchText = search.trim().toLowerCase();

    const matchesSearch =
      !searchText ||
      [
        report.id,
        getIssueLabel(report.issue_type),
        report.description,
        getLocation(report),
        getReportUser(report),
      ]
        .filter(Boolean)
        .some((value) => String(value).toLowerCase().includes(searchText));

    const matchesStatus =
      statusFilter === 'all' || report.status === statusFilter;

    const matchesSeverity =
      severityFilter === 'all' || report.severity === severityFilter;

    return matchesSearch && matchesStatus && matchesSeverity;
  });

  const pendingCount = reports.filter(
    (report) => report.status === 'pending'
  ).length;

  const resolvedCount = reports.filter(
    (report) => report.status === 'resolved'
  ).length;

  const summaryCards = [
    {
      label: 'Total Reports',
      value: reports.length,
      icon: ClipboardList,
      color: C.lavender,
    },
    {
      label: 'Pending',
      value: pendingCount,
      icon: Clock3,
      color: C.orange,
    },
    {
      label: 'Resolved',
      value: resolvedCount,
      icon: CheckCircle2,
      color: C.green,
    },
  ];

  return (
    <section
      style={{
        color: C.text,
        display: 'flex',
        flexDirection: 'column',
        gap: 24,
        paddingBottom: 24,
        minWidth: 0,
      }}
    >
      {/* Heading */}
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
              color: C.lavender,
              fontSize: 11,
              fontWeight: 700,
              letterSpacing: 2,
              margin: '0 0 10px',
            }}
          >
            CIVIC MANAGEMENT
          </p>

          <h1
            style={{
              color: C.text,
              fontSize: 'clamp(25px, 3vw, 32px)',
              fontWeight: 750,
              letterSpacing: -1,
              margin: 0,
            }}
          >
            Civic Reports
          </h1>

          <p style={{ color: C.muted, fontSize: 14, margin: '10px 0 0' }}>
            Review AI-detected civic issues and manage their resolution.
          </p>
        </div>

        <button
          type="button"
          onClick={loadReports}
          disabled={loading}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 9,
            padding: '11px 15px',
            background: C.surfaceSecondary,
            border: `1px solid ${C.border}`,
            borderRadius: 12,
            color: C.text,
            cursor: loading ? 'wait' : 'pointer',
            opacity: loading ? 0.7 : 1,
          }}
        >
          <RefreshCw size={15} />
          {loading ? 'Loading...' : 'Refresh'}
        </button>
      </div>

      {/* Summary cards */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(min(100%, 190px), 1fr))',
          gap: 15,
        }}
      >
        {summaryCards.map((item) => {
          const Icon = item.icon;

          return (
            <div key={item.label} style={{ ...cardStyle, padding: 20 }}>
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  gap: 10,
                }}
              >
                <span style={{ color: C.muted, fontSize: 13 }}>
                  {item.label}
                </span>
                <Icon size={20} color={item.color} />
              </div>

              <div
                style={{
                  color: C.text,
                  fontSize: 29,
                  fontWeight: 750,
                  marginTop: 17,
                }}
              >
                {loading && reports.length === 0 ? '—' : item.value}
              </div>
            </div>
          );
        })}
      </div>

      {/* Error */}
      {error && (
        <div
          role="alert"
          style={{
            ...cardStyle,
            borderColor: 'rgba(251,113,133,0.4)',
            padding: 16,
            display: 'flex',
            alignItems: 'center',
            gap: 12,
          }}
        >
          <AlertCircle size={20} color={C.red} />

          <span style={{ flex: 1, color: C.text, fontSize: 13 }}>
            {error}
          </span>

          <button
            type="button"
            onClick={loadReports}
            style={{
              background: 'transparent',
              border: 0,
              color: C.lavender,
              cursor: 'pointer',
            }}
          >
            Retry
          </button>
        </div>
      )}

      {/* Filters */}
      <div
        style={{
          ...cardStyle,
          padding: 16,
          display: 'flex',
          flexWrap: 'wrap',
          gap: 12,
        }}
      >
        <div
          style={{
            flex: '1 1 220px',
            minWidth: 0,
            display: 'flex',
            alignItems: 'center',
            gap: 10,
            padding: '0 13px',
            borderRadius: 11,
            border: `1px solid ${C.border}`,
            background: C.input,
          }}
        >
          <Search size={17} color={C.muted} />

          <input
            type="search"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search reports, location, user..."
            aria-label="Search reports"
            style={{
              width: '100%',
              minWidth: 0,
              padding: '13px 0',
              border: 0,
              outline: 'none',
              background: 'transparent',
              color: C.text,
              fontSize: 13,
            }}
          />
        </div>

        <select
          aria-label="Filter by status"
          value={statusFilter}
          onChange={(event) => setStatusFilter(event.target.value)}
          style={selectStyle}
        >
          <option value="all">All statuses</option>
          <option value="pending">Pending</option>
          <option value="resolved">Resolved</option>
        </select>

        <select
          aria-label="Filter by severity"
          value={severityFilter}
          onChange={(event) => setSeverityFilter(event.target.value)}
          style={selectStyle}
        >
          <option value="all">All severity levels</option>
          <option value="low">Low severity</option>
          <option value="medium">Medium severity</option>
          <option value="high">High severity</option>
        </select>
      </div>

      {/* Reports table */}
      <div
        style={{
          ...cardStyle,
          overflow: 'hidden',
          minWidth: 0,
        }}
      >
        <div
          style={{
            padding: '20px 22px',
            borderBottom: `1px solid ${C.border}`,
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            flexWrap: 'wrap',
            gap: 10,
          }}
        >
          <div>
            <h2 style={{ color: C.text, margin: 0, fontSize: 16, fontWeight: 650 }}>
              All Reports
            </h2>

            <p style={{ color: C.muted, fontSize: 12, margin: '7px 0 0' }}>
              {filteredReports.length} report
              {filteredReports.length === 1 ? '' : 's'} displayed
            </p>
          </div>

          <span
            style={{
              fontSize: 11,
              color: C.lavender,
              background: C.badge,
              borderRadius: 8,
              padding: '7px 10px',
            }}
          >
            Live backend data
          </span>
        </div>

        {loading && reports.length === 0 ? (
          <div style={emptyStateStyle}>
            <RefreshCw size={25} color={C.lavender} />
            <p style={{ color: C.muted }}>Loading reports from Django...</p>
          </div>
        ) : filteredReports.length === 0 ? (
          <div style={emptyStateStyle}>
            <ClipboardList size={30} color={C.muted} />

            <p style={{ color: C.text, marginBottom: 5 }}>
              {reports.length === 0 ? 'No reports available' : 'No matching reports'}
            </p>

            <p style={{ color: C.muted, fontSize: 12, margin: 0 }}>
              {reports.length === 0
                ? 'Reports submitted through UrbanEye will appear here.'
                : 'Try changing your search or filters.'}
            </p>
          </div>
        ) : (
          <div style={{ overflowX: 'auto', width: '100%' }}>
            <table
              style={{
                width: '100%',
                borderCollapse: 'collapse',
                textAlign: 'left',
                minWidth: 980,
                color: C.text,
              }}
            >
              <thead>
                <tr>
                  {[
                    'REPORT',
                    'LOCATION',
                    'SEVERITY',
                    'CONFIDENCE',
                    'SUBMITTED',
                    'STATUS',
                    'ACTIONS',
                  ].map((heading) => (
                    <th key={heading} style={thStyle}>
                      {heading}
                    </th>
                  ))}
                </tr>
              </thead>

              <tbody>
                {filteredReports.map((report) => {
                  const severity = String(report.severity || '').toLowerCase();
                  const status = String(report.status || 'pending').toLowerCase();
                  const severityColor = SEVERITY_COLORS[severity] || C.muted;
                  const statusColor = STATUS_COLORS[status] || C.muted;
                  const imageUrl = getImageUrl(report.image);

                  return (
                    <tr
                      key={report.id}
                      style={{ borderTop: `1px solid ${C.border}` }}
                    >
                      <td style={tdStyle}>
                        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
                          <div
                            style={{
                              width: 44,
                              height: 44,
                              flexShrink: 0,
                              borderRadius: 11,
                              overflow: 'hidden',
                              background: C.surfaceSecondary,
                              display: 'grid',
                              placeItems: 'center',
                            }}
                          >
                            {imageUrl ? (
                              <img
                                src={imageUrl}
                                alt={getIssueLabel(report.issue_type)}
                                style={{
                                  width: '100%',
                                  height: '100%',
                                  objectFit: 'cover',
                                }}
                                onError={(event) => {
                                  event.currentTarget.style.display = 'none';
                                }}
                              />
                            ) : (
                              <ImageIcon size={19} color={C.lavender} />
                            )}
                          </div>

                          <div>
                            <p
                              style={{
                                color: C.text,
                                fontWeight: 650,
                                margin: '0 0 5px',
                                fontSize: 13,
                              }}
                            >
                              {getIssueLabel(report.issue_type)}
                            </p>

                            <p style={{ color: C.muted, fontSize: 11, margin: 0 }}>
                              #{report.id} · {getReportUser(report)}
                            </p>
                          </div>
                        </div>
                      </td>

                      <td style={{ ...tdStyle, maxWidth: 220 }}>
                        <div
                          style={{
                            display: 'flex',
                            gap: 7,
                            alignItems: 'flex-start',
                            color: C.secondary,
                            fontSize: 12,
                            lineHeight: 1.6,
                          }}
                        >
                          <MapPin
                            size={15}
                            color={C.lavender}
                            style={{ flexShrink: 0, marginTop: 2 }}
                          />
                          <span>{getLocation(report)}</span>
                        </div>
                      </td>

                      <td style={tdStyle}>
                        <span
                          style={{
                            color: severityColor,
                            background: `color-mix(in srgb, ${severityColor} 10%, transparent)`,
                            border: `1px solid color-mix(in srgb, ${severityColor} 30%, transparent)`,
                            borderRadius: 7,
                            padding: '5px 8px',
                            fontSize: 11,
                            textTransform: 'capitalize',
                            whiteSpace: 'nowrap',
                          }}
                        >
                          {severity || 'Unknown'}
                        </span>
                      </td>

                      <td style={tdStyle}>
                        <span style={{ fontSize: 12, color: C.text }}>
                          {formatConfidence(report.confidence)}
                        </span>
                      </td>

                      <td style={tdStyle}>
                        <div
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 7,
                            color: C.muted,
                            fontSize: 11,
                            whiteSpace: 'nowrap',
                          }}
                        >
                          <CalendarDays size={14} />
                          {formatDate(report.created_at)}
                        </div>
                      </td>

                      <td style={tdStyle}>
                        <span
                          style={{
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: 6,
                            color: statusColor,
                            fontSize: 11,
                            textTransform: 'capitalize',
                          }}
                        >
                          <span
                            style={{
                              width: 6,
                              height: 6,
                              borderRadius: '50%',
                              background: statusColor,
                            }}
                          />
                          {status}
                        </span>
                      </td>

                      <td style={tdStyle}>
                        <div style={{ display: 'flex', gap: 7, alignItems: 'center' }}>
                          <button
                            type="button"
                            onClick={() => setSelectedReport(report)}
                            style={smallButtonStyle}
                          >
                            View
                          </button>

                          <button
                            type="button"
                            disabled={updatingId === report.id}
                            onClick={() =>
                              updateStatus(
                                report,
                                status === 'resolved' ? 'pending' : 'resolved'
                              )
                            }
                            style={{
                              ...smallButtonStyle,
                              color: status === 'resolved' ? C.orange : C.green,
                              opacity: updatingId === report.id ? 0.6 : 1,
                              cursor: updatingId === report.id ? 'wait' : 'pointer',
                            }}
                          >
                            {updatingId === report.id
                              ? 'Saving...'
                              : status === 'resolved'
                                ? 'Reopen'
                                : 'Resolve'}
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Report details dialog */}
      {selectedReport && (
        <div
          onClick={() => {
            if (updatingId !== selectedReport.id) setSelectedReport(null);
          }}
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 1000,
            padding: 20,
            display: 'grid',
            placeItems: 'center',
            background: 'rgba(0,0,0,0.72)',
            backdropFilter: 'blur(8px)',
          }}
        >
          <div
            role="dialog"
            aria-modal="true"
            aria-label="Report details"
            onClick={(event) => event.stopPropagation()}
            style={{
              ...cardStyle,
              width: 'min(100%, 620px)',
              maxHeight: '85vh',
              overflowY: 'auto',
              padding: 24,
            }}
          >
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                gap: 12,
                marginBottom: 20,
              }}
            >
              <div>
                <p
                  style={{
                    color: C.lavender,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    margin: '0 0 8px',
                  }}
                >
                  REPORT #{selectedReport.id}
                </p>

                <h2 style={{ color: C.text, fontSize: 21, margin: 0 }}>
                  {getIssueLabel(selectedReport.issue_type)}
                </h2>
              </div>

              <button
                type="button"
                aria-label="Close report details"
                disabled={updatingId === selectedReport.id}
                onClick={() => setSelectedReport(null)}
                style={{
                  background: C.surfaceSecondary,
                  border: `1px solid ${C.border}`,
                  color: C.text,
                  borderRadius: 10,
                  width: 38,
                  height: 38,
                  cursor: 'pointer',
                  display: 'grid',
                  placeItems: 'center',
                }}
              >
                <X size={18} />
              </button>
            </div>

            {getImageUrl(selectedReport.image) && (
              <img
                src={getImageUrl(selectedReport.image)}
                alt={getIssueLabel(selectedReport.issue_type)}
                style={{
                  display: 'block',
                  width: '100%',
                  maxHeight: 280,
                  objectFit: 'contain',
                  borderRadius: 12,
                  background: C.input,
                  marginBottom: 20,
                }}
              />
            )}

            <div style={{ display: 'grid', gap: 15 }}>
              {[
                ['Description', selectedReport.description || 'No description provided.'],
                ['Location', getLocation(selectedReport)],
                ['Latitude', selectedReport.latitude ?? '—'],
                ['Longitude', selectedReport.longitude ?? '—'],
                ['Severity', selectedReport.severity || 'Unknown'],
                ['AI confidence', formatConfidence(selectedReport.confidence)],
                ['Submitted by', getReportUser(selectedReport)],
                ['Submitted at', formatDate(selectedReport.created_at)],
                ['Status', selectedReport.status || 'pending'],
              ].map(([label, value]) => (
                <div
                  key={label}
                  style={{
                    display: 'grid',
                    gridTemplateColumns: '130px minmax(0, 1fr)',
                    gap: 12,
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: 12,
                  }}
                >
                  <span style={{ color: C.muted, fontSize: 12 }}>{label}</span>

                  <span
                    style={{
                      color: C.text,
                      fontSize: 13,
                      lineHeight: 1.6,
                      overflowWrap: 'anywhere',
                    }}
                  >
                    {String(value)}
                  </span>
                </div>
              ))}
            </div>

            <div
              style={{
                display: 'flex',
                justifyContent: 'flex-end',
                gap: 10,
                marginTop: 22,
                flexWrap: 'wrap',
              }}
            >
              <button
                type="button"
                disabled={updatingId === selectedReport.id}
                onClick={() => setSelectedReport(null)}
                style={smallButtonStyle}
              >
                Close
              </button>

              <button
                type="button"
                disabled={updatingId === selectedReport.id}
                onClick={() =>
                  updateStatus(
                    selectedReport,
                    selectedReport.status === 'resolved' ? 'pending' : 'resolved'
                  )
                }
                style={{
                  ...smallButtonStyle,
                  background: C.badge,
                  borderColor: 'rgba(124,58,237,0.3)',
                  color: C.lavender,
                  opacity: updatingId === selectedReport.id ? 0.6 : 1,
                }}
              >
                {updatingId === selectedReport.id
                  ? 'Saving...'
                  : selectedReport.status === 'resolved'
                    ? 'Reopen report'
                    : 'Mark as resolved'}
              </button>
            </div>
          </div>
        </div>
      )}
    </section>
  );
}