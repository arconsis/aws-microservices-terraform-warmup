const {
  SQSClient,
  SendMessageCommand,
  ReceiveMessageCommand,
  DeleteMessageCommand,
} = require('@aws-sdk/client-sqs');
const {
  aws: awsConfig,
} = require('../../../configuration');

module.exports.init = () => {
  const sqsClient = new SQSClient({ region: awsConfig.sqs.region });
  const queueURL = awsConfig.sqs.queueURL;
  const queueRepository = {
    async sendMessage(message, body) {
      const params = {
        DelaySeconds: 10,
        MessageAttributes: message,
        MessageBody: body,
        // MessageDeduplicationId: "TheWhistler",  // Required for FIFO queues
        // MessageGroupId: "Group1",  // Required for FIFO queues
        QueueUrl: queueURL,
      };
      const data = await sqsClient.send(new SendMessageCommand(params));
      return data; // map it
    },
    async receiveMessages() {
      const params = {
        AttributeNames: ['SentTimestamp'],
        MaxNumberOfMessages: 10,
        MessageAttributeNames: ['All'],
        QueueUrl: queueURL,
        VisibilityTimeout: 20,
        WaitTimeSeconds: 0,
      };
      return sqsClient.send(new ReceiveMessageCommand(params));
    },
    async deleteMessage(receiptHandle) {
      const deleteParams = {
        QueueUrl: queueURL,
        ReceiptHandle: receiptHandle,
      };
      return sqsClient.send(new DeleteMessageCommand(deleteParams))
    },
  };

  return Object.freeze(Object.create(queueRepository));
};
