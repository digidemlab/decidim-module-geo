import { taxonomyDropdownItem, taxonomyGeoLayer } from "../ui";
import geoStore from "../stores/geoStore";
import pointStore from "../stores/pointStore";
import configStore from "../stores/configStore";
import polylabel from "polylabel";
import _ from "lodash";

export default class GeoTaxonomy {
  constructor({ geoTaxonomy }) {
    //Model
    this.data = geoTaxonomy;
    this.markers_group = [];
    this.menuItem = null;
    this.menuItemRepaint = () => {};
  }

  get activeState() {
    return { 
      fillColor: "#2952A370", 
      color: "#2952A3", 
      lineJoin: "miter",
      dashArray: "5, 10",
      dashOffset: "5"
    };
  }

  isEmpty(points = undefined) {
    if (this.data.geom === null) return true;
    if (!points) points = pointStore.getState().points;
    const currentTaxonomyId = this.id;
    return !points.find(({ geoTaxonomyId }) => `${geoTaxonomyId}` === `${currentTaxonomyId}`);
  }

  isLoading() {
    return pointStore.getState().isLoading;
  }

  get staledState() {
    return { 
      fillColor: "#cccccc",
      color: "#999999",
      lineJoin: "miter",
      dashArray: "5, 10",
      dashOffset: "5"
    };
  }

  select() {
    const { selectedTaxonomy: previousTaxonomy } = geoStore.getState();
    if (previousTaxonomy === this) return;
    geoStore.getState().selectTaxonomy(this);
  }

  /**
   * If the current marker is selected (active)
   * @returns boolean
   */
  isActive() {
    const { selectedTaxonomy } = geoStore.getState();
    if (selectedTaxonomy) return selectedTaxonomy.id === this.id;
    return false;
  }

  repaint() {
    if (!this.layer) return;

    const { map } = configStore.getState();
    const styleToApply = this.isActive() ? this.activeState : this.staledState;
    this.layer.setStyle(styleToApply);
    if (typeof this.layer.redraw === 'function') {
      this.layer.redraw();
    } 
  }

  get name() {
    return this.data.name.translation;
  }
  get geom() {
    return this.data.geom;
  }

  get id() {
    return parseInt(`${this.data.id}`);
  }

  nodesForTaxonomy() {
    const { points } = pointStore.getState();
    const currentTaxonomyId = this.id;
    return points
      .filter(({ geoTaxonomyId }) => `${geoTaxonomyId}` === `${currentTaxonomyId}`)
      .filter(Boolean);
  }

  markersForTaxonomy() {
    if (this.markers_group.length > 0) return this.markers_group;
    return this.nodesForTaxonomy()
      .filter((node) => node.isGeoLocated())
      .map(({ marker }) => marker);
  }

  componentIds() {
    return _.uniq(
      this.nodesForTaxonomy()
        .map(({ data }) => (data.componentId ? `${data.componentId}` : false))
        .filter(Boolean)
    );
  }

  taxonomyClickHandler() {
    this.select("layer");
  }
  remove() {
    const { map } = configStore.getState();
    if (this.layer && map.hasLayer(this.layer)) {
      try {
        map.removeLayer(this.layer);
      } catch (e) {
        console.error(e);
      }
    }
  }
  init(taxonomyLayer) {
    this.markers_group = this.markersForTaxonomy();
    const [itm, repaintItm] = taxonomyDropdownItem({
      taxonomyId: this.id,
      label: this.name,
      onClick: () => {
        geoStore.getState().selectTaxonomy(this);
      }
    });
    this.menuItem = itm;
    this.menuItemRepaint = repaintItm;

    if (this.data.geom?.type) {
      if (this.data.geom.type === "MultiPolygon") {
        this.centroid = polylabel(this.data.geom.coordinates[0], 1.0);
      }
      this.layer = taxonomyGeoLayer({
        geoTaxonomy: this.data,
        centroid: this.centroid,
        onClick: this.taxonomyClickHandler.bind(this)
      });
      this.layer.bringToBack();

      let layers = taxonomyLayer.getLayers();
      if (layers.length > 0) {
        let taxonomyId = this.id.toString();
        let ids = [];
        taxonomyLayer.eachLayer((layer) => {
           if(layer.eachLayer) { 
             layer.eachLayer((innerLayer) => { ids.push(innerLayer.feature.geometry.properties.id); });
           }
        });
        
        if (!ids.includes(taxonomyId)) { 
          taxonomyLayer.addLayer(this.layer); 
        }
      } else {
        taxonomyLayer.addLayer(this.layer);
      }

      pointStore.subscribe(
        (state) => [state.isLoading, state.points], // Escute também mudanças nos pontos se necessário
        ([isLoading, points]) => {
          const { map, mapReady } = configStore.getState();
          
          // 1. Se ainda está carregando, não faz nada
          if (isLoading) return;
          
          if (!this.layer) return;

          if (this.isActive()) return; 

          if (this.isEmpty() && map.hasLayer(this.layer) && mapReady) {
            map.removeLayer(this.layer);
          }
        }
      );
    }    
    return this;
  }
}
