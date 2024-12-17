FROM node:latest AS build
WORKDIR /app
COPY package*.json ./
RUN rm -rf /root/.npm && npm install --legacy-peer-deps --production
COPY . . 
RUN npm run build 
FROM nginx:alpine 
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 3000
RUN rm -rf /root/.npm && npm install --legacy-peer-deps --production
CMD ["nginx", "-g", "daemon off;"]
