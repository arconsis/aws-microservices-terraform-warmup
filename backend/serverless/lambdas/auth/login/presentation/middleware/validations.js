const validator = require('validator');

function assertLoginEvent(event) {
  if (!event) {
    throw new Error('Event not found');
  }
  if (!event.email || !validator.isEmail(event.email)) {
    throw new Error('email not provided. Make sure you have a correct "email" property in your request body.');
  }
  if (!event.password) {
    throw new Error('password not provided. Make sure you have a "password" property in your request body.');
  }
}

module.exports = {
  assertLoginEvent,
};
