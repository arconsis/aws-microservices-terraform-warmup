require('dotenv').config();
const logging = require('logging');

const generateResponse = (isAuthorized, context = {}) => {
  return {
    isAuthorized,
    context,
  };
};

exports.handler = async function verifyApiKeyHandler(event, context) {
  logging.log(`Handler of verifyApiKeyHandler EVENT: \n ${JSON.stringify(event, null, 2)}`);
  logging.log('Api-key: ', event.headers.api_key);
  try {
    if (!event || !event.headers || !event.headers.api_key) {
      return generateResponse(false, {
        AuthInfo: 'Deny',
      });
    }
    if (event.headers.api_key != process.env.API_KEY) {
      return generateResponse(false, {
        AuthInfo: 'Deny',
      });
    }
    return generateResponse(true, {
      AuthInfo: 'Allow',
    });
  } catch (error) {
    return generateResponse(false, {
      AuthInfo: 'Deny',
    });
  }
};
