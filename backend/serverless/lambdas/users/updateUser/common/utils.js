function getPayloadAsJSON(event) {
  try {
    return JSON.parse(event.body);
  } catch (error) {
    return undefined;
  }
}

module.exports = Object.freeze({
  getPayloadAsJSON,
});
