FROM node:21-alpine3.18

WORKDIR /usr/src/app

COPY package*.json ./

RUN apk add python3 py3-pip && apk add --update nodejs npm && npm install

COPY . .

RUN ls -a

EXPOSE 3000

RUN pip3 install --upgrade pip && pip3 install --ignore-installed njsscan

RUN npm run lint && njsscan app.js

CMD [ "node", "app.js" ]
