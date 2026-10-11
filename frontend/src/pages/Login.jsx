import api from "../api/axios";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { FaEnvelope, FaLock } from "react-icons/fa";
import { toast } from "react-toastify";
import AuthLayout from "../layouts/AuthLayout";
import Input from "../components/Input";
import PasswordInput from "../components/PasswordInput";
import Button from "../components/Button";

const Login = () => {
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    email: "",
    password: "",
  });

  const [error, setError] = useState("");

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });

    setError("");
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!formData.email.trim() || !formData.password) {
      setError("Please fill all fields.");
      return;
    }

    try {
      const response = await api.post("accounts/login/", {
        email: formData.email.trim(),
        password: formData.password,
      });

      const { access, refresh } = response.data;

      localStorage.setItem("access_token", access);
      localStorage.setItem("refresh_token", refresh);

      
      const profileResponse = await api.get("accounts/profile/", {
        headers: {
          Authorization: `Bearer ${access}`,
        },
      });

      const user = profileResponse.data;

  
      localStorage.setItem("user", JSON.stringify(user));

      setError("");

      toast.success(`Welcome back, ${user.username}!`);

      setTimeout(() => {
        navigate("/home");
      }, 1000);

    } catch (error) {
      console.error(
        "Login failed:",
        error.response?.data || error.message
      );

      const backendError = error.response?.data;

      if (backendError?.detail) {
        setError(backendError.detail);
      } else {
        setError("Login failed. Please check your credentials.");
      }
    }
  };

  return (
    <AuthLayout
      title="Welcome Back"
      subtitle="Login to continue using UrbanEye."
    >
      <form onSubmit={handleSubmit}>

        {error && (
          <div className="mb-4 rounded-xl bg-red-100 border border-red-200 p-3 text-sm text-red-600">
            {error}
          </div>
        )}

        <Input
          label="Email"
          name="email"
          type="email"
          value={formData.email}
          onChange={handleChange}
          placeholder="Enter your email"
          icon={FaEnvelope}
        />

        <PasswordInput
          label="Password"
          name="password"
          value={formData.password}
          onChange={handleChange}
          placeholder="Enter your password"
          icon={FaLock}
        />

        <Button type="submit">
          Login
        </Button>

        <p className="mt-6 text-center text-gray-600">
          Don't have an account?{" "}
          <Link
            to="/register"
            className="font-semibold text-blue-600 hover:underline"
          >
            Create Account
          </Link>
        </p>

      </form>
    </AuthLayout>
  );
};

export default Login;
