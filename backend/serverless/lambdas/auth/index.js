const logging = require('logging');

const BEARER_TOKEN_PREFIX = 'bearer';
const TOKEN_VALUE = 'secret';

/*
  TODO: check correct policy for v2 to see what is going wrong,
  then we can remove simple response and remove enable_simple_responses
*/
const generatePolicy = (principalId, effect, resource) => {
  const authResponse = {};
  authResponse.principalId = principalId;
  if (effect && resource) {
    const policyDocument = {};
    policyDocument.Version = '2012-10-17';
    policyDocument.Statement = [];
    const statementOne = {};
    statementOne.Action = 'execute-api:Invoke';
    statementOne.Effect = effect;
    statementOne.Resource = resource;
    policyDocument.Statement[0] = statementOne;
    authResponse.policyDocument = policyDocument;
  }
  return authResponse;
};

const generateResponse = (isAuthorized, context = {}) => {
  return {
    isAuthorized: isAuthorized,
    context: context
  };
}

exports.handler = async function(event, context) {
  logging.log("EVENT: \n" + JSON.stringify(event, null, 2));
  logging.log("Authorization: ", event.headers.authorization)
  if (!event.headers || !event.headers.authorization) {
    return generateResponse(false, { AuthInfo: "defaultdeny" });
  }

  const tokenParts = event.headers.authorization.split(' ');
  const tokenValue = tokenParts[1];

  if (tokenParts[0].toLowerCase() != BEARER_TOKEN_PREFIX || !tokenValue) {
    return generateResponse(false, { AuthInfo: "defaultdeny" });
  }
  if (tokenValue != TOKEN_VALUE) {
    return generateResponse(false, { AuthInfo: "defaultdeny" });
  }
  return generateResponse(true, { AuthInfo: "Customer1"});
  // generatePolicy('userId', 'Allow', event.methodArn);
};
