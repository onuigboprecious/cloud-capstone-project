FROM nginx:alpine

# Copy custom Nginx reverse proxy configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static frontend assets (HTML, CSS, JS)
COPY index.html submissions.html styles.css /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
