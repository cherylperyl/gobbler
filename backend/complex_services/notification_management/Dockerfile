FROM node:18-alpine

WORKDIR /server

COPY . /server
RUN npm install

EXPOSE 3000
CMD [ "npm", "start" ]
