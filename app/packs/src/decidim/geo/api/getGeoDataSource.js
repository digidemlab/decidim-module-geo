import { _getGeoDataSource, _getGeoDataSourceIds } from "./queries";

const getGeoDataSource = async (params = {}, fetchAll = true, callback) => {
  const { filters = [], locale, isIndex = false, offset = 0, first = 50 } = params;
  const fields = fetchAll
    ? [
        "resourceUrl",
        "resourceId",
        "resourceType",
        "resourceStatus",
        "participatorySpaceId",
        "participatorySpaceType",
        "componentId",
        "startDate",
        "endDate",
        "title",
        "shortDescription",
        "descriptionHtml",
        "imageUrl",
        "latitude",
        "longitude",
        "geoScopeId",
        "lonlat",
        "extendedData"
      ]
    : ["resourceType"];

  const searchParams = new URLSearchParams({
    locale,
    offset,
    first
  });
  if (isIndex) {
    searchParams.append("is_index", "true");
  }

  filters.forEach((f) => {
    searchParams.append("filters[]", JSON.stringify(f));
  });
  fields.forEach((f) => searchParams.append("fields[]", f));
  let page;
  try {
    const response = await fetch("/api/decidim-geo/points?" + searchParams.toString());
    if (response.ok) page = await response.json();
    else throw new Error(await response.text());
  } catch (error) {
    console.error(error);
    throw error;
  }
  if (!page) return { nodes: [], edges: [] };
  const { has_more: hasMoreThanOne } = page?.meta || {};
  callback(page.data, hasMoreThanOne, page?.meta || {});
  if (!hasMoreThanOne) return;
  let nextOffset = 50;
  searchParams.set("offset", nextOffset);
  while (true) {
    try {
      const response = await fetch("/api/decidim-geo/points?" + searchParams.toString());
      if (response.ok) page = await response.json();
      else throw new Error(await response.text());
    } catch (error) {
      console.error(error);
      return;
    }
    const { has_more: hasMore } = page.meta || {};
    callback(page.data, hasMore, page?.meta || {});
    if (!hasMore) break;
    nextOffset += 50;
    searchParams.set("offset", nextOffset);
  }
};
export default getGeoDataSource;
