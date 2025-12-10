import configStore from "../../stores/configStore";
import createClasses from "../createClasses";
import _ from "lodash";
import L from "../../leaflet";
import getHashtagFromNode from "../drawerHelper";
import getArrowIcon from "../geoIcons";

const proposals = (node) => {
  const { i18n, images, locale, defaultLocale, filters } = configStore.getState();
  const listCard = L.DomUtil.create(
    "li",
    "decidimGeo__drawer__listCard decidimGeo__drawer__listCard--proposals"
  );
  const info = L.DomUtil.create(
    "div",
    "decidimGeo__drawer__listCardInfo decidimGeo__drawer__listCardInfo--large",
    listCard
  );
  const metadatas = L.DomUtil.create("div", "decidimGeo__drawer__metas", info);

  const infoType = L.DomUtil.create("div", "decidimGeo__drawer__listCardType", metadatas);
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

  const infoTitle = L.DomUtil.create("div", "decidimGeo__drawer__listCardTitle", info);
  const infoTitleTxt = L.DomUtil.create("span", createClasses("decidimGeo__drawer__listTitleTxt"), infoTitle);
  infoTitleTxt.textContent = getHashtagFromNode(node, locale, defaultLocale);

  const status = node.resourceStatus || null;
  if (status) {
    const infoStatus = L.DomUtil.create(
      "div",
      createClasses("decidimGeo__drawer__listCardStatus", [status.toLowerCase()]),
      metadatas
    );
    infoStatus.textContent = status;
  }

  const hasAssemblyOrProcess = filters?.some(f => f.assembly_filter || f.process_filter);

  if (node?.extendedData?.componentUrl && !hasAssemblyOrProcess) {
    const infoChild = L.DomUtil.create("div", createClasses("decidimGeo__drawer__listCardChild"), infoTitle);
    infoChild.innerHTML += getArrowIcon();
  } else {
    const infoChild = L.DomUtil.create("div", createClasses("decidimGeo__drawer__listCardTitle"), infoTitle);
  }

  if (node.shortDescription) {
    const infoDescription = L.DomUtil.create("div", info);
    infoDescription.textContent =
      node.shortDescription[locale] || node.shortDescription[defaultLocale];
  }

  return listCard;
};

export default proposals;
