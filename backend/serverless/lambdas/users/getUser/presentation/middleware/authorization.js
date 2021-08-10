const httpErrors = require('../../common/errors');
const {
  ADMIN_ROLE,
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

function isAbleToFetchSpecificUser(event) {
  if (!event.requestContext
    || !event.requestContext.authorizer
    || !event.requestContext.authorizer.lambda
    || !event.requestContext.authorizer.lambda.roles
    || !Array.isArray(event.requestContext.authorizer.lambda.roles)
    || event.requestContext.authorizer.lambda.roles.length <= 0
    || (!event.requestContext.authorizer.lambda.roles.includes(USER_ROLE) && !event.requestContext.authorizer.lambda.roles.includes(ADMIN_ROLE))
  ) {
    throw new httpErrors.Forbidden('No token roles attached');
  }
  if (event.requestContext.authorizer.lambda.roles.includes(USER_ROLE)
    && getUserIdFromRequestContext(event) !== getUserIdFromPath(event)
  ) {
    throw new httpErrors.Forbidden('Can fetch only yours user account');
  }
}

module.exports = {
  isAbleToFetchSpecificUser,
  getUserIdFromPath,
  getIdFromRequestContext,
};
