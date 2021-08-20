const validator = require('validator');

function assertUpdateUserPayload(payload) {
  if (!payload) {
    throw new Error('Event not found');
  }
  if (!payload.profileImage || !validator.isURL(payload.profileImage)) {
    throw new Error('profileImage not provided. Make sure you have a correct "profileImage" property as URL in your request body.');
  }
}

module.exports = {
  assertUpdateUserPayload,
};
