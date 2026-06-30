import _ from "lodash";
import configStore from "../../stores/configStore";
import createClasses from "../createClasses";
import L from "../../leaflet";
import getHashtagFromNode from "../drawerHelper";
import getArrowIcon from "../geoIcons";

const fallback = (container, node) => {
  let { i18n, images, locale, defaultLocale, filters } = configStore.getState();

  defaultLocale = node?.extendedData?.defaultLocale || defaultLocale;

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

  const infoTitle = L.DomUtil.create(
    "div",
    "decidimGeo__drawer__listCardTitle",
    container
  );
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
    const text = node.shortDescription[locale] || node.shortDescription[defaultLocale];

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
