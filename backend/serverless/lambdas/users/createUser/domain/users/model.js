class User {
  constructor({
    id,
    userId,
    firstName,
    lastName,
    userName,
    email,
    roles,
    createdAt,
  } = {}) {
    this.id = id;
    this.userId = userId;
    this.firstName = firstName;
    this.lastName = lastName;
    this.userName = userName;
    this.email = email;
    this.roles = roles;
    this.createdAt = createdAt;
  }
}

module.exports = User;
