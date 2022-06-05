FROM  node:16-alpine as builder

RUN mkdir /app
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY package.json ./package.json
RUN npm install --silent

COPY ./src ./src
COPY ./public ./public
COPY ./tsconfig.json ./tsconfig.json

CMD ["npm", "start"]
