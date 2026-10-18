
# Stage 1: Build the Spring Boot application
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# Stage 2: Run the application
FROM eclipse-temurin:17-jre

WORKDIR /app

RUN mkdir -p /app/uploads

COPY --from=builder /app/target/FoodBridge.war /app/FoodBridge.war

EXPOSE 10000

ENTRYPOINT ["sh", "-c", "java -Dserver.address=0.0.0.0 -Dserver.port=${PORT:-10000} -jar /app/FoodBridge.war"]
