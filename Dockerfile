# -------- Stage 1: Build the Spring Boot app --------

# Use a Maven image to build the project
FROM maven:3.9-eclipse-temurin-17 AS build

# Set the working directory
WORKDIR /app

# Copy the pom.xml 
COPY pom.xml .

# download dependencies
RUN mvn dependency:go-offline

# Copy the source code
COPY src ./src

# Package the application (skip tests for speed)
RUN mvn clean package -DskipTests

# generate wrapper
RUN mvn -N io.takari:maven:wrapper


# Make the Maven wrapper executable
RUN chmod +x mvnw

# -------- Stage 2: Run the Spring Boot app --------

# Use a lightweight Java runtime image
FROM eclipse-temurin:17-jdk-alpine

# inlcude bash
RUN apk add --no-cache bash

# Set the working directory
WORKDIR /app

# Copy the packaged JAR from the build stage
COPY --from=build /app/target/*.jar app.jar

# Copy maven wrapper from the build stage
COPY --from=build /app/mvnw mvnw
COPY --from=build /app/.mvn .mvn

# Expose port (typically 8080 for Spring Boot)
EXPOSE 8080

# Run the JAR directly (recommended for production)
ENTRYPOINT ["java", "-jar", "app.jar"]