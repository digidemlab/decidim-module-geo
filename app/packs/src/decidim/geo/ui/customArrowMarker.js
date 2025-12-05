import L from "../leaflet";

const customArrowMarker = (location) => {

  const svg = `
    <svg width="24px" height="24px" xmlns="http://www.w3.org/2000/svg" viewBox="-6 -6 28 28">
      <g id="SVGRepo_bgCarrier" stroke-width="0">
        <rect x="-4" y="-4" width="24" height="24" rx="20" fill="#404040" strokewidth="0"></rect>
      </g>
      <g id="SVGRepo_iconCarrier"> 
        <path d="M14 2H5.50003L4.00003 3.5L6.83581 6.33579L0.585815 12.5858L3.41424 15.4142L9.66424 9.16421L12.5 12L14 10.5L14 2Z" fill="#ffffff"/></path>
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
