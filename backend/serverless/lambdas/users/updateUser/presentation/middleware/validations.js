const validator = require('validator');

function assertUpdateUserPayload(payload) {
  if (!payload) {
    throw new Error('Event not found');
  }
  if (!payload.profileImage
    // || !validator.isBase64(payload.profileImage, { urlSafe: true })
  ) {
    throw new Error('profileImage not provided. Make sure you have a correct "profileImage" property as base64 in your request body.');
  }
}

module.exports = {
  assertUpdateUserPayload,
};
