function assertCreatePostPayload(payload) {
  if (!payload) {
    throw new Error('payload not found');
  }
  if (!payload.title) {
    throw new Error('title not provided. Make sure you have a "title" property in your request body.');
  }
  if (!payload.message) {
    throw new Error('message not provided. Make sure you have a "message" property in your request body.');
  }
}

module.exports = {
  assertCreatePostPayload,
};
