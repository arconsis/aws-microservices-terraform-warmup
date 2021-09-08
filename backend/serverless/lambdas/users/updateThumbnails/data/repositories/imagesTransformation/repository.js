const axios = require('axios');

module.exports.init = function init() {
  async function cropImage({
    imageUrl,
    width = 100,
    height = 100,
  }) {
    const baseUrl = `https://res.cloudinary.com/demo/image/fetch/c_fill,g_face,h_${height},w_${width}/r_max/f_auto`;
    const response = await axios.get(`${baseUrl}/${imageUrl}`, {
      responseType: 'arraybuffer',
    });
    const base64 = Buffer.from(response.data, 'binary').toString('base64');
    return `data:${response.headers['content-type'].toLowerCase()};base64,${base64}`;
  }

  return Object.freeze({
    cropImage,
  });
};
