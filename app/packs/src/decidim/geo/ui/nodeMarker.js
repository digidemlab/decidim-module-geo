import { customMarker, customArrowMarker } from ".";
import L from "../leaflet";
const nodeMarker = (node) => {
  if (!node.lonlat?.latitude || !node.lonlat?.longitude) return null;
  const location = L.latLng(node.lonlat.latitude, node.lonlat.longitude);

  if (node?.extendedData?.componentUrl) return customArrowMarker(location); 

  return customMarker(location);
};

export default nodeMarker;
