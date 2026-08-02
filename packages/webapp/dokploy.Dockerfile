FROM node:22.21 as build

WORKDIR /usr/src/app

COPY ./webapp/package.json ./webapp/.npmrc ./webapp/pnpm-lock.yaml /usr/src/app/

COPY ./webapp/patches/ /usr/src/app/patches/

RUN npm install pnpm@10.6.5 -g && pnpm install

COPY ./webapp/ /usr/src/app/

COPY ./shared/ /usr/src/shared/

# nginx.conf proxies /api/ to the "api" service (see docker-compose-dokploy.yml),
# so the built app should call the API through a relative path.
ENV VITE_API_URL=/api
ENV VITE_ENV=production

RUN pnpm run build

FROM nginx:1.25.1

COPY --from=build /usr/src/app/dist /var/www/litefarm

COPY ./webapp/dokploy.nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
