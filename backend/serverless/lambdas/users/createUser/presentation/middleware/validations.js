const validator = require('validator');

function assertCreateUserPayload(payload) {
  if (!payload) {
    throw new Error('Payload not found');
  }
  if (!payload.email || !validator.isEmail(payload.email)) {
    throw new Error('email not provided. Make sure you have a correct "email" property in your request body.');
  }
  if (!payload.password) {
    throw new Error('password not provided. Make sure you have a "password" property in your request body.');
  }
  if (!payload.firstName) {
    throw new Error('firstName not provided. Make sure you have a "firstName" property in your request body.');
  }
  if (!payload.lastName) {
    throw new Error('lastName not provided. Make sure you have a "lastName" property in your request body.');
  }
  if (!payload.userName) {
    throw new Error('userName not provided. Make sure you have a "userName" property in your request body.');
  }
}

module.exports = {
  assertCreateUserPayload,
};
