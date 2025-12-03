import L from "../leaflet";
const customMarker = (location) => {
  const circleIcon = L.divIcon({
    className: "unicode-circle-marker",
    html: `
      <div class="arrow-inner" style="
        width: 16px;
        height: 16px;
        background: #404040;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        user-select: none;
        position: relative;
        z-index: 0;
      ">
        <div style="
          width: 6px;
          height: 6px;
          background: white;
          border-radius: 50%;
        "></div>
      </div>
    `,
    iconSize: [16, 16],
    iconAnchor: [8, 8]
  });

  const marker = L.marker(location, { icon: circleIcon, opacity: 1 });
  return marker;
};

export default customMarker;
