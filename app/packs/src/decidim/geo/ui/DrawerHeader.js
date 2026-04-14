import createClasses from "./createClasses";
import geoStore from "../stores/geoStore";
import pointStore from "../stores/pointStore";
import pointCounterStore from "../stores/pointCounterStore";
import configStore from "../stores/configStore";
import filterStore from "../stores/filterStore";
import dropdownFilterStore from "../stores/dropdownFilterStore";
import _, { filter } from "lodash";
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
    const { locale, defaultLocale } = configStore.getState();

    this.container = L.DomUtil.create(
      "div",
      "leaflet-control decidimGeo__drawer",
      this.parent
    );
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

    this.resultsBox = L.DomUtil.create("ul", "decidimGeo__searchResults", this.searchBox);

    L.DomEvent.disableClickPropagation(this.resultsBox);
    L.DomEvent.disableScrollPropagation(this.resultsBox);

    let startY = 0;
    let isScrolling = false;

    this.resultsBox.addEventListener("touchstart", (e) => {
      startY = e.touches[0].clientY;
      isScrolling = false;
    });

    this.resultsBox.addEventListener("touchmove", (e) => {
      const moveY = e.touches[0].clientY;

      if (Math.abs(moveY - startY) > 10) {
        isScrolling = true;
      }
    });

    const input = this.searchBox.querySelector(".decidimGeo__searchInput");

    L.DomEvent.disableClickPropagation(input);
    L.DomEvent.disableScrollPropagation(input);

    L.DomEvent.on(input, "keydown", (e) => {
      if (e.key === "Enter") {
        e.preventDefault();
        const value = e.target.value.trim();
        this.onSearchEnter(value);
        input.blur();
      }
    });

    this.onSearchEnter = function (value) {
      let { activeFilters, setFilters } = filterStore.getState();
      activeFilters = activeFilters.filter((f) => !f.searchFilter);
      let filters = value
        ? [...activeFilters, { searchFilter: { title: value } }]
        : activeFilters;

      pointsForFilters(filters);
      this.pointCounterStore.updateCurrentCountForFilters(filters);
      setFilters(filters);

      this.resultsBox.classList.remove("is-open");

      const searchItems = document.querySelectorAll(".decidimGeo__searchItem");
      if (searchItems) {
        searchItems.forEach((item) => item.remove());
      }

      const drawer = document.querySelector(".decidimGeo__drawerSearch");
      if (drawer) {
        drawer.classList.remove("has-results");
      }

      const { isAsideOpen } = configStore.getState();
      if (isAsideOpen === false)
        configStore.setState(({ isAsideOpen }) => ({ isAsideOpen: true }));
    };

    L.DomEvent.on(input, "input", (e) => {
      const value = e.target.value.trim();
      throttledOnSearchInput(value);
    });

    const closeSearch = () => {
      this.resultsBox.classList.remove("is-open");
      const drawer = document.querySelector(".decidimGeo__drawerSearch");
      if (drawer) {
        drawer.classList.remove("has-results");
      }
      document
        .querySelectorAll(".decidimGeo__searchItem")
        .forEach((item) => item.remove());
    };

    input?.addEventListener("blur", closeSearch);
    input?.addEventListener("change", closeSearch);

    const throttledOnSearchInput = _.throttle(
      (value) => {
        this.onSearchInput(value.trim());
      },
      640,
      { leading: false, trailing: true }
    );

    this.onSearchInput = async function (term) {
      if (!term || term.length < 2) {
        this.resultsBox.innerHTML = "";
        this.resultsBox.classList.remove("is-open");
        const drawer = document.querySelector(".decidimGeo__drawerSearch");
        if (drawer) {
          drawer.classList.remove("has-results");
        }
        return;
      }

      const { activeFilters } = filterStore.getState();

      const filter = JSON.stringify({ searchFilter: { title: term } });

      const response = await this.getResults(filter, activeFilters);
      const data = response.data;
      this.renderResults(data);
    };

    this.getResults = async function (filter, activeFilters) {
      const params = new URLSearchParams({
        "filters[]": filter,
        locale: locale,
        is_index: true
      });
      activeFilters.forEach((f) => {
        params.append("filters[]", JSON.stringify(f));
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
      const drawer = document.querySelector(".decidimGeo__drawerSearch");

      if (!data.length) {
        this.resultsBox.innerHTML = `<div class="decidimGeo__searchItem">
          ${i18n["decidim.geo.no_results"]}
        </div>`;
        drawer.classList.add("has-results");
        this.resultsBox.classList.add("is-open");
        return;
      }

      data.forEach((point) => {
        const item = L.DomUtil.create("li", "decidimGeo__searchItem", this.resultsBox);

        L.DomEvent.disableClickPropagation(item);
        L.DomEvent.disableScrollPropagation(item);

        item.textContent = point.title[locale] || point.title[defaultLocale];

        item.addEventListener("pointerdown", (e) => {
          const searchInput = document.querySelector(".decidimGeo__searchInput");
          if (searchInput) {
            searchInput.value = e.target.textContent;
          }

          this.onSearchEnter(point.title[locale]);
        });
      });
      drawer.classList.add("has-results");
      this.resultsBox.classList.add("is-open");
    };

    this.menu = L.DomUtil.create("div", "decidimGeo__drawerHeader", this.parent);

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
