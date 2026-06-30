import { createStore } from "zustand/vanilla";
import configStore from "./configStore";

import { getGeoDataSource, getGeoTaxonomies } from "../api";
import GeoDatasourceNode from "../models/GeoDatasourceNode";
import GeoTaxonomy from "../models/GeoTaxonomy";
import { subscribeWithSelector } from "zustand/middleware";
import _ from "lodash";

const mapNodeToPoint = (node) => {
  const point = new GeoDatasourceNode({
    node
  });
  if (point.init()) {
    return point;
  }
  return undefined;
};

const filteredIdsStore = createStore((set, get) => ({
  activeFilterIds: []
}));
let fetchAllCalled = false;

const store = createStore(
  subscribeWithSelector((set, get) => ({
    /**
     * Data Points
     */
    points: [],
    taxonomies: [],
    fetchedGeoTaxonomies: [],
    selectedGeoTaxonomyIds: [],
    isInitialized: false,
    isLoading: 0,
    _lastFilter: "",
    _lastResponse: [],
    lastResponseCount: 0,
    fetchesRunning: 0,
    taxonomyForId: (taxonomyId) => {
      const taxonomy = get().taxonomies.find(({ data }) => `${data.id}` === `${taxonomyId}`);
      if (!taxonomy || taxonomy.isEmpty()) return null;
      return taxonomy;
    },
    clearCache: () => {
      set(() => ({ _lastFilter: "", _lastResponse: [], lastResponseCount: 0 }));
    },
    addProcess: () => {
      set(({ isLoading }) => ({ isLoading: isLoading + 1 }));
    },
    removeProcess: () => {
      set(({ isLoading }) => ({ isLoading: isLoading - 1 }));
    },
    loading() {
      const { isLoading, fetchesRunning } = store.getState();
      return isLoading > 0 || !fetchAllCalled || fetchesRunning;
    },
    getFilteredPoints: () => store.getState()._lastResponse,
    _updateCache: () => {
      const filteredPoints = filteredIdsStore.getState().activeFilterIds;
      const { taxonomyLayer } = configStore.getState();
      const { selectedGeoTaxonomyIds, fetchedGeoTaxonomies, points, taxonomies } = get();
      
      const targetIds = new Set(selectedGeoTaxonomyIds);
      
      const taxonomiesToKeep = [];
      const taxonomiesToRemove = [];

      taxonomies.forEach(t => {
        if (targetIds.has(t.id)) {
          taxonomiesToKeep.push(t);
        } else {
          taxonomiesToRemove.push(t);
        }
      });

      taxonomiesToRemove.forEach(t => {
        t.remove();
      });

      const existingIds = new Set(taxonomiesToKeep.map(t => t.id));
      const newTaxonomies = [];

      selectedGeoTaxonomyIds.forEach(id => {
        if (!existingIds.has(id)) {
          const match = fetchedGeoTaxonomies.find(({ id: fid }) => `${fid}` === `${id}`);
          if (match) {
            const geoTaxonomy = new GeoTaxonomy({ geoTaxonomy: match });
            geoTaxonomy.init(taxonomyLayer);
            newTaxonomies.push(geoTaxonomy);
          }
        }
      });

      const geoTaxonomies = [...taxonomiesToKeep, ...newTaxonomies];

      const responsePoints = filteredPoints
        .map(({ id: needleId }) => points.find(({ id }) => `${needleId}` === `${id}`))
        .filter(Boolean);

      set(() => ({
        _lastResponse: responsePoints,
        lastResponseCount: responsePoints.length,
        taxonomies: geoTaxonomies
      }));

      taxonomyLayer.eachLayer(function (layer) {
        layer.bringToBack();
      });
    },
    fetchAll: async (filters = []) => {
      const { points: fetchedPoints } = store.getState();
      if (fetchedPoints.length > 0) return;

      const { locale, isIndex } = configStore.getState();

      const promises = [];
      const filterWithoutTime = filters.filter(
        (f) => typeof f.timeFilter === "undefined"
      );
      set(({ fetchesRunning }) => ({ fetchesRunning: fetchesRunning + 1 }));
      await getGeoDataSource(
        { filters: filterWithoutTime, locale, isIndex },
        true,
        (data, hasMore, meta) => {
          const points = data.map(mapNodeToPoint).filter(Boolean);
          store.setState(({ points: prevPoints }) => ({
            points: [...prevPoints, ...points]
          }));
          fetchAllCalled = !hasMore;
          get()._updateCache();
          set(({ fetchesRunning }) => ({
            fetchesRunning: fetchesRunning - (hasMore ? 0 : 1),
            selectedGeoTaxonomyIds: meta.geo_taxonomy_ids ? [...new Set(meta.geo_taxonomy_ids)] : []
          }));
        }
      );

      promises.push(
        getGeoTaxonomies({
          variables: { locale: locale }
        }).then((taxonomies) => {
          return { geoTaxonomies: taxonomies };
        })
      );
      await Promise.allSettled(promises).then((results) => {
        const rejected = results.filter((result) => result.status === "rejected");
        if (rejected.length > 0)
          console.error("ERR: fail to fetch." + rejected.map((r) => r.reason).join("."));
        const [fetchedGeoTaxonomies] = results
          .filter(({ value }) => typeof value.geoTaxonomies !== "undefined")
          .map(({ value: { geoTaxonomies } }) => geoTaxonomies);
        set(() => ({ fetchedGeoTaxonomies }));
        get()._updateCache();
      });
    },

    pointsForFilters: async (filters = [], forceRefresh = false) => {
      const { locale, isIndex } = configStore.getState();
      const { _lastFilter: lastFilter, _lastResponse: lastResponse } = store.getState();
      const cacheKey = JSON.stringify(filters);
      // cache
      if (cacheKey === lastFilter && !forceRefresh) {
        return lastResponse;
      }
      set(({ fetchesRunning }) => ({
        fetchesRunning: fetchesRunning + 1,
        _lastFilter: cacheKey
      }));
      filteredIdsStore.setState(() => ({ activeFilterIds: [] }));

      await getGeoDataSource(
        { filters, locale: locale, isIndex },
        false,
        (data, hasMore) => {
          filteredIdsStore.setState(({ activeFilterIds }) => ({
            activeFilterIds: activeFilterIds.concat(data || [])
          }));
          set(({ fetchesRunning }) => ({
            fetchesRunning: fetchesRunning - (hasMore ? 0 : 1)
          }));
          get()._updateCache();
        }
      );
    }
  }))
);

export default store;
