
import requests


NOMINATIM_URL = "https://nominatim.openstreetmap.org/reverse"


def get_location_name(latitude, longitude):
    """
    Convert latitude and longitude into a readable address.
    """

    try:
        response = requests.get(
            NOMINATIM_URL,
            params={
                "lat": latitude,
                "lon": longitude,
                "format": "jsonv2",
                "addressdetails": 1,
                "zoom": 18,
                "accept-language": "en",
            },
            headers={
                "User-Agent": "UrbanEye/1.0"
            },
            timeout=10,
        )

        response.raise_for_status()

        data = response.json()

        address = data.get("address", {})

        house_number = address.get("house_number")
        road = address.get("road")

        neighbourhood = (
            address.get("neighbourhood")
            or address.get("suburb")
            or address.get("quarter")
        )

        city = (
            address.get("city")
            or address.get("town")
            or address.get("village")
            or address.get("municipality")
        )

        state = address.get("state")
        country = address.get("country")

        parts = []

        if house_number and road:
            parts.append(
                f"{house_number}, {road}"
            )
        elif road:
            parts.append(road)

        if neighbourhood:
            parts.append(neighbourhood)

        if city:
            parts.append(city)

        if state:
            parts.append(state)

        if country:
            parts.append(country)

        return ", ".join(parts)

    except (
        requests.RequestException,
        ValueError,
        TypeError,
    ):
        return ""