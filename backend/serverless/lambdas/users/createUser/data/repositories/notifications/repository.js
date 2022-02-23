const AWS = require('aws-sdk');
const {
  aws: awsConfig,
} = require('../../../configuration');

AWS.config.update({
  region: awsConfig.sqs.region
});

module.exports.init = () => {
  const snsClient = new AWS.SNS({ apiVersion: '2010-03-31' });
  const notificationsRepository = {
    async publishMessage(messageAttributes, message, topic) {
      const params = {
        Message: message,
        MessageAttributes: messageAttributes,
        TopicArn: topic
      };
      console.log('params', params);
      const data = await snsClient.publish(params).promise();
      return data; // map it
    },
  };
  
  return Object.freeze(Object.create(notificationsRepository));
};
