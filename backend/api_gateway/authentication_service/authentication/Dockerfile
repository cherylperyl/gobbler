FROM maven:3.8.4-openjdk-17 AS builder
WORKDIR /app
COPY ./src /app/src
COPY pom.xml /app/pom.xml

RUN mvn clean package

FROM openjdk:17-jdk-alpine

COPY --from=builder /app/target/authentication-1.0.0.jar /app/authentication.jar

ENTRYPOINT ["java", "-jar", "/app/authentication.jar"]
