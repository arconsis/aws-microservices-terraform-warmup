/* eslint-disable prefer-object-spread */
const httpErrors = require('throw-http-errors');

const isHttpError = (error) => {
  if (Object.keys(httpErrors).includes(error.name) || (error.status && Object.keys(httpErrors).includes(error.status.toString()))) {
    return true;
  }
  return false;
};

const createResponseError = (err) => ({
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
  const internalError = new httpErrors.InternalServerError(err.message);
  return isHttpError(err) ? createResponseError(err) : createResponseError(internalError);
}

module.exports = Object.assign(
  {},
  errorHandler,
  httpErrors,
  {
    isHttpError,
  },
);
