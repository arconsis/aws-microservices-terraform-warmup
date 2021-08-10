class Admin {
  constructor({
    id,
    adminId,
    firstName,
    lastName,
    username,
    email,
    createdAt,
  } = {}) {
    this.id = id;
    this.adminId = adminId;
    this.firstName = firstName;
    this.lastName = lastName;
    this.username = username;
    this.email = email;
    this.createdAt = createdAt;
  }
}

module.exports = Admin;
