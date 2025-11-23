import L from "../leaflet";

const customArrowMarker = (location) => {
  const arrowMarker = new L.circleMarker(location, {
    radius: 6,
    fillColor: "#ec1010ff",
    fillOpacity: 1,
    color: "#404040",
    opacity: 1,
    weight: 5,
    className: "decidimGeo__marker",
    riseOnHover: true,
    interactive: true
  });
  
  return arrowMarker;
};

export default customArrowMarker;
