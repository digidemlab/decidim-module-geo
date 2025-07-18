import configStore from "../../stores/configStore";

const closeFullscreen = () => {
  const { map } = configStore.getState();
  map.toggleFullscreen();
  $("body").removeClass("noscroll");
  $(".decidimGeo__container").removeClass("decidimGeo__container--fullscreen");
};

export default closeFullscreen;
