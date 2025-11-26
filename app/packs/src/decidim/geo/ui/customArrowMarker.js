import L from "../leaflet";

const customArrowMarker = (location) => {
  console.log("location: ", location)

  const arrowNEIcon = L.divIcon({
    className: "unicode-arrow-marker",
    html: `<div style="
      width: 16px;
      height: 16px;
      background: #404040;
      border-radius: 70%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 18px;
      user-select: none;
    ">
      ↗
    </div>`,
    iconSize: [5, 5],
    iconAnchor: [16, 16]
  });

  let arrowMarker = L.marker(location, { icon: arrowNEIcon, opacity: 8 });

  console.log("arrowMarker: ", arrowMarker)

  return arrowMarker;
};

export default customArrowMarker;
