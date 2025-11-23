import L from "../leaflet";
const customMarker = (location) => {
  const circleMarker = new L.circleMarker(location, {
    radius: 6,
    fillColor: "#ffffff",
    fillOpacity: 1,
    color: "#404040",
    opacity: 1,
    weight: 5,
    className: "decidimGeo__marker",
    riseOnHover: true,
    interactive: true
  });
  
  return circleMarker;
};

export default customMarker;
