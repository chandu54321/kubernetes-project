FROM node:17.9.0-slim
LABEL name="chandu"
RUN useradd adminapi
WORKDIR /app
RUN chown adminapi /app /home
COPY . .
RUN npm install 
EXPOSE 1004
USER adminapi
CMD ["npm","start"]
