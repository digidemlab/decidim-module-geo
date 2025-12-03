import L from "../leaflet";

const customArrowMarker = (location) => {

  const arrowNEIcon = L.divIcon({
    className: "unicode-arrow-marker",
    html: `<div class="arrow-inner" style="
      width: 16px;
      height: 16px;
      background: #404040;
      border-radius: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 16px;
      line-height: 1;
      user-select: none;
      position: relative;
      z-index: 0;
    ">
      ↗
    </div>`,
    iconSize: [5, 5],
    iconAnchor: [16, 16],
    zIndex: 0
  });
  let arrowMarker = L.marker(location, { icon: arrowNEIcon, opacity: 8 });
  return arrowMarker;
};

export default customArrowMarker;
