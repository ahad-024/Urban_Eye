import { useEffect, useState } from "react";
import {
  User,
  Bell,
  Palette,
  ShieldCheck,
  Info,
  Save,
  RotateCcw,
} from "lucide-react";
import { api, authStorage } from "../services/api";

const PURPLE = "#8B5CF6";
const STORAGE_KEY = "urbaneye_admin_preferences";

const DEFAULT_SETTINGS = {
  emailNotifications: true,
  reportAlerts: true,
  complaintAlerts: true,
  darkMode: true,
};

function readSettings() {
  try {
    const saved = JSON.parse(
      localStorage.getItem(STORAGE_KEY) || "{}"
    );

    return {
      emailNotifications:
        typeof saved.emailNotifications === "boolean"
          ? saved.emailNotifications
          : DEFAULT_SETTINGS.emailNotifications,
      reportAlerts:
        typeof saved.reportAlerts === "boolean"
          ? saved.reportAlerts
          : DEFAULT_SETTINGS.reportAlerts,
      complaintAlerts:
        typeof saved.complaintAlerts === "boolean"
          ? saved.complaintAlerts
          : DEFAULT_SETTINGS.complaintAlerts,
      darkMode:
        typeof saved.darkMode === "boolean"
          ? saved.darkMode
          : DEFAULT_SETTINGS.darkMode,
    };
  } catch {
    return { ...DEFAULT_SETTINGS };
  }
}

function applyTheme(darkMode) {
  const theme = darkMode ? "dark" : "light";

  document.documentElement.setAttribute("data-theme", theme);
  document.documentElement.style.colorScheme = theme;
  document.body?.setAttribute("data-theme", theme);
}

function saveSettings(settings) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(settings));
}

const cardStyle = {
  background: "var(--ue-card, #111114)",
  border: "1px solid var(--ue-border, #25252C)",
  borderRadius: 16,
  padding: 22,
  color: "var(--ue-text, #F4F4F5)",
  minWidth: 0,
};

const labelStyle = {
  color: "var(--ue-text, #F4F4F5)",
  fontSize: 14,
  fontWeight: 600,
};

const descriptionStyle = {
  color: "var(--ue-muted, #92929D)",
  fontSize: 12,
  lineHeight: 1.6,
  marginTop: 5,
};

function Toggle({ checked, onChange }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      onClick={() => onChange(!checked)}
      style={{
        width: 44,
        height: 25,
        flexShrink: 0,
        border: 0,
        borderRadius: 20,
        padding: 3,
        display: "flex",
        alignItems: "center",
        justifyContent: checked ? "flex-end" : "flex-start",
        background: checked ? PURPLE : "#71717A",
        cursor: "pointer",
      }}
    >
      <span
        style={{
          display: "block",
          width: 19,
          height: 19,
          borderRadius: "50%",
          background: "#FFFFFF",
        }}
      />
    </button>
  );
}

function SettingRow({ title, description, checked, onChange }) {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        gap: 16,
        padding: "17px 0",
        borderBottom: "1px solid var(--ue-border, #25252C)",
      }}
    >
      <div>
        <div style={labelStyle}>{title}</div>
        <div style={descriptionStyle}>{description}</div>
      </div>

      <Toggle checked={checked} onChange={onChange} />
    </div>
  );
}

function SectionHeading({ icon: Icon, title, subtitle }) {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 12,
        marginBottom: 22,
      }}
    >
      <div
        style={{
          background: "var(--ue-icon-bg, #291A43)",
          padding: 10,
          borderRadius: 10,
        }}
      >
        <Icon color="#A78BFA" size={21} />
      </div>

      <div>
        <h2 style={{ fontSize: 17, margin: 0 }}>{title}</h2>
        <p style={{ ...descriptionStyle, marginBottom: 0 }}>
          {subtitle}
        </p>
      </div>
    </div>
  );
}

export default function Settings() {
  const [profile, setProfile] = useState(
    () => authStorage.getUser() || {}
  );
  const [settings, setSettings] = useState(readSettings);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [feedback, setFeedback] = useState(null);

  // Apply the current theme immediately and keep it synchronized.
  useEffect(() => {
    applyTheme(settings.darkMode);
  }, [settings.darkMode]);

  // Preserve the existing Django profile integration.
  useEffect(() => {
    let active = true;

    async function loadProfile() {
      try {
        const response = await api.getProfile();
        const data = response?.user || response;

        if (active && data) {
          setProfile((previous) => ({
            ...previous,
            ...data,
          }));
        }
      } catch {
        if (active) {
          setFeedback({
            type: "error",
            text: "Could not load the latest Django profile. Showing saved account information.",
          });
        }
      } finally {
        if (active) setLoading(false);
      }
    }

    loadProfile();

    return () => {
      active = false;
    };
  }, []);

  function updateSetting(key, value) {
    setSettings((previous) => ({
      ...previous,
      [key]: value,
    }));

    setFeedback(null);
  }

  function handleSave() {
    setSaving(true);
    setFeedback(null);

    try {
      saveSettings(settings);
      applyTheme(settings.darkMode);

      setFeedback({
        type: "success",
        text: "Preferences saved successfully.",
      });
    } catch {
      setFeedback({
        type: "error",
        text: "Unable to save preferences. Check your browser storage settings.",
      });
    } finally {
      setSaving(false);
    }
  }

  function handleReset() {
    try {
      const defaults = { ...DEFAULT_SETTINGS };

      // Persist the defaults and apply them immediately.
      saveSettings(defaults);
      setSettings(defaults);
      applyTheme(defaults.darkMode);

      setFeedback({
        type: "success",
        text: "Preferences reset to their default values.",
      });
    } catch {
      setFeedback({
        type: "error",
        text: "Unable to reset preferences in this browser.",
      });
    }
  }

  const displayName =
    profile.username ||
    profile.email?.split("@")[0] ||
    "Administrator";

  const initials = displayName.slice(0, 2).toUpperCase();

  const apiUrl =
    import.meta.env.VITE_API_BASE_URL ||
    "http://127.0.0.1:8000";

  return (
    <div
      style={{
        minHeight: "100%",
        padding: 28,
        boxSizing: "border-box",
        background: "var(--ue-page-bg, #09090B)",
        color: "var(--ue-text, #F4F4F5)",
        fontFamily: "Inter, system-ui, sans-serif",
      }}
    >
      <div style={{ maxWidth: 1100, margin: "0 auto" }}>
        <header style={{ marginBottom: 28 }}>
          <div
            style={{
              color: PURPLE,
              fontSize: 12,
              fontWeight: 700,
              letterSpacing: 2,
            }}
          >
            ADMINISTRATION
          </div>

          <h1 style={{ fontSize: 30, margin: "9px 0" }}>
            Settings
          </h1>

          <p style={{ color: "var(--ue-muted, #92929D)", margin: 0 }}>
            Manage your administrator profile and application preferences.
          </p>
        </header>

        {feedback && (
          <div
            key={`${feedback.type}-${feedback.text}`}
            role={feedback.type === "error" ? "alert" : "status"}
            style={{
              padding: 14,
              marginBottom: 18,
              borderRadius: 10,
              border: `1px solid ${
                feedback.type === "success" ? "#28583B" : "#653038"
              }`,
              background:
                feedback.type === "success" ? "#14251B" : "#291719",
              color:
                feedback.type === "success" ? "#86EFAC" : "#FCA5A5",
              fontSize: 13,
            }}
          >
            {feedback.text}
          </div>
        )}

        <div
          style={{
            display: "grid",
            gridTemplateColumns:
              "repeat(auto-fit, minmax(min(100%, 320px), 1fr))",
            gap: 20,
          }}
        >
          <section style={cardStyle}>
            <SectionHeading
              icon={User}
              title="Administrator Profile"
              subtitle="Your account information"
            />

            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 15,
                marginBottom: 23,
              }}
            >
              <div
                style={{
                  width: 60,
                  height: 60,
                  borderRadius: 18,
                  background: "linear-gradient(135deg, #7C3AED, #4C1D95)",
                  display: "grid",
                  placeItems: "center",
                  color: "#FFFFFF",
                  fontSize: 21,
                  fontWeight: 800,
                }}
              >
                {initials}
              </div>

              <div>
                <div style={{ fontSize: 17, fontWeight: 700 }}>
                  {displayName}
                </div>
                <div style={{ color: "#A78BFA", fontSize: 12, marginTop: 5 }}>
                  Administrator
                </div>
              </div>
            </div>

            <div style={{ marginBottom: 18 }}>
              <div style={labelStyle}>Username</div>
              <div style={descriptionStyle}>
                {loading ? "Loading..." : profile.username || "Not available"}
              </div>
            </div>

            <div style={{ marginBottom: 18 }}>
              <div style={labelStyle}>Email address</div>
              <div style={descriptionStyle}>
                {profile.email || "Not available"}
              </div>
            </div>

            <div>
              <div style={labelStyle}>Account role</div>
              <div style={{ ...descriptionStyle, color: "#16A34A" }}>
                {profile.is_superuser
                  ? "Superuser"
                  : profile.is_staff
                    ? "Staff administrator"
                    : "Standard user"}
              </div>
            </div>

            <div
              style={{
                marginTop: 22,
                padding: 12,
                borderRadius: 10,
                background: "var(--ue-subtle, #18181D)",
                display: "flex",
                alignItems: "center",
                gap: 9,
                color: "var(--ue-muted, #A1A1AA)",
                fontSize: 12,
              }}
            >
              <ShieldCheck size={17} color="#16A34A" />
              Profile information is retrieved from Django.
            </div>
          </section>

          <section style={cardStyle}>
            <SectionHeading
              icon={Bell}
              title="Notifications"
              subtitle="Manage your alert preferences"
            />

            <SettingRow
              title="Email notifications"
              description="Receive important updates by email."
              checked={settings.emailNotifications}
              onChange={(value) => updateSetting("emailNotifications", value)}
            />

            <SettingRow
              title="New report alerts"
              description="Get notified about incoming civic reports."
              checked={settings.reportAlerts}
              onChange={(value) => updateSetting("reportAlerts", value)}
            />

            <SettingRow
              title="Complaint updates"
              description="Track complaint activity and status changes."
              checked={settings.complaintAlerts}
              onChange={(value) => updateSetting("complaintAlerts", value)}
            />

            <div
              style={{
                display: "flex",
                gap: 9,
                marginTop: 18,
                color: "var(--ue-muted, #92929D)",
                fontSize: 12,
                lineHeight: 1.6,
              }}
            >
              <Info size={16} color={PURPLE} />
              These are saved preferences. Actual notification delivery
              requires a backend notification service.
            </div>
          </section>

          <section style={cardStyle}>
            <SectionHeading
              icon={Palette}
              title="Appearance"
              subtitle="Customize your admin experience"
            />

            <SettingRow
              title="Dark appearance"
              description={
                settings.darkMode
                  ? "Dark theme is enabled."
                  : "Light theme is enabled."
              }
              checked={settings.darkMode}
              onChange={(value) => updateSetting("darkMode", value)}
            />

            <p style={{ ...descriptionStyle, marginTop: 16 }}>
              The theme changes immediately. Save your preferences to
              keep the selection after reopening the application.
            </p>
          </section>

          <section style={cardStyle}>
            <SectionHeading
              icon={ShieldCheck}
              title="Security & Application"
              subtitle="Session and app information"
            />

            <div style={{ marginBottom: 19 }}>
              <div style={labelStyle}>Authentication</div>
              <div style={descriptionStyle}>JWT access and refresh tokens</div>
            </div>

            <div style={{ marginBottom: 19 }}>
              <div style={labelStyle}>API server</div>
              <div style={{ ...descriptionStyle, overflowWrap: "anywhere" }}>
                {apiUrl}
              </div>
            </div>

            <div style={{ marginBottom: 19 }}>
              <div style={labelStyle}>Application version</div>
              <div style={descriptionStyle}>UrbanEye Admin v1.0.0</div>
            </div>

            <div
              style={{
                borderTop: "1px solid var(--ue-border, #25252C)",
                paddingTop: 16,
                color: "var(--ue-muted, #92929D)",
                fontSize: 12,
                display: "flex",
                gap: 8,
                alignItems: "center",
              }}
            >
              <ShieldCheck size={16} color="#16A34A" />
              Django APIs must enforce authorization.
            </div>
          </section>
        </div>

        <div
          style={{
            display: "flex",
            justifyContent: "flex-end",
            flexWrap: "wrap",
            gap: 12,
            marginTop: 24,
          }}
        >
          <button
            type="button"
            onClick={handleReset}
            disabled={saving}
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 8,
              padding: "12px 17px",
              border: "1px solid var(--ue-border, #34343D)",
              background: "var(--ue-subtle, #151519)",
              color: "var(--ue-text, #D4D4D8)",
              borderRadius: 10,
              cursor: "pointer",
            }}
          >
            <RotateCcw size={16} />
            Reset preferences
          </button>

          <button
            type="button"
            onClick={handleSave}
            disabled={saving}
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 8,
              padding: "12px 20px",
              border: "none",
              background: PURPLE,
              color: "#FFFFFF",
              borderRadius: 10,
              fontWeight: 700,
              cursor: saving ? "wait" : "pointer",
              opacity: saving ? 0.7 : 1,
            }}
          >
            <Save size={16} />
            {saving ? "Saving..." : "Save preferences"}
          </button>
        </div>
      </div>
    </div>
  );
}