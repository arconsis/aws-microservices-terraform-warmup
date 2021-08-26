const AWS = require('aws-sdk');
const {
  aws: awsConfig,
} = require('../../../configuration');

module.exports.init = function init() {
  const s3 = new AWS.S3({
    region: awsConfig.s3.region,
  });

  async function uploadFileFromBase64({ base64, bucket, key }) {
    const base64Data = Buffer.from(base64.replace(/^data:image\/\w+;base64,/, ''), 'base64');
    const type = base64.split(';')[0].split('/')[1];
    console.log('image key', key);
    console.log('image type', type);
    const params = {
      Bucket: bucket,
      Key: `${key}.${type}`,
      Body: base64Data,
      ACL: 'public-read',
      ContentEncoding: 'base64',
      ContentType: `image/${type}`,
    };
    const { Location, Key } = await s3.upload(params).promise();
    return {
      fileUrl: Location,
      key: Key,
    };
  }

  return {
    uploadFileFromBase64,
  };
};
