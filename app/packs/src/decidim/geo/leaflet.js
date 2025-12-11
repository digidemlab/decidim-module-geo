import L from "leaflet";
import "leaflet.markercluster/dist/leaflet.markercluster.js";

// Ensure L is on window before esri-leaflet attaches to it
window.L = L;

export default window.L;
