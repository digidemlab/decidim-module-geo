import configStore from "../../stores/configStore";

const openFullscreen = () => {
  const { map } = configStore.getState();
  
  const searchBox = document.querySelector(".decidimGeo__drawerSearch");
  const topLeft = map.getContainer().querySelector(".leaflet-top.leaflet-left");

  if (searchBox && topLeft && searchBox.parentNode !== topLeft) {
    topLeft.appendChild(searchBox);
  }
  
  map.toggleFullscreen();
  $("body").addClass("noscroll");
  $(".decidimGeo__container").addClass("decidimGeo__container--fullscreen");
};

export default openFullscreen;
