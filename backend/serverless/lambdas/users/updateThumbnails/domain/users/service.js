const moment = require('moment');
const {
  aws: awsConfig,
} = require('../../configuration');

const getThumbnailKey = (index) => {
  switch (index) {
    case 0:
      return 'small';
    case 1:
      return 'medium';
    case 2:
      return 'large';
    default:
      throw new Error('Wrong index');
  }
};

function init({
  filesRepository,
  imagesTransformationRepository,
  usersRepository,
}) {
  async function updateUserThumbnails({
    userId,
    profileImage,
  }) {
    const thumbnails = await Promise.all([
      imagesTransformationRepository.cropImage({ imageUrl: profileImage, width: 100, height: 100 }),
      imagesTransformationRepository.cropImage({ imageUrl: profileImage, width: 200, height: 200 }),
      imagesTransformationRepository.cropImage({ imageUrl: profileImage, width: 300, height: 300 }),
    ]);
    const s3ImagesResponse = await Promise.all(thumbnails.map(async (thumbnail, index) => filesRepository.uploadFileFromBase64({
      base64: thumbnail,
      bucket: awsConfig.s3.bucket,
      key: `${userId}__${moment.utc().valueOf()}_${index}`,
    })));
    return usersRepository.updateUser({
      userId,
      thumbnails: s3ImagesResponse.map((s3Response, index) => ({
        [getThumbnailKey(index)]: {
          href: s3Response.fileUrl,
        },
      })),
    });
  }

  return Object.freeze({
    updateUserThumbnails,
  });
}


module.exports.init = init;
