import configStore from "../../stores/configStore";
import createClasses from "../createClasses";
import _ from "lodash";
import L from "../../leaflet";
import getHashtagFromNode from "../drawerHelper";
import getArrowIcon from "../geoIcons";

const fallback = (node) => {
  let { i18n, images, locale, defaultLocale, filters } = configStore.getState();
  defaultLocale = node?.extendedData?.defaultLocale || defaultLocale
  const hasImage = !_.isEmpty(node.imageUrl);
  const listCard = L.DomUtil.create("li", "decidimGeo__drawer__listCard");

  defaultLocale = node?.extendedData?.defaultLocale || defaultLocale;

  const GeoEncodedIcon = L.DomUtil.create(
    "img",
    createClasses("decidimGeo__drawer__listCardIcon"),
    listCard
  );

  GeoEncodedIcon.src = images?.geolocated;

  if (!node.lonlat) {
    GeoEncodedIcon.style.opacity = "0.32";
  }

  const info = L.DomUtil.create(
    "div",
    createClasses("decidimGeo__drawer__listCardInfo", [!hasImage && "large"]),
    listCard
  );

  const infoType = L.DomUtil.create("div", "decidimGeo__drawer__listCardType", info);
  const infoTxt = L.DomUtil.create(
    "span",
    createClasses("decidimGeo__drawer__listCardTxt"),
    infoType
  );

  infoTxt.textContent = i18n[node.resourceType];

  const infoTitle = L.DomUtil.create("div", "decidimGeo__drawer__listCardTitle", info);
  const infoTitleTxt = L.DomUtil.create(
    "span",
    createClasses("decidimGeo__drawer__listTitleTxt"),
    infoTitle
  );

  infoTitleTxt.textContent = getHashtagFromNode(node, locale, defaultLocale);

  const hasAssemblyOrProcess = filters?.some(
    (f) => f.assembly_filter || f.process_filter
  );

  if (node?.extendedData?.componentUrl && !hasAssemblyOrProcess) {
    const infoChild = L.DomUtil.create(
      "div",
      createClasses("decidimGeo__drawer__listCardChild"),
      infoTitle
    );
    infoChild.innerHTML += getArrowIcon();
  } else {
    const infoChild = L.DomUtil.create(
      "div",
      createClasses("decidimGeo__drawer__listCardTitle"),
      infoTitle
    );
  }

  if (node.shortDescription) {
    const text =
      node.shortDescription[locale] ||
      node.shortDescription[defaultLocale] ||
      Object.values(node.shortDescription)[0];

    if (text && !text.includes("Translation missing")) {
      const infoDescription = L.DomUtil.create(
        "div",
        "decidimGeo__drawer__listCardDescription",
        info
      );
      infoDescription.textContent = text;
    }
  }

  if (hasImage) {
    const image = L.DomUtil.create("img", "decidimGeo__drawer__listCardImg", listCard);
    image.src = node.imageUrl;
  }
  return listCard;
};

export default fallback;
