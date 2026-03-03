# Dockerfile para el servicio ETL

# Usa una imagen base ligera de Python
FROM python:3.11-slim

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Instala dependencias necesarias (libpq-dev para psycopg2)
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copia el script ETL y el archivo de requisitos si lo tienes
COPY etl_extractor.py .
RUN pip install requests sqlalchemy psycopg2-binary

# Comando para ejecutar el script cuando se inicia el contenedor
CMD ["python", "etl_extractor.py"]
