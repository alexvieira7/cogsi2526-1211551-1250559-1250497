# H2 database server container
FROM eclipse-temurin:17-jre

WORKDIR /opt/h2

# Install tools and download H2
RUN apt-get update && \
    apt-get install -y wget netcat-openbsd && \
    rm -rf /var/lib/apt/lists/* && \
    wget -q -O h2.jar https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar

# Directory where the DB files will live (will be a volume)
RUN mkdir -p /opt/h2-data

VOLUME ["/opt/h2-data"]

EXPOSE 9092

# Start H2 in TCP server mode, storing data under /opt/h2-data
CMD ["java", "-cp", "h2.jar", "org.h2.tools.Server",
     "-tcp", "-tcpAllowOthers",
     "-tcpPort", "9092",
     "-baseDir", "/opt/h2-data"]

