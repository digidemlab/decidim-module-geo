import configStore from "../../stores/configStore";
import createClasses from "../createClasses";
import _ from "lodash";
import { format, isSameDay } from "date-fns";
import { tz, TZDate } from "@date-fns/tz";
import L from "../../leaflet";
import getHashtagFromNode from "../drawerHelper";
import getArrowIcon from "../geoIcons";

const meetings = (node) => {
  let { i18n, images, locale, defaultLocale, filters } = configStore.getState();
  defaultLocale = node?.extendedData?.defaultLocale || defaultLocale
  const listCard = L.DomUtil.create("li", "decidimGeo__drawer__listCard");
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
    "decidimGeo__drawer__listCardInfo decidimGeo__drawer__listCardInfo--large",
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

  const infoDescription = L.DomUtil.create(
    "div",
    "decidimGeo__drawer__listCardDate",
    info
  );
  const infoStart = L.DomUtil.create(
    "strong",
    "decidimGeo__drawer__listCardStartDate",
    infoDescription
  );

  // Date
  let match = node.startDate.match(/([+-]\d{2}:\d{2})$/);
  let timezone = match ? match[1] : null;
  
  let startDate = new TZDate(node.startDate, timezone)
  let endDate = new TZDate(node.endDate, timezone)

  let displayedDate = format(startDate, "dd/MM/yyyy", { in: tz(timezone) })  + "-" + format(endDate, "dd/MM/yyyy", { in: tz(timezone) });

  if (isSameDay(startDate, endDate)) {
    displayedDate = format(startDate, "dd/MM/yyyy", { in: tz(timezone) });
  }
  infoStart.textContent = displayedDate;

  const infoStartSep = L.DomUtil.create(
    "span",
    "decidimGeo__drawer__listCardStartDateSep",
    infoDescription
  );
  infoStartSep.textContent = "·";

  // Time
  const infoStartTime = L.DomUtil.create(
    "span",
    "decidimGeo__drawer__listCardStartTime",
    infoDescription
  );

  let timeFormat = i18n["decidim.geo.time.formats.12h_24h"]

  const formatMap = {
    "%H:%M": "HH:mm",
    "%I:%M %p": "hh:mm aa",
  };

  timeFormat = formatMap[timeFormat] || timeFormat;

  let displayedTime = format(startDate, timeFormat, { in: tz(timezone) }) + "-" + format(endDate, timeFormat, { in: tz(timezone) });

  infoStartTime.textContent = displayedTime
  
  return listCard;
};

export default meetings;
