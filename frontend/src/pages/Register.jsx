import api from "../api/axios";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { FaUser, FaEnvelope, FaLock } from "react-icons/fa";
import { toast } from "react-toastify";
import AuthLayout from "../layouts/AuthLayout";
import Input from "../components/Input";
import PasswordInput from "../components/PasswordInput";
import Button from "../components/Button";

const Register = () => {
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    name: "",
    email: "",
    password: "",
    confirmPassword: "",
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

    if (
      !formData.name.trim() ||
      !formData.email.trim() ||
      !formData.password ||
      !formData.confirmPassword
    ) {
      setError("Please fill all fields.");
      return;
    }

    if (formData.password.length < 6) {
      setError("Password must be at least 6 characters.");
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      setError("Passwords do not match.");
      return;
    }

    try {
      const response = await api.post("accounts/register/", {
        username: formData.name.trim(),
        email: formData.email.trim(),
        password: formData.password,
      });

      console.log("Registration successful:", response.data);

      setError("");

      toast.success("🎉 Account created successfully!");

      setTimeout(() => {
        navigate("/login");
      }, 1000);
    } catch (error) {
      console.error(
        "Registration failed:",
        error.response?.data || error.message
      );

      const backendError = error.response?.data;

      if (backendError?.username) {
        setError(backendError.username[0]);
      } else if (backendError?.email) {
        setError(backendError.email[0]);
      } else if (backendError?.password) {
        setError(backendError.password[0]);
      } else {
        setError("Registration failed. Please try again.");
      }
    }
  };

  return (
    <AuthLayout
      title="Create Your Account"
      subtitle="Join UrbanEye and help build smarter cities."
    >
      <form onSubmit={handleSubmit}>
        {error && (
          <div className="mb-4 rounded-xl bg-red-100 border border-red-200 p-3 text-sm text-red-600">
            {error}
          </div>
        )}

        <Input
          label="Full Name"
          name="name"
          value={formData.name}
          onChange={handleChange}
          placeholder="Enter your full name"
          icon={FaUser}
        />

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

        <PasswordInput
          label="Confirm Password"
          name="confirmPassword"
          value={formData.confirmPassword}
          onChange={handleChange}
          placeholder="Confirm your password"
          icon={FaLock}
        />

        <Button type="submit">
          Create Account
        </Button>

        <p className="mt-6 text-center text-gray-600">
          Already have an account?{" "}
          <Link
            to="/login"
            className="font-semibold text-blue-600 hover:underline"
          >
            Login
          </Link>
        </p>
      </form>
    </AuthLayout>
  );
};

export default Register;

