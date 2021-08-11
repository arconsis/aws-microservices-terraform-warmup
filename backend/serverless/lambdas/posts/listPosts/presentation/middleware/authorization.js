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

function isAbleToListPosts(event) {
  if (!event.requestContext
    || !event.requestContext.authorizer
    || !event.requestContext.authorizer.lambda
    || !event.requestContext.authorizer.lambda.roles
    || !Array.isArray(event.requestContext.authorizer.lambda.roles)
    || event.requestContext.authorizer.lambda.roles.length <= 0
    || (!event.requestContext.authorizer.lambda.roles.includes(USER_ROLE))
  ) {
    throw new httpErrors.Forbidden('Not able to list posts');
  }
  if (getUserIdFromRequestContext(event) !== getUserIdFromPath(event)
  ) {
    throw new httpErrors.Forbidden('Can only list yours posts');
  }
}

function getUserPKFromRequestContext(event) {
  return event && event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.lambda
    ? event && event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.lambda.id
    : undefined;
}

module.exports = {
  isAbleToListPosts,
  getUserPKFromRequestContext,
};
