import configStore from "../../stores/configStore";

const openFullscreen = () => {
  const { map } = configStore.getState();
  
  const searchBox = document.querySelector(".decidimGeo__drawerSearch");
  const searchResults = document.querySelector(".decidimGeo__searchResults");
  const topLeft = map.getContainer().querySelector(".leaflet-top.leaflet-left");

  if (!searchBox.parentNode || searchBox.parentNode !== topLeft && 
      !searchResults.parentNode || searchResults.parentNode !== topLeft)
  {
    topLeft.appendChild(searchBox);
    topLeft.appendChild(searchResults);
  }
  
  map.toggleFullscreen();
  $("body").addClass("noscroll");
  $(".decidimGeo__container").addClass("decidimGeo__container--fullscreen");
};

export default openFullscreen;
