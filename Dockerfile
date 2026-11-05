FROM nginx:1.27-alpine
RUN apk add --no-cache apache2-utils
ENV PORT=8080
COPY 40-htpasswd.sh /docker-entrypoint.d/40-htpasswd.sh
RUN chmod +x /docker-entrypoint.d/40-htpasswd.sh
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY site/ /usr/share/nginx/html/
