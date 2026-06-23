import L from "../leaflet";
const taxonomyGeoLayer = ({ geoTaxonomy, onClick }) => {
  geoTaxonomy.geom = {
    ...geoTaxonomy.geom,
    properties: {
      id: geoTaxonomy.id,
      name: geoTaxonomy.name.translation || geoTaxonomy.name.defaultTranslation
    }
  };
  const layer = L.geoJSON(geoTaxonomy.geom, {
    style: {
      fillColor: "#cccccc",
      color: "#999999",
      lineJoin: "miter",
      dashArray: "5, 10",
      dashOffset: "5"
    }
  });
  layer.on("click", onClick);

  return layer;
};

export default taxonomyGeoLayer;
