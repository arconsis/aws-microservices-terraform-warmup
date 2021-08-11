const errors = require('../../common/errors');

const createResponseError = err => ({
  statusCode: err.status,
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    data: {
      code: err.code,
      message: err.message,
    },
  }),
});

function errorHandler(err) {
  const internalError = new errors.InternalServerError(err.message);
  return errors.isHttpError(err) ? createResponseError(err) : createResponseError(internalError);
}

module.exports = errorHandler;
