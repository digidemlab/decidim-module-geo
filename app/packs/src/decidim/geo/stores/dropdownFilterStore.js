import { createStore } from "zustand/vanilla";
import { subscribeWithSelector } from "zustand/middleware";
import filterStore from "./filterStore";
import pointCounterStore from "./pointCounterStore";
const store = createStore(
  subscribeWithSelector((set, get) => ({
    isOpen: false,
    defaultFilters: {
      GeoScopeFilter: "all",
      GeoShowFilter: "all",
      GeoTimeFilter: "active",
      GeoType: "all"
    },
    selectedFilters: {
      GeoScopeFilter: "all",
      GeoShowFilter: "all",
      GeoTimeFilter: "active",
      GeoType: "all"
    },
    nextFilters: undefined,

    filterCount() {
      const { selectedFilters, defaultFilters } = store.getState();
      return Object.entries(selectedFilters).filter(([key, value]) => {
        return defaultFilters[key] !== value;
      }).length;
    },
    fromOptionsToFilters(filters = undefined) {
      if (!filters) filters = get().selectedFilters;
      const { activeFilters } = filterStore.getState();

      let newFilters = [...activeFilters];
      const withoutGeoShowFilter = (filters) =>
        filters.filter((f) => {
          const [filterName] = Object.keys(f);
          return filterName !== "geoencodedFilter";
        });
      const withoutTimeFilter = (filters) =>
        filters.filter((f) => {
          const [filterName] = Object.keys(f);
          return filterName !== "timeFilter";
        });
      const withoutTypeFilter = (filters) =>
        filters.filter((f) => {
          const [filterName] = Object.keys(f);
          return filterName !== "resourceTypeFilter";
        });
      const withoutGeoScopeFilter = (filters) =>
        filters.filter((f) => {
          const [filterName] = Object.keys(f);
          return filterName !== "scopeFilter";
        });

      switch (filters.GeoShowFilter) {
        case "all":
          newFilters = withoutGeoShowFilter(newFilters);

          break;
        case "geoencoded":
          newFilters = [
            ...withoutGeoShowFilter(newFilters),
            {
              geoencodedFilter: { geoencoded: true }
            }
          ];
          break;
        case "virtual":
          newFilters = [
            ...withoutGeoShowFilter(newFilters),
            {
              geoencodedFilter: { geoencoded: false }
            }
          ];
          break;
      }
      const filteredScopeId = filters.GeoScopeFilter || "all";

      switch (filteredScopeId) {
        case "all":
          newFilters = withoutGeoScopeFilter(newFilters);
          break;
        default:
          newFilters = [
            ...withoutGeoShowFilter(newFilters),
            {
              scopeFilter: { scopeId: `${filteredScopeId}` }
            }
          ];
          break;
      }

      const timeFilter = filters.GeoTimeFilter;
      if (timeFilter)
        newFilters = [
          ...withoutTimeFilter(newFilters),
          {
            timeFilter: { time: timeFilter }
          }
        ];

      const resourceType = filters.GeoType;
      if (resourceType) {
        const id = document.querySelector('.decidimGeo__container').id;

        switch (id) {
          case "GeoAccountability":
          case "GeoProposals":
            if (resourceType === "all") {
              newFilters = [
                ...withoutTypeFilter(newFilters),
                { resourceTypeFilter: { resourceType: "proposals" } },
                { resourceTypeFilter: { resourceType: "debates" } },
                { resourceTypeFilter: { resourceType: "meetings" } },
                { resourceTypeFilter: { resourceType: "accountability" } }
              ];
            } else {
              newFilters = [
                ...withoutTypeFilter(newFilters),
                {
                  resourceTypeFilter: { resourceType: resourceType }
                }
              ];
            }
          break;
          default:
            newFilters = [
              ...withoutTypeFilter(newFilters),
              {
                resourceTypeFilter: { resourceType: resourceType }
              }
            ];
            break;
        }
      }
      return newFilters;
    },
    setNextFilter(name, value) {
      set((state) => ({
        nextFilters: {
          ...state.nextFilters,
          [`${name}`]: value || state.defaultFilters[`${name}`]
        }
      }));
    },
    applyNextFilters() {
      set(({ nextFilters }) => (nextFilters ? { selectedFilters: nextFilters } : {}));
    },
    resetFilters() {
      set(({ defaultFilters }) => ({
        selectedFilters: defaultFilters,
        nextFilters: defaultFilters
      }));
    },
    setDefaultFilters(newFilters) {
      set(() => ({ defaultFilters: newFilters, selectedFilters: newFilters }));
    },
    setFilter(name, value) {
      const prevState = get().selectedFilters;
      if (prevState[name] === value) return;
      set((state) => ({
        selectedFilters: {
          ...state.defaultFilters,
          ...state.selectedFilters,
          [`${name}`]: value || state.defaultFilters[`${name}`]
        }
      }));
    },
    toggleOpen() {
      set((state) => ({ isOpen: !state.isOpen }));
    },
    close() {
      set(() => ({ isOpen: false }));
    },
    open() {
      set(() => ({ isOpen: true }));
    }
  }))
);

export default store;

store.subscribe(
  (state) => [state.nextFilters],
  async ([nextFilters], { prevFilter }) => {
    const nextFilterKey = JSON.stringify(nextFilters);
    const prevFilterKey = JSON.stringify(prevFilter);
    if (_.isEqual(nextFilterKey, prevFilterKey)) return;

    const { updateNextCountForFilters } = pointCounterStore.getState();
    await updateNextCountForFilters(store.getState().fromOptionsToFilters(nextFilters));
  }
);
