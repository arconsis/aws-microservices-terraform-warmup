const axios = require('axios');

module.exports.init = function init() {
  async function transformImage(imageUrl) {
    const baseUrl = 'https://res.cloudinary.com/demo/image/fetch/c_fill,g_face,h_100,w_100/r_max/f_auto';
    const response = await axios.get(`${baseUrl}/${imageUrl}`, {
      responseType: 'arraybuffer'
    });
    return Buffer.from(response.data, 'binary').toString('base64')
  }

  return Object.freeze({
    transformImage,
  });
};
