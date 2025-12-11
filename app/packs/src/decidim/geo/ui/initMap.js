import configStore from "../stores/configStore";
import { MaptilerLayer } from "@maptiler/leaflet-maptilersdk";
import L from "../leaflet";
import loadEsri from "./loadEsri";
const initMap = async () => {
  await import("leaflet.fullscreen");
  const {
    mapID,
    map_config: {
      lat,
      lng,
      zoom,
      tile_layer,
      maptiler_api_key,
      maptiler_style_id,
      esri_tile_enabled
    },
    i18n
  } = configStore.getState();
  if (!document.getElementById(mapID)) {
    console.warn("No map found with id", mapID);
    throw new Error(`no map found with ID ${mapID}`);
  }
  const map = L.map(mapID, {
    center: [lat, lng],
    zoom,
    scrollWheelZoom: false,
    fullscreenControl: false,
    attributionControl: false,
    renderer: L.svg()
  });

  map.zoomControl.setPosition("bottomright");
  if (esri_tile_enabled) {
    await loadEsri();
    const layer = L.esri.Vector.vectorTileLayer(tile_layer, {});
    layer.addTo(map);
  } else if (maptiler_api_key.length > 0) {
    new MaptilerLayer({
      style: maptiler_style_id,
      apiKey: maptiler_api_key
    }).addTo(map);
  } else {
    L.tileLayer(tile_layer, {
      maxZoom: 19,
      attribution:
        '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);
  }
  L.control
    .fullscreen({
      position: "topright",
      title: i18n["decidim.geo.mobile.open_fullscreen"],
      titleCancel: i18n["decidim.geo.mobile.close_fullscreen"],
      forceSeparateButton: true,
      forcePseudoFullscreen: true
    })
    .addTo(map);

  return { map };
};
export default initMap;
