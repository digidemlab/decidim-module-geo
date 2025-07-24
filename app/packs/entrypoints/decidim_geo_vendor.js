import L from "leaflet";
import "leaflet.fullscreen";
import MarkerClusterGroup from "leaflet.markercluster";
L.MarkerClusterGroup = MarkerClusterGroup;
window.L = L;
global.L = L;
