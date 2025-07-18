import configStore from "../../stores/configStore";

const openFullscreen = () => {
  const { map } = configStore.getState();
  map.toggleFullscreen();
  $("body").addClass("noscroll");
  $(".decidimGeo__container").addClass("decidimGeo__container--fullscreen");
};

export default openFullscreen;
