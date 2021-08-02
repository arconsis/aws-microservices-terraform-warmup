class Token {
  constructor({
    accessToken,
    roles,
  } = {}) {
    if (accessToken == null || typeof accessToken !== 'string') {
      throw new Error('accessToken should be a string');
    }
    this.accessToken = accessToken;
    this.roles = roles;
  }
}

module.exports = Token;
