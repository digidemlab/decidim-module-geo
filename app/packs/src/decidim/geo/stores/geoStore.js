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
    /**
     *
     */
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
        // unselect point when moving away from its taxonomy
        selectedPoint:
          state.selectedPoint && state.selectedPoint.geoTaxonomyId === taxonomy?.id
            ? state.selectedPoint
            : null
      }));
      if (taxonomy) taxonomy.repaint();
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
  ([selectedTaxonomy]) => {
    // Close the drowp down
    dropdownFilterStore.getState().close();

    // Update filter associated to the taxonomy
    const { activeFilters, setFilters, taxonomyFilter, defaultFilters } =
      filterStore.getState();
    const filtersWithoutTaxonomies = activeFilters.filter(({ taxonomyFilter }) => {
      return !taxonomyFilter;
    });
    const currentTaxonomyFilterId = taxonomyFilter(activeFilters);
    if (`${currentTaxonomyFilterId}` === `${selectedTaxonomy?.id}`) return;
    if (selectedTaxonomy?.id) {
      const matchFilter = activeFilters.find(
        ({ taxonomyFilter }) => taxonomyFilter?.taxonomyId === selectedTaxonomy.id
      );
      if (!matchFilter)
        setFilters(
          filtersWithoutTaxonomies.concat({ taxonomyFilter: { taxonomyId: selectedTaxonomy.id } })
        );
    } else {
      const defaultTaxonomyFilter = defaultFilters.find(({ taxonomyFiler }) => taxonomyFilter);
      if (defaultTaxonomyFilter) setFilters(filtersWithoutTaxonomies.concat(defaultTaxonomyFilter));
      else setFilters(filtersWithoutTaxonomies);
    }
  }
);

store.subscribe(
  (state) => [state.selectedTaxonomy],
  ([selectedTaxonomy], [previousTaxonomy]) => {
    // Close the filter dropdown
    if (previousTaxonomy) previousTaxonomy.repaint();
    if (selectedTaxonomy) {
      selectedTaxonomy.repaint();
    }
    dropdownFilterStore.getState().close();
  }
);

store.subscribe(
  (state) => [state.selectedPoint],
  async ([selectedPoint], [previousPoint]) => {
    if (!selectedPoint) {
      return;
    }
    // Close the filter dropdown
    dropdownFilterStore.getState().close();
    // Open drawer
    configStore.getState().openAside();
    // Center to the marker
    selectedPoint.repaint();
    await selectedPoint.panToMarker();

    if (previousPoint) previousPoint.repaint();
  }
);
export default store;
