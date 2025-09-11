function getHashtagFromNode(node, locale, defaultLocale) {
  const rawText = node.title?.[locale] || node.title?.[defaultLocale];
  if (!rawText) return "";

  const gidMatch = rawText.match(/gid:.*./);
  if (!gidMatch) return rawText;

  try {
    const decodedName = rawText.replace(/gid:\/\/rails-app\/Decidim::Hashtag\/\d+\//g, "#");
    return decodedName.trim();
  } catch (error) {
    console.warn("Error decoding hashtag name:", encodedName, error);
    return rawText; 
  }
}
export default getHashtagFromNode;