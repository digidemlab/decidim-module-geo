import L from "../leaflet";

const customArrowMarker = (location) => {

  const svg = `
    <svg width="22px" height="22px" xmlns="http://www.w3.org/2000/svg" viewBox="-3 -3 28 28">
      <g id="SVGRepo_bgCarrier" stroke-width="0">
        <rect x="0" y="0" width="24" height="24" rx="20" fill="#404040" strokewidth="0" opacity="0.72"></rect>
      </g>
      <g id="SVGRepo_iconCarrier"> 
        <path d="M16.0037 9.41421L7.39712 18.0208L5.98291 16.6066L14.5895 8H7.00373V6H18.0037V17H16.0037V9.41421Z" fill="#ffffff"/></path>
      </g>
    </svg>`; 
     
  const arrowNEIcon = L.divIcon({
    className: "arrow-marker",
    html: svg,
    iconSize: [10, 10],
    iconAnchor: [16, 16],
    zIndex: 0
  });
  let arrowMarker = L.marker(location, { icon: arrowNEIcon, opacity: 8 });
  return arrowMarker;
};

export default customArrowMarker;
