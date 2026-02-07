# Build Stage
FROM maven:3-eclipse-temurin-25 AS build
WORKDIR /app

# Copy Parent and BOM
COPY pom.xml .
COPY dependencies-bom/pom.xml dependencies-bom/

# Copy Target Service
COPY gateway gateway

# Build
RUN mvn clean package -pl gateway -am -DskipTests

# Run Stage
FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=build /app/gateway/target/*.jar app.jar
EXPOSE 8888
ENTRYPOINT ["java", "-jar", "app.jar"]
