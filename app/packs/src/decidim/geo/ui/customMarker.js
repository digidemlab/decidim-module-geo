import L from "../leaflet";
const customMarker = (location) => {

  const svg = `
      <svg width="30px" height="30px" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="12" cy="12" r="4" stroke="#404040" stroke-width="6" />
        <circle cx="12" cy="12" r="3" fill="white" />
      </svg>
      `;
      
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
