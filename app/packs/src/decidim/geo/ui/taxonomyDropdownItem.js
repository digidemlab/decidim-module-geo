import geoStore from "../stores/geoStore";
import L from "../leaflet";
const taxonomyDropdownItem = ({ label, onClick, taxonomyId = undefined }) => {
  const menuItem = L.DomUtil.create("li", "decidimGeo__drawerHeader__listItem");
  menuItem.onclick = onClick;

  const menuItemText = L.DomUtil.create(
    "span",
    "decidimGeo__drawerHeader__listItemtxt",
    menuItem
  );
  menuItemText.textContent = label;

  const icn = L.DomUtil.create("span", "decidimGeo__drawerHeader__listItemIcn", menuItem);
  icn.innerHTML = `
  <svg width="11" height="8" viewBox="0 0 11 8" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M10 1.00024L4 6.99998L1 4.00024" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
`.trim();
  if (taxonomyId) menuItem.setAttribute("data-taxonomy", taxonomyId);
  const repaintItem = () => {
    const { selectedTaxonomy } = geoStore.getState();
    const id = selectedTaxonomy ? selectedTaxonomy?.id : "all";
    if (`${taxonomyId}` === `${id}`) {
      menuItem.className =
        "decidimGeo__drawerHeader__listItem decidimGeo__drawerHeader__listItem--active";
    } else {
      menuItem.className = "decidimGeo__drawerHeader__listItem";
    }
  };
  repaintItem();

  return [menuItem, repaintItem];
};

export default taxonomyDropdownItem;
