import { useEffect, useState } from "react";
import {
  MapContainer,
  TileLayer,
  Marker,
  useMap,
  useMapEvents,
} from "react-leaflet";
import L from "leaflet";
import "leaflet/dist/leaflet.css";

// Fix Leaflet marker icons when using Vite
delete L.Icon.Default.prototype._getIconUrl;

L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon-2x.png",
  iconUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-icon.png",
  shadowUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png",
});

function LocationMarker({ position, setPosition }) {
  useMapEvents({
    click(event) {
      setPosition([event.latlng.lat, event.latlng.lng]);
    },
  });

  if (!position) {
    return null;
  }

  return <Marker position={position} />;
}

function RecenterMap({ position }) {
  const map = useMap();

  useEffect(() => {
    if (position) {
      map.setView(position, 16);
    }
  }, [position, map]);

  return null;
}

const LocationPicker = ({ value, onChange }) => {
  const [position, setPosition] = useState(value || null);
  const [loading, setLoading] = useState(false);
  const [locationError, setLocationError] = useState("");

  useEffect(() => {
    if (value) {
      setPosition(value);
    }
  }, [value]);

  const updatePosition = (newPosition) => {
    setPosition(newPosition);

    if (onChange) {
      onChange(newPosition);
    }
  };

  const getCurrentLocation = () => {
    if (!navigator.geolocation) {
      setLocationError(
        "Geolocation is not supported by this browser."
      );
      return;
    }

    setLoading(true);
    setLocationError("");

    navigator.geolocation.getCurrentPosition(
      (location) => {
        const newPosition = [
          location.coords.latitude,
          location.coords.longitude,
        ];

        updatePosition(newPosition);
        setLoading(false);
      },
      (error) => {
        setLoading(false);

        switch (error.code) {
          case error.PERMISSION_DENIED:
            setLocationError(
              "Location permission was denied. Please allow location access."
            );
            break;

          case error.POSITION_UNAVAILABLE:
            setLocationError(
              "Your current location could not be determined."
            );
            break;

          case error.TIMEOUT:
            setLocationError(
              "Location request timed out. Please try again."
            );
            break;

          default:
            setLocationError(
              "Unable to get your current location."
            );
        }
      },
      {
        enableHighAccuracy: true,
        timeout: 15000,
        maximumAge: 0,
      }
    );
  };

  const defaultCenter = position || [24.8607, 67.0011];

  return (
    <div className="w-full">
      <div className="mb-4 flex items-center justify-between gap-3">
        <div>
          <h3 className="text-lg font-semibold text-gray-900">
            Issue Location
          </h3>

          <p className="text-sm text-gray-500">
            Select where the civic issue was found.
          </p>
        </div>

        <button
          type="button"
          onClick={getCurrentLocation}
          disabled={loading}
          className="rounded-xl bg-blue-600 px-4 py-2 text-sm font-semibold text-white transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {loading ? "Locating..." : "Use My Location"}
        </button>
      </div>

      {locationError && (
        <div className="mb-3 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-600">
          {locationError}
        </div>
      )}

      <div className="overflow-hidden rounded-2xl border border-gray-200 shadow-sm">
        <MapContainer
          center={defaultCenter}
          zoom={13}
          scrollWheelZoom={true}
          className="h-[350px] w-full"
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />

          <LocationMarker
            position={position}
            setPosition={updatePosition}
          />

          <RecenterMap position={position} />
        </MapContainer>
      </div>

      {position ? (
        <div className="mt-3 rounded-xl bg-blue-50 p-4">
          <p className="text-sm font-semibold text-blue-900">
            Selected Location
          </p>

          <div className="mt-1 grid grid-cols-2 gap-3 text-sm text-blue-700">
            <div>
              <span className="font-medium">Latitude:</span>{" "}
              {position[0].toFixed(6)}
            </div>

            <div>
              <span className="font-medium">Longitude:</span>{" "}
              {position[1].toFixed(6)}
            </div>
          </div>
        </div>
      ) : (
        <div className="mt-3 rounded-xl bg-gray-50 p-4 text-sm text-gray-500">
          Click anywhere on the map or use "Use My Location" to select
          the issue location.
        </div>
      )}
    </div>
  );
};

export default LocationPicker;