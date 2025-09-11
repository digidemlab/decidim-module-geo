import _ from "lodash";
import configStore from "../../stores/configStore";
import createClasses from "../createClasses";
import L from "../../leaflet";
import getHashtagFromNode from "../drawerHelper";

const fallback = (container, node) => {
  const { i18n, images, locale, defaultLocale } = configStore.getState();
  if (!_.isEmpty(node.imageUrl)) {
    const image = L.DomUtil.create(
      "img",
      "decidimGeo__drawer__listCardImg decidimGeo__drawer__listCardImg--large",
      container
    );
    image.src = node.imageUrl;
    container.className += " decidimGeo__drawer__listCardInfo--image";
  }

  const infoType = L.DomUtil.create("div", "decidimGeo__drawer__listCardType", container);
  const infoTxt = L.DomUtil.create(
    "span",
    createClasses("decidimGeo__drawer__listCardTxt"),
    infoType
  );
  infoTxt.textContent = i18n[node.resourceType];
  const notGeoEncodedIcon = L.DomUtil.create(
    "img",
    createClasses("decidimGeo__drawer__listCardIcon", [node.lonlat && "hidden"]),
    infoType
  );
  notGeoEncodedIcon.src = images?.not_geolocated;

  const infoTitle = L.DomUtil.create(
    "div",
    "decidimGeo__drawer__listCardTitle",
    container
  );
  infoTitle.textContent = getHashtagFromNode(node, locale, defaultLocale);
  console.log("infoTitle: " + infoTitle.textContent)
  if (node.descriptionHtml) {
    const text = node.descriptionHtml[locale] || node.descriptionHtml[defaultLocale];

    if (text && !text.includes("Translation missing")) {
      const infoDescription = L.DomUtil.create(
        "div",
        "decidimGeo__drawer__listCardDescription decidimGeo__drawer__listCardDescription--large",
        container
      );
      infoDescription.innerHTML = text;
    }
  }
};
export default fallback;
