const httpErrors = require('../../common/errors');
const {
  USER_ROLE,
} = require('../../common/constants');

function getUserPKFromRequestContext(event) {
  return event && event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.lambda
    ? event && event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.lambda.id
    : undefined;
}

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

function isAbleToCreatePost(event) {
  if (!event.requestContext
    || !event.requestContext.authorizer
    || !event.requestContext.authorizer.lambda
    || !event.requestContext.authorizer.lambda.roles
    || !Array.isArray(event.requestContext.authorizer.lambda.roles)
    || event.requestContext.authorizer.lambda.roles.length <= 0
    || !event.requestContext.authorizer.lambda.roles.includes(USER_ROLE)
  ) {
    throw new httpErrors.Forbidden('Only user can create posts');
  }
  if (getUserIdFromRequestContext(event) !== getUserIdFromPath(event)
  ) {
    throw new httpErrors.Forbidden('Can only create yours posts');
  }
}

module.exports = {
  isAbleToCreatePost,
  getUserPKFromRequestContext,
};
