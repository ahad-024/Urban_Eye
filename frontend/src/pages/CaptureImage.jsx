
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import {
  FaCamera,
  FaImage,
  FaRobot,
  FaUpload,
} from "react-icons/fa";
import { toast } from "react-toastify";

import api from "../api/axios";
import MainLayout from "../layouts/MainLayout";
import PageHeader from "../components/PageHeader";
import Card from "../components/Card";
import Button from "../components/Button";
import LocationPicker from "../components/LocationPicker";

const CaptureImage = () => {
  const navigate = useNavigate();

  const [selectedFile, setSelectedFile] = useState(null);
  const [imagePreview, setImagePreview] = useState(null);
  const [location, setLocation] = useState(null);
  const [loading, setLoading] = useState(false);

  // --------------------------------
  // Cleanup preview URL
  // --------------------------------

  useEffect(() => {
    return () => {
      if (imagePreview) {
        URL.revokeObjectURL(imagePreview);
      }
    };
  }, [imagePreview]);

  // --------------------------------
  // Handle image selection
  // --------------------------------

  const handleImage = (e) => {
    const file = e.target.files?.[0];

    if (!file) {
      return;
    }

    if (!file.type.startsWith("image/")) {
      toast.error("Please select a valid image.");
      return;
    }

    if (imagePreview) {
      URL.revokeObjectURL(imagePreview);
    }

    // Keep the real File object for uploading.
    setSelectedFile(file);

    // Create temporary URL only for displaying the image.
    const previewUrl = URL.createObjectURL(file);

    setImagePreview(previewUrl);
  };

  // --------------------------------
  // Handle location selected
  // --------------------------------

  const handleLocationChange = (newLocation) => {
    setLocation(newLocation);
  };

  // --------------------------------
  // Analyze image
  // --------------------------------

  const analyzeImage = async () => {
    if (!selectedFile) {
      toast.error("Please select an image first.");
      return;
    }

    if (
      !location ||
      location.length < 2 ||
      location[0] === undefined ||
      location[1] === undefined ||
      location[0] === null ||
      location[1] === null
    ) {
      toast.error("Please select the issue location.");
      return;
    }

    try {
      setLoading(true);

      const accessToken =
        localStorage.getItem("access_token");

      if (!accessToken) {
        navigate("/login");
        return;
      }

      const latitude = Number(location[0]);
      const longitude = Number(location[1]);

      if (
        Number.isNaN(latitude) ||
        Number.isNaN(longitude)
      ) {
        toast.error(
          "Invalid location coordinates. Please select the location again."
        );
        return;
      }

      // --------------------------------
      // Create multipart FormData
      // --------------------------------

      const formData = new FormData();

      formData.append(
        "image",
        selectedFile
      );

      formData.append(
        "latitude",
        latitude
      );

      formData.append(
        "longitude",
        longitude
      );

      // --------------------------------
      // AI Analysis
      // --------------------------------

      const response = await api.post(
        "reports/analyze/",
        formData,
        {
          headers: {
            Authorization:
              `Bearer ${accessToken}`,
          },
        }
      );

      // --------------------------------
      // Readable location
      // --------------------------------

      const locationName =
        response.data?.location_name || "";

      // --------------------------------
      // Navigate to AI Result
      // --------------------------------

      navigate("/analysis", {
        state: {
          // Real File object for future upload
          imageFile: selectedFile,

          // Preview URL only for display
          imagePreview,

          // AI response
          result: response.data,

          // GPS coordinates
          location: {
            latitude,
            longitude,
          },

          // Reverse-geocoded location
          locationName,
        },
      });

    } catch (error) {
      console.error(
        "AI analysis failed:",
        error.response?.data ||
          error.message
      );

      // JWT expired/invalid
      if (
        error.response?.status === 401
      ) {
        localStorage.removeItem(
          "access_token"
        );

        localStorage.removeItem(
          "refresh_token"
        );

        localStorage.removeItem(
          "user"
        );

        navigate("/login");
        return;
      }

      toast.error(
        error.response?.data?.error ||
          "Failed to analyze image. Please try again."
      );

    } finally {
      setLoading(false);
    }
  };

  return (
    <MainLayout>

      <PageHeader
        title="AI Image Detection"
        backTo="/home"
      />

      <Card
        maxWidth="max-w-3xl"
        className="mx-auto text-center"
      >

        {/* AI Icon */}
        <div className="w-24 h-24 mx-auto rounded-full bg-blue-100 flex items-center justify-center mb-6">
          <FaRobot className="text-blue-600 text-5xl" />
        </div>

        {/* Title */}
        <h2 className="text-3xl font-bold">
          Analyze Civic Issue
        </h2>

        <p className="text-gray-500 mt-3">
          Upload an image and UrbanEye AI will detect the problem.
        </p>

        {/* Image Preview */}
        <div className="mt-8 border-2 border-dashed border-blue-300 rounded-3xl p-6">

          {imagePreview ? (

            <img
              src={imagePreview}
              alt="Selected civic issue"
              className="w-full h-64 object-cover rounded-2xl"
            />

          ) : (

            <div>

              <FaImage className="mx-auto text-6xl text-gray-300" />

              <p className="mt-4 text-gray-400">
                No image selected
              </p>

            </div>

          )}

        </div>

        {/* Choose Image */}
        <label
          className="
            mt-6
            bg-blue-600
            text-white
            py-4
            px-6
            rounded-2xl
            font-bold
            cursor-pointer
            flex
            items-center
            justify-center
            gap-3
            hover:bg-blue-700
            transition
          "
        >

          <FaUpload />

          Choose Image

          <input
            type="file"
            accept="image/*"
            hidden
            onChange={handleImage}
          />

        </label>

        {/* Location Picker */}
        <div className="mt-8 text-left">

          <LocationPicker
            value={location}
            onChange={handleLocationChange}
          />

        </div>

        {/* Analyze Button */}
        <Button
          className="mt-6"
          onClick={analyzeImage}
          disabled={loading}
        >

          <FaCamera className="inline mr-2" />

          {loading
            ? "Analyzing..."
            : "Analyze Image"}

        </Button>

      </Card>

    </MainLayout>
  );
};

export default CaptureImage;
