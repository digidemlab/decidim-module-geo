import "../leaflet";
const loadEsri = async () => {
  const esriModule = await import("esri-leaflet/dist/esri-leaflet.js");
  const esriVectorModule = await import(
    "esri-leaflet-vector/dist/esri-leaflet-vector.js"
  );

  if (!window.L.esri) {
    window.L.esri = esriModule?.esri || esriModule?.default || esriModule;
  }

  if (!window.L.esri.Vector) {
    window.L.esri.Vector = {};
  }

  const vectorTileLayer =
    esriVectorModule?.vectorTileLayer ||
    esriVectorModule?.default?.vectorTileLayer ||
    esriVectorModule?.Vector?.vectorTileLayer;

  if (!vectorTileLayer) {
    throw new Error("esri-leaflet-vector failed to expose vectorTileLayer");
  }

  window.L.esri.Vector.vectorTileLayer = vectorTileLayer;

  return vectorTileLayer;
};

export default loadEsri;
