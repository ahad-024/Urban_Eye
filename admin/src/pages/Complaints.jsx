
import { useCallback, useEffect, useState } from 'react';
import {
  AlertCircle,
  RefreshCw,
  Search,
  MapPin,
  CalendarDays,
  ClipboardList,
  CheckCircle2,
  Clock3,
  Eye,
  X,
  FileText,
  UserRound,
} from 'lucide-react';
import { api } from '../services/api';

const C = {
  card: 'var(--surface, #141416)',
  border: 'var(--border, #29272F)',
  lavender: 'var(--lavender, #B78BEA)',
  purple: 'var(--purple, #7C3AED)',
  text: 'var(--text-primary, #F7F5FA)',
  secondary: 'var(--text-secondary, #DAD7E1)',
  muted: 'var(--muted, #92909D)',
  green: '#4ADE80',
  orange: '#FBBF24',
  red: '#FB7185',
  subtle: 'var(--surface-secondary, #1C1C1E)',
  input: 'var(--input-bg, #0C0C0E)',
  hover: 'var(--hover-bg, rgba(255,255,255,0.045))',
  page: 'var(--app-bg, #08080A)',
};

const STATUS_COLORS = {
  pending: C.orange,
  resolved: C.green,
  rejected: C.red,
  in_progress: C.lavender,
};

const cardStyle = {
  background: C.card,
  border: `1px solid ${C.border}`,
  borderRadius: 16,
  color: C.text,
};

const selectStyle = {
  minWidth: 150,
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
};

const tdStyle = {
  padding: 16,
  fontSize: 12,
  verticalAlign: 'middle',
  color: C.text,
};

const actionButtonStyle = {
  padding: '8px 11px',
  borderRadius: 8,
  border: `1px solid ${C.border}`,
  background: C.subtle,
  color: C.text,
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

function normalizeComplaints(data) {
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.results)) return data.results;
  if (Array.isArray(data?.complaints)) return data.complaints;
  return [];
}

function normalizeReports(data) {
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.results)) return data.results;
  if (Array.isArray(data?.reports)) return data.reports;
  return [];
}

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

function getUser(complaint) {
  if (complaint.username) return complaint.username;
  if (complaint.user_name) return complaint.user_name;

  if (complaint.user && typeof complaint.user === 'object') {
    return (
      complaint.user.username ||
      complaint.user.email ||
      'Unknown user'
    );
  }

  if (complaint.user != null) {
    return `User #${complaint.user}`;
  }

  return 'Unknown user';
}

function getReportId(complaint) {
  const report = complaint.report;

  if (report && typeof report === 'object') {
    return report.id ?? report.pk ?? complaint.report_id ?? '—';
  }

  return report ?? complaint.report_id ?? '—';
}

function getLinkedReport(complaint) {
  if (complaint._linkedReport) return complaint._linkedReport;

  if (complaint.report && typeof complaint.report === 'object') {
    return complaint.report;
  }

  return null;
}

function getIssue(complaint) {
  const report = getLinkedReport(complaint);

  const issue =
    report?.issue_type ||
    report?.issue ||
    complaint.issue_type;

  return issue
    ? String(issue).replaceAll('_', ' ')
    : 'Civic complaint';
}

function getLocation(complaint) {
  const hasText = (value) =>
    typeof value === 'string' && value.trim().length > 0;

  if (hasText(complaint.location_name)) {
    return complaint.location_name.trim();
  }

  if (hasText(complaint.location)) {
    return complaint.location.trim();
  }

  const report = getLinkedReport(complaint);

  if (report) {
    if (hasText(report.location_name)) {
      return report.location_name.trim();
    }

    if (hasText(report.location)) {
      return report.location.trim();
    }

    if (
      report.latitude != null &&
      report.longitude != null &&
      report.latitude !== '' &&
      report.longitude !== ''
    ) {
      return `${report.latitude}, ${report.longitude}`;
    }
  }

  return 'Location unavailable';
}

function getDescription(complaint) {
  return (
    complaint.description ||
    complaint.message ||
    complaint.details ||
    complaint.complaint_text ||
    'No description provided.'
  );
}

function getStatus(complaint) {
  return String(complaint.status || 'pending').toLowerCase();
}

function getComplaintDate(complaint) {
  return (
    complaint.created_at ||
    complaint.submitted_at ||
    complaint.created ||
    complaint.date_created
  );
}

export default function Complaints() {
  const [complaints, setComplaints] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [updatingId, setUpdatingId] = useState(null);
  const [selectedComplaint, setSelectedComplaint] = useState(null);

  const loadComplaints = useCallback(async () => {
    setLoading(true);
    setError('');

    try {
      const [complaintsResult, reportsResult] =
        await Promise.allSettled([
          api.getComplaints(),
          api.getReports(),
        ]);

      if (complaintsResult.status === 'rejected') {
        throw complaintsResult.reason;
      }

      const complaintList = normalizeComplaints(
        complaintsResult.value
      );

      const reportList =
        reportsResult.status === 'fulfilled'
          ? normalizeReports(reportsResult.value)
          : [];

      const reportsById = new Map();

      reportList.forEach((report) => {
        const id = report.id ?? report.pk;

        if (id != null) {
          reportsById.set(String(id), report);
        }
      });

      const enrichedComplaints = complaintList.map((complaint) => {
        const reportValue = complaint.report;

        const reportId =
          reportValue && typeof reportValue === 'object'
            ? reportValue.id ??
              reportValue.pk ??
              complaint.report_id
            : reportValue ?? complaint.report_id;

        const fetchedReport =
          reportId != null
            ? reportsById.get(String(reportId))
            : null;

        const embeddedReport =
          reportValue && typeof reportValue === 'object'
            ? reportValue
            : null;

        const embeddedHasLocation =
          embeddedReport &&
          (
            embeddedReport.location_name ||
            embeddedReport.location ||
            (
              embeddedReport.latitude != null &&
              embeddedReport.longitude != null
            )
          );

        const linkedReport = embeddedHasLocation
          ? embeddedReport
          : fetchedReport || embeddedReport;

        return {
          ...complaint,
          _linkedReport: linkedReport || null,
        };
      });

      setComplaints(enrichedComplaints);
    } catch (err) {
      setError(err.message || 'Unable to load complaints.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadComplaints();
  }, [loadComplaints]);

  const updateStatus = async (complaint, nextStatus) => {
    if (getStatus(complaint) === nextStatus) return;

    setUpdatingId(complaint.id);
    setError('');

    try {
      const updated = await api.updateComplaint(complaint.id, {
        status: nextStatus,
      });

      setComplaints((current) =>
        current.map((item) =>
          item.id === complaint.id
            ? { ...item, ...updated, status: nextStatus }
            : item
        )
      );

      setSelectedComplaint((current) =>
        current?.id === complaint.id
          ? { ...current, ...updated, status: nextStatus }
          : current
      );
    } catch (err) {
      setError(
        err.message ||
          'Unable to update complaint status. Check administrator permissions and the backend serializer.'
      );
    } finally {
      setUpdatingId(null);
    }
  };

  const filteredComplaints = complaints.filter((complaint) => {
    const query = search.trim().toLowerCase();

    const matchesSearch =
      !query ||
      [
        complaint.id,
        getUser(complaint),
        getReportId(complaint),
        getIssue(complaint),
        getLocation(complaint),
        getDescription(complaint),
      ].some((value) =>
        String(value ?? '').toLowerCase().includes(query)
      );

    const status = getStatus(complaint);
    const matchesStatus =
      statusFilter === 'all' || status === statusFilter;

    return matchesSearch && matchesStatus;
  });

  const pendingCount = complaints.filter(
    (item) => getStatus(item) === 'pending'
  ).length;

  const resolvedCount = complaints.filter(
    (item) => getStatus(item) === 'resolved'
  ).length;

  const otherCount =
    complaints.length - pendingCount - resolvedCount;

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
      {/* Page heading */}
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
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
              fontSize: 'clamp(25px, 3vw, 32px)',
              fontWeight: 750,
              letterSpacing: -1,
              margin: 0,
              color: C.text,
            }}
          >
            Complaints
          </h1>

          <p
            style={{
              color: C.muted,
              fontSize: 14,
              margin: '10px 0 0',
            }}
          >
            Review citizen complaints and track their progress.
          </p>
        </div>

        <button
          type="button"
          onClick={loadComplaints}
          disabled={loading}
          style={{
            ...actionButtonStyle,
            display: 'flex',
            alignItems: 'center',
            gap: 9,
            padding: '11px 15px',
            opacity: loading ? 0.7 : 1,
            cursor: loading ? 'wait' : 'pointer',
          }}
        >
          <RefreshCw size={15} />
          {loading ? 'Loading...' : 'Refresh'}
        </button>
      </div>

      {/* Error message */}
      {error && (
        <div
          role="alert"
          style={{
            ...cardStyle,
            borderColor: 'var(--danger-border, #7F1D35)',
            background: 'var(--danger-bg, #1B1015)',
            padding: 16,
            display: 'flex',
            alignItems: 'center',
            gap: 12,
          }}
        >
          <AlertCircle size={20} color={C.red} />

          <span
            style={{
              flex: 1,
              color: C.text,
              fontSize: 13,
              overflowWrap: 'anywhere',
            }}
          >
            {error}
          </span>

          <button
            type="button"
            onClick={loadComplaints}
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

      {/* Summary cards */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns:
            'repeat(auto-fit, minmax(min(100%, 180px), 1fr))',
          gap: 15,
        }}
      >
        {[
          {
            label: 'Total Complaints',
            value: complaints.length,
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
          {
            label: 'Other Statuses',
            value: otherCount,
            icon: AlertCircle,
            color: C.red,
          },
        ].map((item) => {
          const Icon = item.icon;

          return (
            <div
              key={item.label}
              style={{ ...cardStyle, padding: 20 }}
            >
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
                  fontSize: 29,
                  fontWeight: 750,
                  marginTop: 17,
                  color: C.text,
                }}
              >
                {loading && complaints.length === 0
                  ? '—'
                  : item.value}
              </div>
            </div>
          );
        })}
      </div>

      {/* Search and filter */}
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
            flex: '1 1 230px',
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
            placeholder="Search complaints, users, reports..."
            aria-label="Search complaints"
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
          aria-label="Filter complaints by status"
          value={statusFilter}
          onChange={(event) => setStatusFilter(event.target.value)}
          style={selectStyle}
        >
          <option value="all">All statuses</option>
          <option value="pending">Pending</option>
          <option value="resolved">Resolved</option>
          <option value="in_progress">In progress</option>
          <option value="rejected">Rejected</option>
        </select>
      </div>

      {/* Complaints table */}
      <div style={{ ...cardStyle, overflow: 'hidden', minWidth: 0 }}>
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
            <h2
              style={{
                margin: 0,
                fontSize: 16,
                fontWeight: 650,
                color: C.text,
              }}
            >
              All Complaints
            </h2>

            <p
              style={{
                color: C.muted,
                fontSize: 12,
                margin: '7px 0 0',
              }}
            >
              {filteredComplaints.length} complaint
              {filteredComplaints.length === 1 ? '' : 's'} displayed
            </p>
          </div>

          <span
            style={{
              fontSize: 11,
              color: C.lavender,
              background: 'var(--lavender-bg, rgba(124,58,237,0.12))',
              border: `1px solid ${C.border}`,
              borderRadius: 8,
              padding: '7px 10px',
            }}
          >
            Live backend data
          </span>
        </div>

        {loading && complaints.length === 0 ? (
          <div style={emptyStateStyle}>
            <RefreshCw size={25} color={C.lavender} />
            <p style={{ color: C.muted }}>
              Loading complaints from Django...
            </p>
          </div>
        ) : filteredComplaints.length === 0 ? (
          <div style={emptyStateStyle}>
            <ClipboardList size={30} color={C.muted} />

            <p style={{ color: C.text, marginBottom: 5 }}>
              {complaints.length === 0
                ? 'No complaints available'
                : 'No matching complaints'}
            </p>

            <p style={{ color: C.muted, fontSize: 12, margin: 0 }}>
              {complaints.length === 0
                ? 'Complaints submitted through UrbanEye will appear here.'
                : 'Try changing your search or status filter.'}
            </p>
          </div>
        ) : (
          <div style={{ overflowX: 'auto', width: '100%' }}>
            <table
              style={{
                width: '100%',
                borderCollapse: 'collapse',
                textAlign: 'left',
                minWidth: 850,
              }}
            >
              <thead>
                <tr
                  style={{
                    background: 'var(--surface-secondary, #101012)',
                  }}
                >
                  {[
                    'COMPLAINT',
                    'SUBMITTED BY',
                    'LINKED REPORT',
                    'LOCATION',
                    'SUBMITTED',
                    'STATUS',
                    'ACTION',
                  ].map((heading) => (
                    <th key={heading} style={thStyle}>
                      {heading}
                    </th>
                  ))}
                </tr>
              </thead>

              <tbody>
                {filteredComplaints.map((complaint) => {
                  const status = getStatus(complaint);
                  const statusColor =
                    STATUS_COLORS[status] || C.muted;

                  return (
                    <tr
                      key={complaint.id}
                      style={{
                        borderTop: `1px solid ${C.border}`,
                      }}
                    >
                      <td style={tdStyle}>
                        <div
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 11,
                          }}
                        >
                          <div
                            style={{
                              width: 40,
                              height: 40,
                              flexShrink: 0,
                              borderRadius: 11,
                              background: 'var(--lavender-bg, rgba(124,58,237,0.12))',
                              color: C.lavender,
                              display: 'grid',
                              placeItems: 'center',
                            }}
                          >
                            <FileText size={18} />
                          </div>

                          <div>
                            <p
                              style={{
                                fontWeight: 650,
                                margin: '0 0 5px',
                                fontSize: 13,
                                color: C.text,
                              }}
                            >
                              Complaint #{complaint.id}
                            </p>

                            <p
                              style={{
                                color: C.muted,
                                fontSize: 11,
                                margin: 0,
                                textTransform: 'capitalize',
                              }}
                            >
                              {getIssue(complaint)}
                            </p>
                          </div>
                        </div>
                      </td>

                      <td style={tdStyle}>
                        <div
                          style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 8,
                          }}
                        >
                          <UserRound size={15} color={C.lavender} />
                          <span>{getUser(complaint)}</span>
                        </div>
                      </td>

                      <td style={tdStyle}>
                        <span style={{ color: C.lavender }}>
                          #{getReportId(complaint)}
                        </span>
                      </td>

                      <td style={{ ...tdStyle, maxWidth: 220 }}>
                        <div
                          style={{
                            display: 'flex',
                            alignItems: 'flex-start',
                            gap: 7,
                            color: C.muted,
                            lineHeight: 1.6,
                            overflowWrap: 'anywhere',
                          }}
                        >
                          <MapPin
                            size={14}
                            color={C.lavender}
                            style={{
                              flexShrink: 0,
                              marginTop: 2,
                            }}
                          />
                          <span>{getLocation(complaint)}</span>
                        </div>
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
                          {formatDate(getComplaintDate(complaint))}
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
                            whiteSpace: 'nowrap',
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
                          {status.replaceAll('_', ' ')}
                        </span>
                      </td>

                      <td style={tdStyle}>
                        <button
                          type="button"
                          onClick={() => setSelectedComplaint(complaint)}
                          style={{
                            ...actionButtonStyle,
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: 6,
                          }}
                        >
                          <Eye size={14} />
                          View
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Complaint details modal */}
      {selectedComplaint && (
        <div
          onClick={() => setSelectedComplaint(null)}
          style={{
            position: 'fixed',
            inset: 0,
            zIndex: 1000,
            padding: 20,
            display: 'grid',
            placeItems: 'center',
            background: 'rgba(0,0,0,0.78)',
            backdropFilter: 'blur(8px)',
          }}
        >
          <div
            role="dialog"
            aria-modal="true"
            aria-label="Complaint details"
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
                marginBottom: 22,
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
                  COMPLAINT #{selectedComplaint.id}
                </p>

                <h2
                  style={{
                    fontSize: 21,
                    margin: 0,
                    color: C.text,
                  }}
                >
                  Complaint Details
                </h2>
              </div>

              <button
                type="button"
                aria-label="Close complaint details"
                onClick={() => setSelectedComplaint(null)}
                style={{
                  ...actionButtonStyle,
                  width: 38,
                  height: 38,
                  padding: 0,
                  display: 'grid',
                  placeItems: 'center',
                }}
              >
                <X size={18} />
              </button>
            </div>

            <div
              style={{
                background: C.input,
                border: `1px solid ${C.border}`,
                borderRadius: 12,
                padding: 16,
                color: C.secondary,
                fontSize: 13,
                lineHeight: 1.8,
                whiteSpace: 'pre-wrap',
                overflowWrap: 'anywhere',
                marginBottom: 20,
              }}
            >
              {getDescription(selectedComplaint)}
            </div>

            <div style={{ display: 'grid', gap: 15 }}>
              {[
                ['Submitted by', getUser(selectedComplaint)],
                [
                  'Linked report',
                  `#${getReportId(selectedComplaint)}`,
                ],
                ['Issue type', getIssue(selectedComplaint)],
                ['Location', getLocation(selectedComplaint)],
                [
                  'Submitted at',
                  formatDate(getComplaintDate(selectedComplaint)),
                ],
                [
                  'Status',
                  getStatus(selectedComplaint).replaceAll('_', ' '),
                ],
              ].map(([label, value]) => (
                <div
                  key={label}
                  style={{
                    display: 'grid',
                    gridTemplateColumns:
                      '125px minmax(0, 1fr)',
                    gap: 12,
                    borderBottom: `1px solid ${C.border}`,
                    paddingBottom: 12,
                  }}
                >
                  <span style={{ color: C.muted, fontSize: 12 }}>
                    {label}
                  </span>

                  <span
                    style={{
                      fontSize: 13,
                      lineHeight: 1.6,
                      overflowWrap: 'anywhere',
                      textTransform:
                        label === 'Status' || label === 'Issue type'
                          ? 'capitalize'
                          : 'none',
                      color: C.text,
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
                flexWrap: 'wrap',
                gap: 10,
                marginTop: 24,
              }}
            >
              <button
                type="button"
                onClick={() => setSelectedComplaint(null)}
                style={actionButtonStyle}
              >
                Close
              </button>

              {getStatus(selectedComplaint) !== 'resolved' && (
                <button
                  type="button"
                  disabled={updatingId === selectedComplaint.id}
                  onClick={() =>
                    updateStatus(selectedComplaint, 'resolved')
                  }
                  style={{
                    ...actionButtonStyle,
                    background: 'var(--success-bg, rgba(34,197,94,0.12))',
                    borderColor: 'var(--success-border, #245D3B)',
                    color: C.green,
                    opacity:
                      updatingId === selectedComplaint.id ? 0.6 : 1,
                    cursor:
                      updatingId === selectedComplaint.id
                        ? 'wait'
                        : 'pointer',
                  }}
                >
                  {updatingId === selectedComplaint.id
                    ? 'Saving...'
                    : 'Mark as resolved'}
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </section>
  );
}
