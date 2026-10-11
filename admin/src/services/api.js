const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000';

const ACCESS_TOKEN_KEY = 'urbaneye_admin_access';
const REFRESH_TOKEN_KEY = 'urbaneye_admin_refresh';
const ADMIN_USER_KEY = 'urbaneye_admin_user';

export const authStorage = {
  getAccessToken() {
    return localStorage.getItem(ACCESS_TOKEN_KEY);
  },

  getRefreshToken() {
    return localStorage.getItem(REFRESH_TOKEN_KEY);
  },

  getUser() {
    const user = localStorage.getItem(ADMIN_USER_KEY);

    try {
      return user ? JSON.parse(user) : null;
    } catch {
      return null;
    }
  },

  saveSession(data) {
    if (!data?.access || !data?.refresh || !data?.user?.is_staff) {
      throw new Error('Invalid administrator login response.');
    }

    localStorage.setItem(ACCESS_TOKEN_KEY, data.access);
    localStorage.setItem(REFRESH_TOKEN_KEY, data.refresh);
    localStorage.setItem(ADMIN_USER_KEY, JSON.stringify(data.user));
  },

  clearSession() {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    localStorage.removeItem(ADMIN_USER_KEY);
  },
};

async function refreshAccessToken() {
  const refresh = authStorage.getRefreshToken();

  if (!refresh) {
    authStorage.clearSession();
    return null;
  }

  try {
    const response = await fetch(
      `${API_BASE_URL}/api/accounts/token/refresh/`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refresh }),
      }
    );

    if (!response.ok) {
      authStorage.clearSession();
      return null;
    }

    const data = await response.json();

    if (!data.access) {
      authStorage.clearSession();
      return null;
    }

    localStorage.setItem(ACCESS_TOKEN_KEY, data.access);

    if (data.refresh) {
      localStorage.setItem(REFRESH_TOKEN_KEY, data.refresh);
    }

    return data.access;
  } catch {
    // Keep the session intact during temporary network failures.
    return null;
  }
}

async function request(endpoint, options = {}, retry = true) {
  const headers = new Headers(options.headers || {});
  const token = authStorage.getAccessToken();
  const isFormData =
    typeof FormData !== 'undefined' && options.body instanceof FormData;

  if (token) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  if (options.body && !isFormData) {
    headers.set('Content-Type', 'application/json');
  }

  let response;

  try {
    response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers,
    });
  } catch {
    throw new Error(
      'Cannot connect to the UrbanEye backend. Check that Django is running.'
    );
  }

  if (
    response.status === 401 &&
    retry &&
    endpoint !== '/api/accounts/admin-login/'
  ) {
    const newToken = await refreshAccessToken();

    if (newToken) {
      return request(
        endpoint,
        {
          ...options,
          headers: {
            ...Object.fromEntries(headers.entries()),
            Authorization: `Bearer ${newToken}`,
          },
        },
        false
      );
    }
  }

  const contentType = response.headers.get('content-type') || '';
  const data = contentType.includes('application/json')
    ? await response.json()
    : await response.text();

  if (!response.ok) {
    const message =
      typeof data === 'object' && data !== null
        ? data.detail ||
          data.error ||
          data.message ||
          Object.values(data).flat().join(' ')
        : data;

    throw new Error(
      message || `Request failed with status ${response.status}.`
    );
  }

  return data;
}

export const api = {
  adminLogin(email, password) {
    return request('/api/accounts/admin-login/', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
  },

  getDashboardStats() {
    return request('/api/dashboard/stats/');
  },

  getReports() {
    return request('/api/reports/admin/');
  },

  getReport(id) {
    return request(`/api/reports/admin/${id}/`);
  },

  updateReport(id, updates) {
    return request(`/api/reports/admin/${id}/`, {
      method: 'PATCH',
      body: JSON.stringify(updates),
    });
  },

  getComplaints() {
    return request('/api/complaints/admin/');
  },

  getComplaint(id) {
    return request(`/api/complaints/admin/${id}/`);
  },

  updateComplaint(id, updates) {
    return request(`/api/complaints/admin/${id}/`, {
      method: 'PATCH',
      body: JSON.stringify(updates),
    });
  },

  // Fetch real registered accounts for the admin Users page.
  getUsers() {
    return request('/api/accounts/admin/users/');
  },

  getProfile() {
    return request('/api/accounts/profile/');
  },

  logout(refresh) {
    return request('/api/accounts/logout/', {
      method: 'POST',
      body: JSON.stringify({ refresh }),
    });
  },
};
