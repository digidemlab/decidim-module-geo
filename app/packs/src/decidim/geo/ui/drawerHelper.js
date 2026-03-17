function getHashtagFromNode(node, locale, defaultLocale) {
  const rawText = node.title?.[locale] || node.title?.[defaultLocale] || Object.values(node.title)[0];
  if (!rawText) return "";

  const gidMatch = rawText.match(/gid:.*./);
  if (!gidMatch) return rawText;

  try {
    const decodedName = rawText.replace(/gid:\/\/.*?\/\d+\//g, "#");
    return decodedName.trim();
  } catch (error) {
    console.warn("Error decoding hashtag name:", encodedName, error);
    return rawText;
  }
}
export default getHashtagFromNode;
