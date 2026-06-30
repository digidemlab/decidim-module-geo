import { createStore } from "zustand/vanilla";
import { subscribeWithSelector } from "zustand/middleware";
import filterStore from "./filterStore";
import dropdownFilterStore from "./dropdownFilterStore";
import memoryStore from "./memoryStore";
import configStore from "./configStore";
const store = createStore(
  subscribeWithSelector((set, get) => ({
    /**
     * Filters given by the backend
     */
    defaultFilters: [],
    /**
     * data point that is currently clicked
     */
    selectedPoint: undefined,
    selectedTaxonomy: null,
    previousState: null,

    hasNoTaxonomySelected: () => {
      return !get().selectedTaxonomy || get().selectedTaxonomy === null;
    },

    /**
     * Action when we click on a point.
     */
    selectPoint: (point) => {
      const { saveState } = memoryStore.getState();
      saveState();
      set((state) => ({
        ...state,
        selectedPoint: point,
        previousState: state
      }));
    },
    /**
     * Action when a taxonomy is selected.
     * - select the taxonomy if any
     * -
     */
    selectTaxonomy: (taxonomy) => {
      const { saveState } = memoryStore.getState();
      saveState();

      dropdownFilterStore.setState(({ nextFilters, selectedFilters }) => ({
        nextFilters: { ...nextFilters, GeoTaxonomyFilter: `${taxonomy?.id || "all"}` },
        selectedFilters: { ...selectedFilters, GeoTaxonomyFilter: `${taxonomy?.id || "all"}` }
      }));

      set((state) => ({
        selectedTaxonomy: taxonomy || null,
        ...(`${taxonomy?.id}` !== `${state.selectedTaxonomy?.id}`
          ? { previousState: state }
          : null),
        selectedPoint:
          state.selectedPoint && state.selectedPoint.geoTaxonomyId === taxonomy?.id
            ? state.selectedPoint
            : null
      }));
      if (taxonomy) {
        taxonomy.repaint(); 
        if (taxonomy.menuItemRepaint) taxonomy.menuItemRepaint();
      }
    },
    /**
     * Go back to previous state
     */
    goBack: () => {
      set((state) => ({
        ...state.previousState
      }));
      const { popState } = memoryStore.getState();
      setTimeout(popState, 32);
    }
  }))
);

store.subscribe(
  (state) => [state.selectedTaxonomy],
  ([selectedTaxonomy], [previousTaxonomy]) => {
    dropdownFilterStore.getState().close();

    const { activeFilters, setFilters, taxonomyFilter, defaultFilters } = filterStore.getState();
    const filtersWithoutTaxonomies = activeFilters.filter(({ taxonomyFilter }) => !taxonomyFilter);
    const currentTaxonomyFilterId = taxonomyFilter(activeFilters);
    
    if (`${currentTaxonomyFilterId}` !== `${selectedTaxonomy?.id}`) {
      if (selectedTaxonomy?.id) {
        const matchFilter = activeFilters.find(
          ({ taxonomyFilter }) => taxonomyFilter?.taxonomyId === selectedTaxonomy.id
        );
        if (!matchFilter) {
          setFilters(filtersWithoutTaxonomies.concat({ taxonomyFilter: { taxonomyId: selectedTaxonomy.id } }));
        }
      } else {
        const defaultTaxonomyFilter = defaultFilters.find(({ taxonomyFiler }) => taxonomyFilter);
        if (defaultTaxonomyFilter) setFilters(filtersWithoutTaxonomies.concat(defaultTaxonomyFilter));
        else setFilters(filtersWithoutTaxonomies);
      }
    }

    if (previousTaxonomy && previousTaxonomy !== selectedTaxonomy) {
      previousTaxonomy.repaint();
      if (previousTaxonomy.menuItemRepaint) previousTaxonomy.menuItemRepaint();
    }

    if (selectedTaxonomy) {
      selectedTaxonomy.repaint();
      if (selectedTaxonomy.menuItemRepaint) selectedTaxonomy.menuItemRepaint();

      const { map } = configStore.getState();
      if (map && selectedTaxonomy.centroid) {
        const lat = selectedTaxonomy.centroid[1];
        const lng = selectedTaxonomy.centroid[0];
        map.panTo([lat, lng]);
      }
    }
  }
);

store.subscribe(
  (state) => [state.selectedPoint],
  async ([selectedPoint], [previousPoint]) => {
    if (!selectedPoint) {
      return;
    }
    dropdownFilterStore.getState().close();
    configStore.getState().openAside();
    selectedPoint.repaint();
    await selectedPoint.panToMarker();

    if (previousPoint) previousPoint.repaint();
  }
);
export default store;
