const validator = require('validator');

function assertCreateUserPayload(event) {
  if (!event) {
    throw new Error('Event not found');
  }
  if (!event.email || !validator.isEmail(event.email)) {
    throw new Error('email not provided. Make sure you have a correct "email" property in your request body.');
  }
  if (!event.password) {
    throw new Error('password not provided. Make sure you have a "password" property in your request body.');
  }
  if (!event.firstName) {
    throw new Error('firstName not provided. Make sure you have a "firstName" property in your request body.');
  }
  if (!event.lastName) {
    throw new Error('lastName not provided. Make sure you have a "lastName" property in your request body.');
  }
  if (!event.userName) {
    throw new Error('userName not provided. Make sure you have a "userName" property in your request body.');
  }
}

module.exports = {
  assertCreateUserPayload,
};
