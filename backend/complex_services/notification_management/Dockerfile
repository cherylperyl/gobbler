FROM node:18-alpine

WORKDIR /server

COPY package*.json /server
RUN npm ci

COPY . /server
RUN npm run build

EXPOSE 80
CMD [ "npm", "start" ]
