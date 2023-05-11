FROM node:16.20-slim
RUN mkdir -p /usr/src/rasbign && chown -R node:node /usr/src/rasbign

WORKDIR /usr/src/rasbign

COPY src/package.json src/package-lock.json ./
RUN npm ci 

COPY --chown=node:node src/ .

RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

USER node

#forcing it to run
# ENTRYPOINT ["tail", "-f", "/dev/null"]
#ENTRYPOINT ["npm", "run", "start"]
CMD [ "npm", "start" ]
