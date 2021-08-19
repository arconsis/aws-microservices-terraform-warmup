class User {
  constructor({
    id,
    userId,
    firstName,
    lastName,
    userName,
    email,
    profileImage,
    thumbnails,
    createdAt,
  } = {}) {
    this.id = id;
    this.userId = userId;
    this.firstName = firstName;
    this.lastName = lastName;
    this.userName = userName;
    this.email = email;
    this.profileImage = profileImage;
    this.thumbnails = thumbnails;
    this.createdAt = createdAt;
  }
}


module.exports = User;
