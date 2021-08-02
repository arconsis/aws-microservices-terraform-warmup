const logging = require('./common/logging');
const authenticationMiddlewareFactory = require('./presentation/middleware/authentication');
const tokenServiceFactory = require('./domain/token/service');
const tokenRepositoryFactory = require('./data/repositories/token/tokenRepository');

const authenticationMiddleware = authenticationMiddlewareFactory.init();
const tokenRepository = tokenRepositoryFactory.init();
const tokenService = tokenServiceFactory.init({
  tokenRepository,
});

/*
  TODO: check correct policy for v2 to see what is going wrong,
  then we can remove simple response and remove enable_simple_responses
*/
// const generatePolicy = (principalId, effect, resource) => {
//   const authResponse = {};
//   authResponse.principalId = principalId;
//   if (effect && resource) {
//     const policyDocument = {};
//     policyDocument.Version = '2012-10-17';
//     policyDocument.Statement = [];
//     const statementOne = {};
//     statementOne.Action = 'execute-api:Invoke';
//     statementOne.Effect = effect;
//     statementOne.Resource = resource;
//     policyDocument.Statement[0] = statementOne;
//     authResponse.policyDocument = policyDocument;
//   }
//   return authResponse;
// };

const generateResponse = (isAuthorized, context = {}) => {
  return {
    isAuthorized,
    context,
  };
};

exports.handler = async function verifyTokenHandler(event, context) {
  logging.log(`EVENT: \n ${JSON.stringify(event, null, 2)}`);
  logging.log('Authorization: ', event.headers.authorization);
  try {
    const tokenValue = authenticationMiddleware.getJWTFromAuthHeader(event);
    const decodedToken = await tokenService.verifyToken(tokenValue);
    if (!decodedToken) {
      return generateResponse(false, {
        AuthInfo: 'Deny',
      });
    }
    return generateResponse(true, {
      AuthInfo: 'Allow',
      UserId: decodedToken.userId,
      Roles: decodedToken.roles,
    });
  } catch (error) {
    return generateResponse(false, {
      AuthInfo: 'Deny',
    });
  }
};
