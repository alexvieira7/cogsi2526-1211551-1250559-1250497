FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY spring-example/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
