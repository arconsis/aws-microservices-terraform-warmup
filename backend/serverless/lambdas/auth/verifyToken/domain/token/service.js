function init({
  tokenRepository,
}) {
  async function verifyToken(token) {
    return tokenRepository.verifyToken(token);
  }

  return {
    verifyToken,
  };
}


module.exports.init = init;
