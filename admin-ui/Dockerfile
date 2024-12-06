FROM node:17.9.0-slim
LABEL name="chandu"
RUN useradd adminui
WORKDIR /app
RUN chown adminui /app /home
COPY . .
RUN npm install 
EXPOSE 3000
USER adminui
CMD ["npm","start"]
