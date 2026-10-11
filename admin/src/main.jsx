
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css';

// Load the saved theme before rendering the application.
const savedPreferences = (() => {
  try {
    return JSON.parse(
      localStorage.getItem('urbaneye_admin_preferences') || '{}'
    );
  } catch {
    return {};
  }
})();

document.documentElement.dataset.theme =
  savedPreferences.darkMode === false ? 'light' : 'dark';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
