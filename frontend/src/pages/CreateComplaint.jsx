
import { useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import {
  FaArrowLeft,
  FaCheckCircle,
  FaMapMarkerAlt,
  FaPaperPlane,
  FaRobot,
} from "react-icons/fa";
import { toast } from "react-toastify";

import api from "../api/axios";
import MainLayout from "../layouts/MainLayout";
import PageHeader from "../components/PageHeader";
import Card from "../components/Card";
import Button from "../components/Button";

const CreateComplaint = () => {
  const navigate = useNavigate();
  const location = useLocation();

  // --------------------------------
  // Data received from AI Result
  // --------------------------------

  const imageFile =
    location.state?.imageFile || null;

  const imagePreview =
    location.state?.imagePreview ||
    location.state?.image ||
    "";

  const issueType =
    location.state?.issueType || "";

  const severity =
    location.state?.severity || "";

  const confidence =
    location.state?.confidence ?? 0;

  const gpsLocation =
    location.state?.location || null;

  const locationName =
    location.state?.locationName || "";

  // --------------------------------
  // State
  // --------------------------------

  const [description, setDescription] =
    useState("");

  const [loading, setLoading] =
    useState(false);

  // --------------------------------
  // Submit complaint
  // --------------------------------

  const handleSubmit = async (e) => {
    e.preventDefault();

    // --------------------------------
    // Validate required data
    // --------------------------------

    if (!imageFile) {
      toast.error(
        "Issue image is missing. Please capture the image again."
      );
      return;
    }

    if (!issueType) {
      toast.error(
        "Issue type is missing."
      );
      return;
    }

    if (!severity) {
      toast.error(
        "Severity is missing."
      );
      return;
    }

    if (
      !gpsLocation ||
      gpsLocation.latitude === undefined ||
      gpsLocation.longitude === undefined
    ) {
      toast.error(
        "Issue location is missing."
      );
      return;
    }

    try {
      setLoading(true);

      // --------------------------------
      // Authentication
      // --------------------------------

      const accessToken =
        localStorage.getItem(
          "access_token"
        );

      if (!accessToken) {
        navigate("/login");
        return;
      }

      // --------------------------------
      // Create FormData
      // --------------------------------

      const formData =
        new FormData();

      // Actual image file
      formData.append(
        "image",
        imageFile,
        imageFile.name ||
          "urbaneye-report.jpg"
      );

      // AI detected issue
      formData.append(
        "issue_type",
        issueType
      );

      // AI detected severity
      formData.append(
        "severity",
        severity
      );

      // AI confidence
      formData.append(
        "confidence",
        confidence
      );

      // Optional description
      formData.append(
        "description",
        description.trim()
      );

      // --------------------------------
      // GPS Coordinates
      // --------------------------------

      formData.append(
        "latitude",
        gpsLocation.latitude
      );

      formData.append(
        "longitude",
        gpsLocation.longitude
      );

      // --------------------------------
      // Create Report
      // --------------------------------

      const reportResponse =
        await api.post(
          "reports/analyze-and-create/",
          formData,
          {
            headers: {
              Authorization:
                `Bearer ${accessToken}`,
            },
          }
        );

      const createdReport =
        reportResponse.data;

      // --------------------------------
      // Create Complaint
      // --------------------------------

      const formattedIssueType =
        String(
          createdReport.issue_type ||
            issueType
        )
          .replace(/_/g, " ")
          .replace(
            /\b\w/g,
            (char) =>
              char.toUpperCase()
          );

      const complaintData = {
        report: createdReport.id,

        title:
          `Civic Issue Report - ${formattedIssueType}`,

        description:
          description.trim(),
      };

      const complaintResponse =
        await api.post(
          "complaints/",
          complaintData,
          {
            headers: {
              Authorization:
                `Bearer ${accessToken}`,
            },
          }
        );

      // --------------------------------
      // Save latest report locally
      // --------------------------------

      localStorage.setItem(
        "urbaneye_last_report",
        JSON.stringify({
          id: createdReport.id,

          complaintId:
            complaintResponse.data?.id
              ? `UE-${complaintResponse.data.id}`
              : `UE-${createdReport.id}`,

          issueType:
            createdReport.issue_type,

          severity:
            createdReport.severity,

          confidence:
            createdReport.confidence,

          latitude:
            createdReport.latitude,

          longitude:
            createdReport.longitude,

          location_name:
            createdReport.location_name ||
            locationName ||
            "",
        })
      );

      // --------------------------------
      // Success
      // --------------------------------

      toast.success(
        "Complaint submitted successfully."
      );

      navigate("/success", {
        state: {
          report: createdReport,

          complaint:
            complaintResponse.data,

          // Pass real File
          imageFile,

          // Pass preview separately
          imagePreview,

          locationName:
            createdReport.location_name ||
            locationName ||
            "",
        },
      });

    } catch (error) {
      console.error(
        "Complaint submission failed:",
        error.response?.data ||
          error.message
      );

      // --------------------------------
      // Unauthorized
      // --------------------------------

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

      // --------------------------------
      // Backend error
      // --------------------------------

      const backendError =
        error.response?.data;

      if (
        typeof backendError ===
        "object" &&
        backendError !== null
      ) {
        const firstError =
          Object.values(
            backendError
          )[0];

        if (
          Array.isArray(firstError) &&
          firstError.length > 0
        ) {
          toast.error(
            firstError[0]
          );
          return;
        }

        if (
          typeof firstError ===
          "string"
        ) {
          toast.error(
            firstError
          );
          return;
        }
      }

      toast.error(
        "Failed to submit complaint. Please try again."
      );

    } finally {
      setLoading(false);
    }
  };

  // --------------------------------
  // Confidence formatting
  // --------------------------------

  const confidenceValue =
    Number(confidence) <= 1
      ? Number(confidence) * 100
      : Number(confidence);

  const formattedConfidence =
    Math.round(
      confidenceValue
    );

  return (
    <MainLayout>

      <PageHeader
        title="Submit Complaint"
        backTo="/analysis"
      />

      <Card
        maxWidth="max-w-3xl"
        className="mx-auto"
      >

        {/* -------------------------------- */}
        {/* Header */}
        {/* -------------------------------- */}

        <div className="text-center">

          <div className="w-20 h-20 mx-auto rounded-full bg-blue-100 flex items-center justify-center mb-5">

            <FaRobot className="text-blue-600 text-4xl" />

          </div>

          <h2 className="text-3xl font-bold text-gray-900">
            Submit Civic Complaint
          </h2>

          <p className="text-gray-500 mt-2">
            Review the detected issue and submit your complaint.
          </p>

        </div>

        {/* -------------------------------- */}
        {/* Image */}
        {/* -------------------------------- */}

        {imagePreview && (

          <div className="mt-8">

            <img
              src={imagePreview}
              alt="Civic issue"
              className="w-full h-72 object-cover rounded-3xl"
            />

          </div>

        )}

        {/* -------------------------------- */}
        {/* AI Detection Summary */}
        {/* -------------------------------- */}

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-8">

          <div className="bg-blue-50 border border-blue-100 rounded-2xl p-5">

            <p className="text-sm text-gray-500">
              Issue
            </p>

            <p className="text-lg font-bold text-blue-700 mt-1 capitalize">
              {String(issueType).replace(
                /_/g,
                " "
              )}
            </p>

          </div>

          <div className="bg-orange-50 border border-orange-100 rounded-2xl p-5">

            <p className="text-sm text-gray-500">
              Severity
            </p>

            <p className="text-lg font-bold text-orange-600 mt-1 capitalize">
              {severity}
            </p>

          </div>

          <div className="bg-green-50 border border-green-100 rounded-2xl p-5">

            <p className="text-sm text-gray-500">
              Confidence
            </p>

            <p className="text-lg font-bold text-green-600 mt-1">
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
                    Automatically captured from your selected GPS location.
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
                Location captured successfully.
              </p>

              <p className="text-sm text-yellow-600 mt-1">
                The readable address will be generated automatically when the report is submitted.
              </p>

            </div>

          )}

        </div>

        {/* -------------------------------- */}
        {/* GPS Status */}
        {/* -------------------------------- */}

        <div className="mt-4 bg-gray-50 border border-gray-200 rounded-2xl p-4">

          <div className="flex items-center gap-3">

            <FaCheckCircle className="text-green-500 flex-shrink-0" />

            <p className="text-sm text-gray-600">
              GPS coordinates are attached to this complaint automatically.
            </p>

          </div>

        </div>

        {/* -------------------------------- */}
        {/* Description */}
        {/* -------------------------------- */}

        <form
          onSubmit={handleSubmit}
          className="mt-8"
        >

          <label
            htmlFor="description"
            className="block text-sm font-semibold text-gray-700 mb-2"
          >
            Additional Description

            <span className="text-gray-400 font-normal">
              {" "}
              (Optional)
            </span>

          </label>

          <textarea
            id="description"
            value={description}
            onChange={(e) =>
              setDescription(
                e.target.value
              )
            }
            placeholder="Add any additional details about this civic issue..."
            rows={5}
            className="
              w-full
              border
              border-gray-200
              rounded-2xl
              px-4
              py-4
              text-gray-800
              outline-none
              focus:ring-2
              focus:ring-blue-500
              focus:border-blue-500
              resize-none
            "
          />

          {/* -------------------------------- */}
          {/* Submit */}
          {/* -------------------------------- */}

          <Button
            type="submit"
            className="w-full mt-6"
            disabled={loading}
          >

            {loading ? (

              <>
                <span className="inline-block animate-spin mr-2">
                  ⏳
                </span>

                Submitting Complaint...
              </>

            ) : (

              <>
                <FaPaperPlane className="inline mr-2" />

                Submit Complaint
              </>

            )}

          </Button>

        </form>

        {/* -------------------------------- */}
        {/* Back */}
        {/* -------------------------------- */}

        <button
          type="button"
          onClick={() =>
            navigate("/analysis")
          }
          disabled={loading}
          className="
            w-full
            mt-3
            py-3
            rounded-2xl
            text-gray-500
            font-medium
            hover:bg-gray-50
            transition
            disabled:opacity-50
          "
        >

          <FaArrowLeft className="inline mr-2" />

          Back to AI Result

        </button>

      </Card>

    </MainLayout>
  );
};

export default CreateComplaint;
