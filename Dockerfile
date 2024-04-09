# Etap pierwszy: Budowanie aplikacji Node.js
FROM node:alpine AS builder

# Ustawienie katalogu roboczego
WORKDIR /app

# Skopiowanie plików aplikacji
COPY . .

# Zdefiniowanie wersji aplikacji jako argument budowania
ARG VERSION=1.0.0

# Utworzenie pliku aplikacji Node.js, który wyświetla informacje o serwerze
RUN echo "const http = require('http');" > app.js \
    && echo "const os = require('os');" >> app.js \
    && echo "const server = http.createServer((req, res) => {" >> app.js \
    && echo "  res.writeHead(200, { 'Content-Type': 'text/plain' });" >> app.js \
    && echo "  res.write('Adres IP serwera: ' + getIpAddress() + '\\n');" >> app.js \
    && echo "  res.write('Lab5: ' + os.hostname() + '\\n');" >> app.js \
    && echo "  res.end('Wersja aplikacji: ' + process.env.VERSION + '\\n');" >> app.js \
    && echo "});" >> app.js \
    && echo "server.listen(3000);" >> app.js \
    && echo "function getIpAddress() {" >> app.js \
    && echo "  const interfaces = os.networkInterfaces();" >> app.js \
    && echo "  let ipAddress = '';" >> app.js \
    && echo "  for (const key in interfaces) {" >> app.js \
    && echo "    for (const iface of interfaces[key]) {" >> app.js \
    && echo "      if (iface.family === 'IPv4' && !iface.internal) {" >> app.js \
    && echo "        ipAddress = iface.address;" >> app.js \
    && echo "        break;" >> app.js \
    && echo "      }" >> app.js \
    && echo "    }" >> app.js \
    && echo "    if (ipAddress) break;" >> app.js \
    && echo "  }" >> app.js \
    && echo "  return ipAddress;" >> app.js \
    && echo "}" >> app.js

# Etap drugi: Tworzenie obrazu NGINX
FROM nginx:latest

# Skopiowanie zbudowanej aplikacji z pierwszego etapu do katalogu html serwera NGINX
COPY --from=builder /app/app.js /usr/share/nginx/html/app.js

# Skopiowanie konfiguracji NGINX
COPY nginx.conf /etc/nginx/nginx.conf

# Ustawienie HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost/ || exit 1

# Eksponowanie portu 80
EXPOSE 80

# Komenda uruchamiająca NGINX w trybie daemon
CMD ["nginx", "-g", "daemon off;"]
