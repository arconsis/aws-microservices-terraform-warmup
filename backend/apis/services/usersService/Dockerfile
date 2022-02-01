FROM node:14-alpine as builder

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci

COPY src ./

FROM node:14-alpine

WORKDIR /usr/src/app
COPY --from=builder /usr/src/app ./

USER node
EXPOSE $PORT

ENV NODE_ENV production

CMD ["node", "index.js"]
