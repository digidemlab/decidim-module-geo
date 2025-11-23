import { customMarker, customArrowMarker } from ".";
import L from "../leaflet";
const nodeMarker = (node) => {
  if (!node.lonlat?.latitude || !node.lonlat?.longitude) return null;
  const location = L.latLng(node.lonlat.latitude, node.lonlat.longitude);

  console.log("node: ", node)

  if (node.participatorySpaceId == 3) return customArrowMarker(location); 

  return customMarker(location);
};

export default nodeMarker;
