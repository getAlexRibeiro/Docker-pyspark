# Usa una imagen base estable
FROM python:3.9-bookworm

# Configura variables de entorno para PySpark
ENV PYSPARK_VERSION=3.5.0
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Agrega logs intermedios para el proceso de instalación
RUN echo "=== Actualizando lista de paquetes ===" && \
    apt-get update && \
    echo "=== Lista de paquetes actualizada ===" && \
    echo "=== Instalando dependencias ===" && \
    apt-get install -y openjdk-11-jdk-headless curl || \
    (echo "Error al instalar dependencias. Intentando alternativas..." && \
    apt-get install -y openjdk-17-jdk-headless curl) && \
    echo "=== Dependencias instaladas correctamente ===" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "=== Instalación de Java y limpieza completada ==="

# Configura JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Descarga e instala Apache Spark con logs
RUN echo "=== Descargando Apache Spark ===" && \
    curl -O https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz || \
    (echo "Error: No se pudo descargar Apache Spark" && exit 1) && \
    echo "=== Verificando si el archivo descargado es válido ===" && \
    if grep -q "<html>" spark-3.5.0-bin-hadoop3.tgz; then \
        echo "Error: Se descargó un archivo HTML en lugar del archivo esperado" && exit 1; \
    fi && \
    echo "=== Archivo descargado correctamente ===" && \
    echo "=== Extrayendo Apache Spark ===" && \
    tar -xvzf spark-3.5.0-bin-hadoop3.tgz -C /opt || \
    (echo "Error: No se pudo extraer Apache Spark" && exit 1) && \
    echo "=== Extracción de Apache Spark completada ===" && \
    echo "=== Configurando directorios de Apache Spark ===" && \
    mv /opt/spark-3.5.0-bin-hadoop3 $SPARK_HOME && \
    echo "=== Directorio de Apache Spark configurado ===" && \
    rm spark-3.5.0-bin-hadoop3.tgz && \
    echo "=== Archivo de Apache Spark eliminado ===" && \
    echo "=== Configuración de Apache Spark completada ==="

# Instala PySpark y otros paquetes necesarios con logs
RUN echo "=== Instalando paquetes de Python ===" && \
    pip install pyspark pandas numpy && \
    echo "=== Paquetes de Python instalados correctamente ==="

# Crea un directorio de trabajo
WORKDIR /app

# Copia los archivos del proyecto (si es necesario)
COPY . /app

# Especifica el comando predeterminado
CMD ["python"]
