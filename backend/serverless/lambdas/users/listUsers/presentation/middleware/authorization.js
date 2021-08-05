const httpErrors = require('../../common/errors');
const {
  ADMIN_ROLE,
} = require('../../common/constants');

function isAbleToListUsers(event) {
  if (!event.requestContext
    || !event.requestContext.authorizer
    || !event.requestContext.authorizer.lambda
    || !event.requestContext.authorizer.lambda.roles
    || !Array.isArray(event.requestContext.authorizer.lambda.roles)
    || event.requestContext.authorizer.lambda.roles.length <= 0
    || (!event.requestContext.authorizer.lambda.roles.includes(ADMIN_ROLE))
  ) {
    throw new httpErrors.Forbidden('Not able to list users');
  }
}

module.exports = {
  isAbleToListUsers,
};
