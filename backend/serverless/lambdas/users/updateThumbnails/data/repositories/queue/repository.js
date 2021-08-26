// const {
//   SQSClient,
//   ReceiveMessageCommand,
//   DeleteMessageCommand,
// } = require('@aws-sdk/client-sqs');
// const {
//   aws: awsConfig,
// } = require('../../../configuration');

// module.exports.init = () => {
//   const sqsClient = new SQSClient({ region: awsConfig.sqs.region });
//   const queueURL = awsConfig.sqs.queueURL;
//   const params = {
//     AttributeNames: ['SentTimestamp'],
//     MaxNumberOfMessages: 10,
//     MessageAttributeNames: ['All'],
//     QueueUrl: queueURL,
//     VisibilityTimeout: 20,
//     WaitTimeSeconds: 0,
//   };

//   const queueRepository = {
//     async receiveMessages() {
//       return sqsClient.send(new ReceiveMessageCommand(params));
//     },
//     async deleteMessage(receiptHandle) {
//       const deleteParams = {
//         QueueUrl: queueURL,
//         ReceiptHandle: receiptHandle,
//       };
//       return sqsClient.send(new DeleteMessageCommand(deleteParams))
//     },
//   };

//   return Object.freeze(Object.create(queueRepository));
// };
