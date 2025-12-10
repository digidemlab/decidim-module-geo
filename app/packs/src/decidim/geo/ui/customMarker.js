import L from "../leaflet";
const customMarker = (location) => {

  const svg = `
    <svg width="20px" height="20px" viewBox="10 10 26 26" fill="none" xmlns="http://www.w3.org/2000/svg">
      <circle cx="24" cy="24" r="8" stroke="#404040" stroke-width="6" />
      <circle cx="24" cy="24" r="5" fill="white" />
    </svg>`;
      
  const circleIcon = L.divIcon({
    className: "circle-marker",
    html: svg,
    iconSize: [16, 16],
    iconAnchor: [8, 8]
  });

  const marker = L.marker(location, { icon: circleIcon, opacity: 1 });
  return marker;
};

export default customMarker;
