FROM node:14-alpine as builder
ARG NPM_TOKEN
RUN mkdir -p /build

COPY ./package.json ./package-lock.json /build/
WORKDIR /build
RUN npm install && \
    rm -f .npmrc

# Bundle app source
COPY . /build

FROM node:12-alpine
# user with username node is provided from the official node image
ENV user node
# Run the image as a non-root user
USER $user

# Create app directory
RUN mkdir -p /home/$user/booksservice/src
WORKDIR /home/$user/booksservice/src

COPY --from=builder /build ./

EXPOSE 5000

ENV NODE_ENV production

CMD ["npm", "start"]
