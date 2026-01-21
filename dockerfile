FROM openjdk:17-jdk-slim
WORKDIR /app

# Copy the built JAR from target
COPY target/*.jar app.jar

# Expose Spring Boot default port
EXPOSE 8080

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]