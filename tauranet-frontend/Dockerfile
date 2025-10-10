# Usa una imagen oficial de Node.js como base
FROM node:14

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de dependencias
COPY package*.json ./

# Instala las dependencias
RUN npm install

# Copia el resto del código de la aplicación
COPY . .

# Expone el puerto (ajusta si tu Express escucha en otro puerto)
EXPOSE 8080

# Comando por defecto para iniciar el servidor de desarrollo Vue escuchando en 0.0.0.0
CMD ["npm", "run", "serve", "--", "--host", "0.0.0.0"]