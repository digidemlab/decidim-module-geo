import { item as drawerListItem, nodeMarker } from "../ui";
import geoStore from "../stores/geoStore";
import configStore from "../stores/configStore";
let maxZIndex = 0;

export default class GeoDatasourceNode {
  constructor({ node, map }) {
    //Model
    this.data = node;
    this.map = map;
    this.marker = undefined;
  }
  get isFetched() {
    return true;
  }
  bringToFront() {
    if (!this.marker) return;

    this.marker.setZIndexOffset(maxZIndex += 100);
  }
  isGeoLocated() {
    if (!this.marker) return false;

    let latlng = []
  
    if (this.marker.getLatLng) {
      latlng = this.marker.getLatLng();
    } else if (this.marker.getLatLngs) {
      const points = this.marker.getLatLngs();
      latlng = Array.isArray(points) && points.length > 0 && points[0].length > 0 ? points[0][0] : null;
    }
    return latlng?.lat && latlng?.lng;
  }

  repaint() {
    const { selectedPoint } = geoStore.getState();
    const { selected_component, defaultSelectedPoint: pinPoint } = configStore.getState();

    if (this.isGeoLocated()) {
      if (pinPoint) {
        if (selectedPoint && selectedPoint === this) {
          if (this.marker.setStyle) { 
            this.marker.setStyle(this.selectedState); 
          } else {
            const markerStyle = this.marker.getElement()?.querySelector(".arrow-inner")?.style
            if (markerStyle) {
              markerStyle.background = "var(--primary)";
            }
          }
          this.bringToFront();

        } else if (
          !selectedPoint &&
          `${this.data.componentId}` == `${selected_component}` &&
          `${pinPoint}` === `${this.data.resourceId}`
        ) {
          if (this.marker.setStyle) { 
            this.marker.setStyle(this.selectedState); 
          } else {
            const markerStyle = this.marker.getElement()?.querySelector(".arrow-inner")?.style
            if (markerStyle) {
              markerStyle.background = "var(--primary)";
            }
          }
        } else {
          if (this.marker.setStyle) { 
            this.marker.setStyle(this.staledState); 
          } else {
            const markerStyle = this.marker.getElement()?.querySelector(".arrow-inner")?.style
            if (markerStyle) {
              markerStyle.background = "#404040";
            }
          }
        }
      } else {
        if (selectedPoint === this) {
          if (this.marker.setStyle) { 
            this.marker.setStyle(this.selectedState); 
          } else {
            const markerStyle = this.marker.getElement()?.querySelector(".arrow-inner")?.style
            if (markerStyle) {
              markerStyle.background = "var(--primary)";
            }
          }
          this.bringToFront();
        } else if (!selectedPoint && `${this.data.componentId}` === `${selected_component}`) {
          if (this.marker.setStyle) { 
            this.marker.setStyle(this.selectedState); 
          } else {
            const markerStyle = this.marker.getElement()?.querySelector(".arrow-inner")?.style
            if (markerStyle) {
              markerStyle.background = "var(--primary)";
            }
          }
        } else {
          if (this.marker.setStyle) { 
            this.marker.setStyle(this.staledState); 
          } else {
            const markerStyle = this.marker.getElement()?.querySelector(".arrow-inner")?.style
            if (markerStyle) {
              markerStyle.background = "#404040";
            }
          }
        }
      }
    }
  }

  colorLayers() {
    if (!this.isGeoLocated()) return;
    const { map } = configStore.getState();
    map.eachLayer((layer) => {
      if (layer.feature) {
        if (layer.feature.geometry.properties.id === this.geoScopeId) {
          layer.setStyle(this.selectedState);
        } else {
          layer.setStyle(this.staledState);
        }
      }
    });
  }

  get type() {
    if (!this.data.id || !this.data.resourceType) return undefined;
    return this.data.resourceType;
  }
  get resourceType() {
    return this.type;
  }

  get id() {
    return parseInt(`${this.data.id}`) || undefined;
  }

  get scopeId() {
    return parseInt(`${this.data.geoScopeId}`) || undefined;
  }
  get geoScopeId() {
    return this.scopeId;
  }

  get selectedState() {
    return { color: "var(--primary)" };
  }

  get staledState() {
    return { color: "#404040" };
  }

  async panToMarker() {
    const { map_config: mapConfig } = configStore.getState();
    const { focus_zoom_level: focusZoomLevel = 21 } = mapConfig;
    if (!this.isGeoLocated()) return;
    const { map } = configStore.getState();
    return new Promise((resolve) => {
      map
        .flyTo(this.marker.getLatLng(), focusZoomLevel, {
          animate: false,
          noMoveStart: true
        })
        .once("moveend", () => {
          this.repaint();
          resolve();
        });
    });
  }

  select() {
    geoStore.getState().selectPoint(this);
  }

  init() {
    if (this.data?.lonlat?.latitude && this.data?.lonlat?.longitude) {
      this.marker = nodeMarker(this.data);
      this.marker.on("click", this.select.bind(this));
      this.bringToFront();
    }
    try {
      this.repaint();
      this.menuItem = drawerListItem(this.data);
      this.menuItem.onclick = this.select.bind(this);

      geoStore.subscribe(
        (state) => [state.selectedPoint],
        (_np, [unselectedPoint]) => {
          if (unselectedPoint) {
            unselectedPoint.repaint();
          }
          this.repaint();
        }
      );
    } catch (error) {
      console.error("ERROR: decidim-geo can't initialize ", { error });
    }
    return this;
  }
}
