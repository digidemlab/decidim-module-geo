import L from "leaflet";

if (typeof window !== "undefined") {
  window.L = L;
}
if (typeof global !== "undefined") {
  global.L = L;
}

import "leaflet.fullscreen";
import "leaflet.markercluster/dist/leaflet.markercluster.js";

if (typeof window !== "undefined" && window.L) {
  Object.freeze(window.L);
}

export default L