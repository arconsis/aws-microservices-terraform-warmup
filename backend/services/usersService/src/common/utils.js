const fetch = require('node-fetch');

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

async function makeGetRequest({
  url,
  params = {},
  headers = { 'Content-Type': 'application/json' },
}) {
  const res = await fetch(url,
    {
      method: 'get',
      headers,
    });
  if (!res) {
    throw new Error('Response not found when tried to make get request.');
  }
  return checkStatus(res);
}

module.exports = {
  makeGetRequest,
};
