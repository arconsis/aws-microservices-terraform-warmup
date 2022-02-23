/* eslint-disable guard-for-in */
/* eslint-disable no-undef */
/* eslint-disable no-restricted-syntax */

const {
  capitalize,
} = require('../../../common/utils');

const createQueueMessage = (type, value) => ({
  DataType: type,
  StringValue: `${value}`,
});

const toQueueMessageAttributes = function toQueueMessage(message) {
  const queueMessage = {};
  for (const property in message) {
    const type = typeof message[property];
    queueMessage[capitalize(property)] = createQueueMessage(capitalize(type), message[property]);
  }
  return queueMessage;
};


module.exports = {
  toQueueMessageAttributes,
};
