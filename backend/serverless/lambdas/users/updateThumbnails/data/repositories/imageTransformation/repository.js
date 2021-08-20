const fetch = require('node-fetch');

module.exports.init = function init() {
  async function checkStatus(res) {
    if (res.ok) { // res.status >= 200 && res.status < 300
      const response = await res.json();
      return response;
    }
    const response = await res.json();
    const msg = response && response.data && response.data.message
      ? response.data.message
      : res.statusText;
    throw new Error(msg);
  }

  async function transformImage(imageUrl) {
    const baseUrl = 'https://res.cloudinary.com/demo/image/fetch/c_fill,g_face,h_100,w_100/r_max/f_auto';
    const res = await fetch(`${baseUrl}/${imageUrl}`,
      {
        method: 'get',
      });
    if (!res) {
      throw new Error('Response not found when tried to make get request.');
    }
    return checkStatus(res);
  }

  return Object.freeze({
    transformImage,
  });
};
