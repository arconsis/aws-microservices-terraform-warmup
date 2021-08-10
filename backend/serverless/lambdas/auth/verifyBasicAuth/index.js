const logging = require('logging');
const authenticationMiddlewareFactory = require('./presentation/middleware/authentication');
const authServiceFactory = require('./domain/auth/service');

const authenticationMiddleware = authenticationMiddlewareFactory.init();
const authService = authServiceFactory.init();

const generateResponse = (isAuthorized, context = {}) => {
  return {
    isAuthorized,
    context,
  };
};

exports.handler = async function verifyBasicAuth(event, context) {
  logging.log(`Handler of verifyBasicAuth EVENT: \n ${JSON.stringify(event, null, 2)}`);
  try {
    const [username, password] = authenticationMiddleware.getBasicAuthCredentialsFromHeader(event);
    await authService.verifyToken({
      username,
      password,
    })
    return generateResponse(true, {
      authInfo: 'Allow Access',
    });
  } catch (error) {
    return generateResponse(false, {
      authInfo: 'Deny Access',
    });
  }
};
