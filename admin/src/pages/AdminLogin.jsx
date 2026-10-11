import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ShieldCheck, Eye, EyeOff, LoaderCircle } from 'lucide-react';
import { api, authStorage } from '../services/api';
import './AdminLogin.css';

export default function AdminLogin() {
  const navigate = useNavigate();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  async function handleSubmit(event) {
    event.preventDefault();
    setError('');

    if (!email.trim() || !password) {
      setError('Please enter your email and password.');
      return;
    }

    setLoading(true);

    try {
      const data = await api.adminLogin(email.trim(), password);

      authStorage.saveSession(data);

      navigate('/', { replace: true });
    } catch (err) {
      setError(err.message || 'Unable to sign in. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="admin-login-page">
      <div className="admin-login-glow" />

      <form className="admin-login-card" onSubmit={handleSubmit}>
        <div className="admin-login-logo">
          <ShieldCheck size={30} />
        </div>

        <p className="admin-login-eyebrow">URBANEYE ADMINISTRATION</p>
        <h1>Welcome back</h1>
        <p className="admin-login-description">
          Sign in to manage civic reports and complaints.
        </p>

        {error && (
          <div className="admin-login-error" role="alert">
            {error}
          </div>
        )}

        <label htmlFor="admin-email">Email address</label>
        <input
          id="admin-email"
          type="email"
          placeholder="admin@example.com"
          autoComplete="username"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          required
        />

        <label htmlFor="admin-password">Password</label>
        <div className="admin-password-field">
          <input
            id="admin-password"
            type={showPassword ? 'text' : 'password'}
            placeholder="Enter your password"
            autoComplete="current-password"
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            required
          />

          <button
            type="button"
            className="admin-password-toggle"
            onClick={() => setShowPassword((value) => !value)}
            aria-label={showPassword ? 'Hide password' : 'Show password'}
          >
            {showPassword ? <EyeOff size={19} /> : <Eye size={19} />}
          </button>
        </div>

        <button
          className="admin-login-submit"
          type="submit"
          disabled={loading}
        >
          {loading ? (
            <>
              <LoaderCircle size={18} className="admin-login-spinner" />
              Signing in...
            </>
          ) : (
            'Sign in to dashboard'
          )}
        </button>

        <div className="admin-login-security">
          <ShieldCheck size={15} />
          <span>Secure administrator access</span>
        </div>
      </form>
    </div>
  );
}