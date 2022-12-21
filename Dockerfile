FROM nginx:alpine
EXPOSE 8081
COPY ./index.html /usr/share/nginx/html/
CMD ["/bin/sh", "-c", "sed -i 's/listen  .*/listen 8081;/g' /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
