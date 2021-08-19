const httpErrors = require('../../common/errors');
const {
  USER_ROLE,
} = require('../../common/constants');

function getUserIdFromRequestContext(event) {
  return event && event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.lambda
    ? event.requestContext.authorizer.lambda.userId
    : undefined;
}

function getUserIdFromPath(event) {
  return event && event.pathParameters
    ? event.pathParameters.userId
    : undefined;
}

function getIdFromRequestContext(event) {
  return event && event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.lambda
    ? event && event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.lambda.id
    : undefined;
}

function isAbleToUpdateSpecificUser(event) {
  if (!event.requestContext
    || !event.requestContext.authorizer
    || !event.requestContext.authorizer.lambda
    || !event.requestContext.authorizer.lambda.roles
    || !Array.isArray(event.requestContext.authorizer.lambda.roles)
    || event.requestContext.authorizer.lambda.roles.length <= 0
    || !event.requestContext.authorizer.lambda.roles.includes(USER_ROLE)
    || getUserIdFromRequestContext(event) !== getUserIdFromPath(event)
  ) {
    throw new httpErrors.Forbidden('Can update only yours user account');
  }
}

module.exports = Object.freeze({
  isAbleToUpdateSpecificUser,
  getUserIdFromPath,
  getIdFromRequestContext,
});
