class Admin {
  constructor({
    id,
    adminId,
    firstName,
    lastName,
    email,
    createdAt,
  } = {}) {
    this.id = id;
    this.adminId = adminId;
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.createdAt = createdAt;
  }
}

module.exports = Admin;
