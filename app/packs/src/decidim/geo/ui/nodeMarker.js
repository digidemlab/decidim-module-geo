import { customMarker, customArrowMarker } from ".";
import L from "../leaflet";
const nodeMarker = (node) => {
  if (!node.lonlat?.latitude || !node.lonlat?.longitude) return null;
  const location = L.latLng(node.lonlat.latitude, node.lonlat.longitude);

  if (node?.extendedData?.componentUrl) {
    if (node?.extendedData?.spacePageHost === window.location.hostname) {
      return customMarker(location);
    } else {
      return customArrowMarker(location); 
    }
  } else {
    return customMarker(location);
  }
};

export default nodeMarker;
