import createClasses from "./createClasses";
import geoStore from "../stores/geoStore";
import pointStore from "../stores/pointStore";
import pointCounterStore from "../stores/pointCounterStore";
import configStore from "../stores/configStore";
import getGeoDataSource from "../api/getGeoDataSource";
import dropdownFilterStore from "../stores/dropdownFilterStore";
import _ from "lodash";
import AsideToggle from "./AsideToggle";
import L from "../leaflet";

export default class DrawerHeader {
  //View
  constructor(parent) {
    this.parent = parent;
    this.menu = null;
    this.heading = null;
    this.titleBack = null;
    this.toggleDrawer = null;
    this.searchField = null;
    this.pointCounterStore = pointCounterStore.getState();
  }

  config() {
    return configStore.getState();
  }

  i18n() {
    return this.config().i18n;
  }

  initMenuElements() {
    const { selectedPoint } = geoStore.getState();
    const { isOpen } = dropdownFilterStore.getState();
    const { i18n, isAsideOpen } = configStore.getState();

    this.heading = L.DomUtil.create(
      "div",
      createClasses("decidimGeo__drawerHeader__heading", [
        isOpen || (isAsideOpen && "closed")
      ]),
      this.menu
    );
    this.backRow = L.DomUtil.create(
      "div",
      createClasses("decidimGeo__drawerHeaderRow", ["filters"]),
      this.heading
    );

    this.titleBack = L.DomUtil.create(
      "span",
      createClasses("decidimGeo__drawerHeader__backButton", [
        "back",
        !selectedPoint && "hidden"
      ]),
      this.backRow
    );
    this.titleBack.innerHTML = `<svg width="25" height="25" viewBox="0 0 25 25" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M16.0413 17.1115L11.4613 12.5315L16.0413 7.94149L14.6313 6.53149L8.63135 12.5315L14.6313 18.5315L16.0413 17.1115Z" fill="currentColor"/>
</svg><span>${i18n["decidim_geo.filters.back"]}</span>`;

    this.toggleDrawer = new AsideToggle(this.heading);

    this.repaint();
  }

  repaint() {
    const { selectedPoint } = geoStore.getState();
    this.backRow.className = createClasses("decidimGeo__drawerHeaderRow", [
      !selectedPoint && "hidden"
    ]);
    this.titleBack.className = createClasses("decidimGeo__drawerHeader__backButton", [
      "back",
      !selectedPoint && "hidden"
    ]);
    if (selectedPoint) {
      this.titleBack.onclick = this.goBackHandler.bind(this);
      return;
    } else {
      this.titleBack.onclick = () => {};
    }
  }

  goBackHandler() {
    geoStore.getState().goBack();
  }

  onAdd() {
    const { pointsForFilters } = pointStore.getState();

    this.container = L.DomUtil.create("div", "leaflet-control decidimGeo__drawer", this.parent);
    this.searchBox = L.DomUtil.create("div", "decidimGeo__drawerSearch", this.container);

    const i18n = this.i18n();

    this.searchBox.innerHTML = `
      <span class="decidimGeo__searchIcon">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
          <path d="M21 21l-4.35-4.35m1.6-5.15a7 7 0 11-14 0 7 7 0 0114 0z"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"/>
        </svg>
      </span>
      <input
        type="search"
        class="decidimGeo__searchInput"
        placeholder="${i18n[`decidim.geo.search`]}";
      />
    `;

    this.resultsBox = L.DomUtil.create("ul", "decidimGeo__searchResults", this.container);

    const input = this.searchBox.querySelector(".decidimGeo__searchInput");

    L.DomEvent.on(input, "keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        const value = e.target.value.trim();
        this.onSearchEnter(value);
      }
    });

    L.DomEvent.on(input, "input", (e) => {
      const value = e.target.value.trim();
      this.onSearchInput(value);
    });

    this.onSearchEnter = function (value) {
      const filters = [{ searchFilter: {title: value}}]
      pointsForFilters(filters)
      this.pointCounterStore.updateCurrentCountForFilters(filters);
      this.resultsBox.classList.remove("is-open");
      const searchItems = document.querySelectorAll('.decidimGeo__searchItem');
      if (searchItems) { searchItems.forEach(item => item.remove()); };
      const searchInput = document.querySelector('.decidimGeo__searchInput');
      if (searchInput) { searchInput.value = ""; }
      const drawer = document.querySelector('.decidimGeo__drawerSearch');
      if (drawer) { drawer.classList.remove("has-results") }
    }

    this.onSearchInput = async function (term) {
      console.log("digitando:", term);

      if (!term || term.length < 2) {
        this.resultsBox.innerHTML = "";
        this.resultsBox.classList.remove("is-open");
        return;
      }

      const filter = JSON.stringify({ searchFilter: { title: term } });
      const response = await this.getResults(filter);
      const data = response.data;
      this.renderResults(data);
    };

    this.getResults = async function (filter) {
      const params = new URLSearchParams({
        "filters[]": filter
      });
      try {
        const response = await fetch("/api/decidim-geo/points/search?" + params);
        if (response.ok) return await response.json();
        else throw new Error(await response.text());
      } catch (error) {
        console.error(error);
        throw error;
      }
    };

    this.renderResults = function (data) {
      this.resultsBox.innerHTML = "";
      const drawer = document.querySelector('.decidimGeo__drawerSearch');

      if (!data.length) {
        this.resultsBox.innerHTML = `<div class="decidimGeo__searchItem">
          no results
        </div>`;
        drawer.classList.add("has-results")
        this.resultsBox.classList.add("is-open");
        return;
      }

      data.forEach((point) => {
        const item = L.DomUtil.create("li", "decidimGeo__searchItem", this.resultsBox);
        console.log("point: ", point.title.en)
        item.textContent = point.title.en;
        item.addEventListener('click', () => {
          this.onSearchEnter(point.title.en);
        })
      });
      drawer.classList.add("has-results")
      this.resultsBox.classList.add("is-open");
    };

    this.menu = L.DomUtil.create(
      "div",
      "decidimGeo__drawerHeader",
      this.parent
    );

    L.DomEvent.disableClickPropagation(this.menu);
    L.DomEvent.disableScrollPropagation(this.menu);

    // We we change the available scopes, repaint.
    geoStore.subscribe(
      (state) => [state.selectedScope],
      ([_geoScope], [prevGeoScope]) => {
        if (prevGeoScope) {
          prevGeoScope.repaint();
        }
        this.repaint();
      }
    );
    geoStore.subscribe(
      (state) => [state.selectedPoint],
      () => {
        this.repaint();
      }
    );
    pointStore.subscribe(
      (state) => [state.scopes, state.isLoading],
      ([scopes, isLoading]) => {
        if (!scopes || scopes.length == 0 || isLoading) return;
        this.repaint();
      }
    );
    dropdownFilterStore.subscribe(
      (state) => [state.isOpen],
      () => this.repaint()
    );
    configStore.subscribe(
      ({ isAsideOpen }) => [isAsideOpen],
      () => this.repaint()
    );
    this.initMenuElements();
    this.toggleDrawer.onAdd();

    this.repaint(); // first repaint
    this.toggleDrawer.repaint();
    return this.container;
  }
}
