class Post {
  constructor({
    id,
    postId,
    title,
    message,
    userId,
    createdAt,
  } = {}) {
    this.id = id;
    this.postId = postId;
    this.title = title;
    this.message = message;
    this.userId = userId;
    this.createdAt = createdAt;
  }
}

module.exports = Post;
