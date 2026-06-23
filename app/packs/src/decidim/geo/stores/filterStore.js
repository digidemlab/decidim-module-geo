import { createStore } from "zustand/vanilla";
import _ from "lodash";
import { subscribeWithSelector } from "zustand/middleware";
import pointStore from "./pointStore";
import geoStore from "./geoStore";
import dropdownFilterStore from "../stores/dropdownFilterStore";
import pointCounterStore from "../stores/pointCounterStore";

const sortingIteratee = (filter) => JSON.stringify(filter);
const store = createStore(
  subscribeWithSelector((set, get) => ({
    defaultFilters: [],
    activeFilters: [],
    setDefaultFilters: (filters = []) => {
      const sortedFilters = _.sortBy(filters, [sortingIteratee]);
      set(() => ({
        defaultFilters: sortedFilters
      }));
    },
    isFilteredByTaxonomy: (filters = undefined) => {
      const { taxonomyFilter } = store.getState();
      return !!taxonomyFilter(filters);
    },
    taxonomyFilter: (filters = undefined) => {
      if (!filters) {
        const { activeFilters } = store.getState();
        filters = activeFilters;
      }
      return filters.find(({ taxonomyFilter }) => taxonomyFilter)?.taxonomyFilter?.taxonomyId;
    },
    isFilteredByTime: (filters = undefined) => {
      if (!filters) {
        const { activeFilters } = store.getState();
        filters = activeFilters;
      }
      return !!filters.find(({ timeFilter }) => timeFilter);
    },
    hasUserFilters: () => {
      const { defaultFilters, activeFilters } = store.getState();
      return _.isEqual(defaultFilters, activeFilters);
    },
    setFilters: (filters = []) => {
      const activeFilters = _.sortBy(filters, [sortingIteratee]);
      set((state) => {
        if (_.isEqual(state.activeFilters, activeFilters)) return {};
        return { activeFilters };
      });
    },
    resetFilters: () => {
      set((state) => ({
        activeFilters: state.defaultFilters
      }));
    },
    /**
     * Check if the map to displays is only for processes
     * @returns bool if serverside required  a participatory process type map only
     */
    isProcessOnly() {
      const { defaultFilters } = get();
      const resourceFilter = defaultFilters.find(
        ({ resourceTypeFilter = undefined }) => resourceTypeFilter
      );
      if (!resourceFilter) return false;
      const { resourceType } = resourceFilter.resourceTypeFilter;
      return resourceType === "participatory_processes";
    },
    /**
     *
     * @returns bool if serverside require a assembly type map only
     */
    isAssemblyOnly() {
      const { defaultFilters } = get();
      const resourceFilter = defaultFilters.find(
        ({ resourceTypeFilter = undefined }) => resourceTypeFilter
      );
      if (!resourceFilter) return false;
      const { resourceType } = resourceFilter.resourceTypeFilter;
      return resourceType === "assemblies";
    },
    isSource() {
      const { defaultFilters } = get();
      const sourceFilterMatch = defaultFilters.find(
        ({ sourceFilter = undefined }) => sourceFilter
      );
      if (!sourceFilterMatch) return false;
      const source = sourceFilterMatch.sourceFilter.source;
      return !!source;
    },
    toFilterOptions: (name, filters) => {
      const { defaultFilters } = dropdownFilterStore.getState();
      switch (name) {
        case "GeoShowFilter":
          const showFilterMatch = filters.find(
            ({ geoencodedFilter = undefined }) => geoencodedFilter
          );
          if (!showFilterMatch) return defaultFilters.GeoShowFilter;
          const geoencodedFilter = showFilterMatch.geoencodedFilter.geoencoded;
          if (geoencodedFilter === true) return "geoencoded";
          if (geoencodedFilter === false) return "virtual";

          return defaultFilters.GeoShowFilter;

        case "GeoTaxonomyFilter":
          const filterGeoTaxonomy = filters.find(
            ({ taxonomyFilter = undefined }) => taxonomyFilter
          );
          if (!filterGeoTaxonomy) {
            return defaultFilters.GeoTaxonomyFilter;
          }

          return `${filterGeoTaxonomy.taxonomyFilter.taxonomyId}`;

        case "GeoTimeFilter":
          const timeFilterMatch = filters.find(
            ({ timeFilter = undefined }) => timeFilter
          );

          if (!timeFilterMatch) return defaultFilters.GeoTimeFilter;
          const timeFilter = timeFilterMatch.timeFilter.time;
          if (timeFilter) return timeFilter;

          return defaultFilters.GeoTimeFilter;

        case "GeoType":
          const typeFilterMatch = filters.find(
            ({ resourceTypeFilter = undefined }) => resourceTypeFilter
          );
          if (!typeFilterMatch) return defaultFilters.GeoType;
          const id = document.querySelector(".decidimGeo__container").id;
          if (
            [
              "GeoAccountability",
              "GeoProposals",
              "GeoProposalsItem",
              "GeoMeetings",
              "GeoMeetingsItem",
              "GeoDebatesItem"
            ].includes(id)
          ) {
            const hasAllComponents = [
              "accountability",
              "debates",
              "meetings",
              "proposals"
            ].every((t) => filters.some((f) => f.resourceTypeFilter?.resourceType === t));
            if (hasAllComponents) {
              return "all";
            }
          }
          const resourceType = typeFilterMatch.resourceTypeFilter.resourceType;
          if (resourceType) {
            return `${resourceType}`;
          }

          return defaultFilters.GeoType;

        case "GeoSource":
          const sourceFilterMatch = filters.find(
            ({ sourceFilter = undefined }) => sourceFilter
          );
          if (!sourceFilterMatch) return defaultFilters.GeoSource;
          const sourceType = sourceFilterMatch.sourceFilter.source;
          if (sourceType) return `${sourceType}`;
      }
    }
  }))
);

const onFilteredByTaxonomy = (filters) => {
  const { taxonomyFilter } = store.getState();
  const { taxonomyForId } = pointStore.getState();
  let taxonomyId;
  const { selectedTaxonomy: previousTaxonomy } = geoStore.getState();
  const { selectTaxonomy } = geoStore.getState();
  if ((taxonomyId = taxonomyFilter(filters))) {
    if (previousTaxonomy && `${taxonomyId}` === `${previousTaxonomy?.id}`) return;
    
    const selectedTaxonomy = taxonomyForId(taxonomyId);
    if (selectedTaxonomy) selectTaxonomy(selectedTaxonomy);
    else selectTaxonomy(null);
  } else {
    const toRepaintTaxonomy = taxonomyForId(previousTaxonomy?.id);
    selectTaxonomy(null);
    if (toRepaintTaxonomy) {
      toRepaintTaxonomy.repaint();
    }
  }
};

// If you update the active filters, we need to fetch
// the point matching this filter.
store.subscribe(
  (state) => [state.activeFilters],
  async ([activeFilters], [previousActiveFilter]) => {
    if (activeFilters && _.isEqual(activeFilters, previousActiveFilter)) return;

    // Select/Unselect taxonomys if a taxonomyFilter is present
    if (activeFilters) {
      await pointStore.getState().pointsForFilters(activeFilters);
    }
    onFilteredByTaxonomy(activeFilters);

    // Update the filter modal state
    const { toFilterOptions } = store.getState();
    const { setFilter } = dropdownFilterStore.getState();
    setFilter("GeoTaxonomyFilter", toFilterOptions("GeoTaxonomyFilter", activeFilters));
    setFilter("GeoShowFilter", toFilterOptions("GeoShowFilter", activeFilters));
    setFilter("GeoTimeFilter", toFilterOptions("GeoTimeFilter", activeFilters));
    setFilter("GeoType", toFilterOptions("GeoType", activeFilters));
    setFilter("GeoSource", toFilterOptions("GeoSource", activeFilters));

    // Update active counters.
    const { updateCurrentCountForFilters } = pointCounterStore.getState();
    const _count = await updateCurrentCountForFilters(activeFilters);
  }
);

export default store;
