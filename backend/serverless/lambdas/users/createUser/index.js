const logging = require('logging');

exports.handler = async function(event, context) {
  logging.log("EVENT: \n" + JSON.stringify(event, null, 2));
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: 'Created user with success',
    }),
  };
}
