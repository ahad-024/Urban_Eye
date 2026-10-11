
import { useLocation, useNavigate } from "react-router-dom";
import {
  FaArrowRight,
  FaCheckCircle,
  FaMapMarkerAlt,
  FaRobot,
} from "react-icons/fa";

import MainLayout from "../layouts/MainLayout";
import PageHeader from "../components/PageHeader";
import Card from "../components/Card";
import Button from "../components/Button";

const AIResult = () => {
  const navigate = useNavigate();
  const location = useLocation();

  // --------------------------------
  // Image
  // --------------------------------

  // Actual File object.
  // This must be used when submitting
  // the final complaint.
  const imageFile =
    location.state?.imageFile || null;

  // Temporary preview URL.
  // This is ONLY used to display the image.
  const imagePreview =
    location.state?.imagePreview ||
    location.state?.image ||
    "";

  const result =
    location.state?.result || {};

  // --------------------------------
  // AI Result
  // --------------------------------

  const issueType =
    result.issue_type ||
    result.issue ||
    "Unknown Issue";

  const severity =
    result.severity ||
    "Unknown";

  const confidence =
    result.confidence ?? 0;

  // --------------------------------
  // Location
  // --------------------------------

  const gpsLocation =
    location.state?.location ||
    (
      result.latitude !== undefined &&
      result.longitude !== undefined
        ? {
            latitude: result.latitude,
            longitude: result.longitude,
          }
        : null
    );

  // Readable address
  const locationName =
    result.location_name ||
    location.state?.locationName ||
    "";

  // --------------------------------
  // Confidence formatting
  // --------------------------------

  const confidenceValue =
    Number(confidence) <= 1
      ? Number(confidence) * 100
      : Number(confidence);

  const formattedConfidence =
    Math.round(confidenceValue);

  // --------------------------------
  // Create Complaint
  // --------------------------------

  const handleCreateComplaint = () => {
    if (!gpsLocation) {
      return;
    }

    if (!imageFile) {
      return;
    }

    navigate("/create-complaint", {
      state: {
        // IMPORTANT:
        // Pass the actual File object.
        imageFile,

        // Keep preview separately for UI.
        imagePreview,

        issueType,

        severity,

        confidence,

        // Preserve GPS coordinates.
        location: gpsLocation,

        // Preserve readable address.
        locationName,
      },
    });
  };

  return (
    <MainLayout>

      <PageHeader
        title="AI Analysis Result"
        backTo="/capture"
      />

      <Card
        maxWidth="max-w-3xl"
        className="mx-auto"
      >

        {/* -------------------------------- */}
        {/* AI Header */}
        {/* -------------------------------- */}

        <div className="text-center">

          <div className="w-20 h-20 mx-auto rounded-full bg-blue-100 flex items-center justify-center mb-5">

            <FaRobot className="text-blue-600 text-4xl" />

          </div>

          <h2 className="text-3xl font-bold text-gray-900">
            AI Analysis Complete
          </h2>

          <p className="text-gray-500 mt-2">
            UrbanEye has analyzed your civic issue.
          </p>

        </div>

        {/* -------------------------------- */}
        {/* Image */}
        {/* -------------------------------- */}

        {imagePreview && (
          <div className="mt-8">

            <img
              src={imagePreview}
              alt="Analyzed civic issue"
              className="w-full h-72 object-cover rounded-3xl"
            />

          </div>
        )}

        {/* -------------------------------- */}
        {/* Detection Result */}
        {/* -------------------------------- */}

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-8">

          {/* Issue */}
          <div className="bg-blue-50 border border-blue-100 rounded-2xl p-5">

            <p className="text-sm text-gray-500">
              Detected Issue
            </p>

            <p className="text-xl font-bold text-blue-700 mt-1 capitalize">
              {String(issueType).replace(
                /_/g,
                " "
              )}
            </p>

          </div>

          {/* Severity */}
          <div className="bg-orange-50 border border-orange-100 rounded-2xl p-5">

            <p className="text-sm text-gray-500">
              Severity
            </p>

            <p className="text-xl font-bold text-orange-600 mt-1 capitalize">
              {severity}
            </p>

          </div>

          {/* Confidence */}
          <div className="bg-green-50 border border-green-100 rounded-2xl p-5">

            <p className="text-sm text-gray-500">
              Confidence
            </p>

            <p className="text-xl font-bold text-green-600 mt-1">
              {formattedConfidence}%
            </p>

          </div>

        </div>

        {/* -------------------------------- */}
        {/* Location */}
        {/* -------------------------------- */}

        <div className="mt-8">

          <div className="flex items-center gap-2 mb-3">

            <FaMapMarkerAlt className="text-red-500" />

            <h3 className="text-lg font-bold text-gray-900">
              Issue Location
            </h3>

          </div>

          {locationName ? (

            <div className="bg-green-50 border border-green-200 rounded-2xl p-5">

              <div className="flex items-start gap-3">

                <FaCheckCircle className="text-green-600 text-xl mt-1 flex-shrink-0" />

                <div>

                  <p className="font-semibold text-green-700">
                    Location detected
                  </p>

                  <p className="text-sm text-gray-500 mt-1">
                    Automatically detected from the selected GPS location.
                  </p>

                  <p className="text-base font-bold text-gray-800 mt-3">
                    {locationName}
                  </p>

                </div>

              </div>

            </div>

          ) : (

            <div className="bg-yellow-50 border border-yellow-200 rounded-2xl p-5">

              <p className="font-medium text-yellow-700">
                GPS location captured successfully.
              </p>

              <p className="text-sm text-yellow-600 mt-1">
                A readable address could not be detected yet.
              </p>

            </div>

          )}

        </div>

        {/* -------------------------------- */}
        {/* Location Status */}
        {/* -------------------------------- */}

        <div className="mt-4 bg-gray-50 border border-gray-200 rounded-2xl p-4">

          <div className="flex items-center gap-3">

            <FaCheckCircle className="text-green-500" />

            <p className="text-sm text-gray-600">
              GPS coordinates have been captured and will be attached to your complaint.
            </p>

          </div>

        </div>

        {/* -------------------------------- */}
        {/* Create Complaint */}
        {/* -------------------------------- */}

        <Button
          className="w-full mt-8"
          onClick={handleCreateComplaint}
          disabled={!gpsLocation || !imageFile}
        >

          Create Complaint

          <FaArrowRight className="inline ml-2" />

        </Button>

        {!imageFile && (
          <p className="text-center text-sm text-red-500 mt-3">
            Image file is missing. Please capture the image again.
          </p>
        )}

        {imageFile && !gpsLocation && (
          <p className="text-center text-sm text-red-500 mt-3">
            Location is required before creating a complaint.
          </p>
        )}

      </Card>

    </MainLayout>
  );
};

export default AIResult;
