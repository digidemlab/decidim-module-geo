function getHashtagFromNode(node, locale, defaultLocale) {
  const rawText = node.title?.[locale] || node.title?.[defaultLocale];
  if (!rawText) return "";

  const gidMatch = rawText.match(/gid:.*./);
  if (!gidMatch) return rawText;

  const gid = gidMatch[0];
  const nameMatch = gid.match(/\/(\d+)\/(.*)$/);
  if (!nameMatch || !nameMatch[2]) return rawText;

  const encodedName = nameMatch[2];

  try {
    const decodedName = decodeURIComponent(encodedName);
    return `#${decodedName.trim()}`;
  } catch (error) {
    console.warn("Erro ao decodificar nome da hashtag:", encodedName, error);
    return rawText; 
  }
}
export default getHashtagFromNode;