# Build Stage
FROM maven:3-eclipse-temurin-25 AS build
WORKDIR /app

# Copy Parent and BOM
COPY pom.xml .
COPY dependencies-bom/pom.xml dependencies-bom/

# Copy Shared Modules
COPY common-core common-core
COPY common-web common-web
COPY common-security common-security

# Copy Target Service
COPY profile-service profile-service

# Build
RUN mvn clean package -pl profile-service -am -DskipTests

# Run Stage
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=build /app/profile-service/target/*.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
