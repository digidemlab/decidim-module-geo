import "src/decidim/map/controller/markers";
import configStore from "./stores/configStore";
import pointStore from "./stores/pointStore";
import filterStore from "./stores/filterStore";
import pointCounterStore from "./stores/pointCounterStore";
import geoStore from "./stores/geoStore";
import memoryStore from "./stores/memoryStore";
import dropdownFilterStore from "./stores/dropdownFilterStore";
import { initMap, DrawerHeader, Drawer, aside } from "./ui";
import bootstrap from "./bootstrap";
import registerMobile from "./ui/mobile/registerMobile";
import FilterControl from "./ui/FilterControl";
import PageNameControl from "./ui/PageNameControl";
import L from "./leaflet";
import _ from "lodash";

window.debug = window.debug || {};
window.debug.stores = () => ({
  config: configStore.getState(),
  filter: filterStore.getState(),
  geo: geoStore.getState(),
  point: pointStore.getState(),
  dropdownFilter: dropdownFilterStore.getState(),
  memoryStore: memoryStore.getState(),
  pointCounterStore: pointCounterStore.getState()
});

async function prepareLeaflet(isSmallScreen) {
  bootstrap();
  // Parse and save server-side information.
  const { map, tile } = await initMap();
  configStore.setState(() => ({ map, isSmallScreen }));
}
async function fetchData() {
  const { addProcess, removeProcess, fetchAll, pointsForFilters } = pointStore.getState();
  const { defaultFilters, activeFilters } = filterStore.getState();
  addProcess();
  // Fetch all the data
  await Promise.all([fetchAll(defaultFilters), pointsForFilters(activeFilters)]);

  removeProcess();
}

async function displayMap() {
  try {
    const { addProcess, removeProcess } = pointStore.getState();
    const { moveHandler, setSavedPosition } = memoryStore.getState();
    const { map, pointsLayer, taxonomyLayer } = configStore.getState();
    addProcess();

    // Be sure to fit all the points whenever you change
    // any filter.
    map.addLayer(taxonomyLayer);
    map.addLayer(pointsLayer);

    map.whenReady(async () => {
      pointCounterStore
        .getState()
        .updateCurrentCountForFilters(filterStore.getState().activeFilters);
      // Add the aside to the map
      aside([DrawerHeader, Drawer]);

      map.addControl(new FilterControl());
      //map.addControl(new PageNameControl());
      map.setMinZoom((configStore.getState().map_config.zoom || 15) - 2);
      // Save the first loaded position.
      await new Promise((resolve) => setTimeout(resolve, 64));
      configStore.getState().setReady();
      removeProcess();
      setTimeout(setSavedPosition, 640);
    });

    pointStore.subscribe(
      (state) => [
        !!state.isLoading,
        state.isInitialized,
        state.getFilteredPoints,
        state.fetchesRunning,
        state._lastResponse
      ],
      ([isLoading, isInitialized, getFilteredPoints, fetchesRunning]) => {
        if (isLoading > 0 || !isInitialized) {
          return;
        }
        const { map, pointsLayer, isSmallScreen } = configStore.getState();
        const { selectedPoint, selectedTaxonomy } = geoStore.getState();
        const pointInMap = getFilteredPoints().filter(
          (node) => typeof node.isGeoLocated !== "undefined" && node.isGeoLocated()
        );
        pointsLayer.clearLayers();
        if (pointInMap.length > 0) {
          pointInMap.forEach(({ marker }) => {
            marker.addTo(pointsLayer);
          });
          const bounds = L.latLngBounds(
            pointInMap.map(({ marker }) => marker.getLatLng())
          );
          map.fitBounds(bounds, {
            animate: true,
            padding: isSmallScreen ? [16, 16, 32, 16] : [32, 32, 32, 310],
            maxZoom: map.getZoom()
          });
        } else {
          console.warn("DecidimGeo: No points in map?");
          return;
        }
        if (
          fetchesRunning === 0 &&
          selectedTaxonomy?.layer &&
          selectedTaxonomy &&
          !selectedPoint
        ) {
          map.setView(selectedTaxonomy.layer.getBounds().getCenter(), map.getZoom(), {
            animation: true
          });
        }
      }
    );

    // Set active class on dropdown element
    geoStore.subscribe(
      (state) => [state.selectedTaxonomy],
      ([geoTaxonomy]) => {
        // Remove all active classes.
        const activeList = document.getElementsByClassName(
          "decidimGeo__drawerHeader__listItem--active"
        );
        for (const domEl of activeList) {
          domEl.className = domEl.className
            .replace("decidimGeo__drawerHeader__listItem--active", "")
            .trim();
        }
        const [container] = document.querySelectorAll(".decidimGeo__drawerHeader__list");
        if (!container) return;
        if (geoTaxonomy?.id) {
          const [active] = document.querySelectorAll(
            `.decidimGeo__drawerHeader__listItem[data-taxonomy='${geoTaxonomy.id}']`
          );
          if (active) {
            active.className += " decidimGeo__drawerHeader__listItem--active";
            container.scrollBy(active.getBoundingClientRect().left, 0);
          }
        } else {
          const [active] = document.querySelectorAll(
            `.decidimGeo__drawerHeader__listItem[data-taxonomy='all']`
          );
          if (active) {
            active.className += " decidimGeo__drawerHeader__listItem--active";
            container.scrollBy(active.getBoundingClientRect().left, 0);
          }
        }
      }
    );
    const [active] = document.querySelectorAll(
      `.decidimGeo__drawerHeader__listItem[data-taxonomy='all']`
    );
    if (active) active.className += " decidimGeo__drawerHeader__listItem--active";

    map.on("moveend", moveHandler);

    window.addEventListener(
      "resize",
      _.throttle(
        function () {
          setTimeout(function () {
            map.invalidateSize();
          }, 300);
        },
        128,
        { leading: false, trailing: true }
      )
    );
  } catch (e) {
    console.error(e);
    const { map, mapID } = configStore.getState();

    // If there is anything that happens,
    // we don't want to see the map.
    if (map?.remove) {
      map.remove();
    }
    if (map?.off) {
      map.off();
    }
    document.getElementById(mapID)?.remove();
  }
}

async function main() {
  var smallScreen = window.matchMedia("(max-width: 49.9988em)");
  const isSmallScreen = !!smallScreen.matches;
  if (isSmallScreen) {
    registerMobile();
  }
  await prepareLeaflet(isSmallScreen);
  await fetchData();
  await displayMap();
}

window.addEventListener("load", function () {
  main()
    .then(() => {
      console.log(
        `DecidimGeo: ready. Using Leaflet ${L.version} (global: ${window.L.version})`
      );
      pointStore.setState(() => ({ isInitialized: true }));
    })
    .catch((error) => {
      console.error("Decidim Geo: Can't initialize.");
      console.error(error);
    });
});

export default L;
