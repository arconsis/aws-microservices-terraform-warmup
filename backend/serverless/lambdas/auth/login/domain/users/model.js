class User {
  constructor({
    id,
    firstName,
    lastName,
    userName,
    email,
    password,
    createdAt,
  } = {}) {
    this.id = id;
    this.firstName = firstName;
    this.lastName = lastName;
    this.userName = userName;
    this.email = email;
    this.password = password;
    this.createdAt = createdAt;
  }
}

module.exports = User;
