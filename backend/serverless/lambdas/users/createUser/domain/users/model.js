class User {
  constructor({
    id,
    firstName,
    lastName,
    userName,
    email,
    createdAt,
  } = {}) {
    this.id = id;
    this.firstName = firstName;
    this.lastName = lastName;
    this.userName = userName;
    this.email = email;
    this.createdAt = createdAt;
  }
}

module.exports = User;
