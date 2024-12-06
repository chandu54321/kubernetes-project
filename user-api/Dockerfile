FROM node:17.9.0-slim
LABEL name="chandu"
RUN useradd userapi
WORKDIR /app
RUN chown userapi /app /home
COPY . .
RUN npm install 
EXPOSE 1004
USER userapi
CMD ["npm","start"]
