FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /workspace
COPY settings.gradle.kts ./
COPY libs/common-java/ libs/common-java/
COPY libs/db-migrations/ libs/db-migrations/
ARG SERVICE_NAME
COPY services/java/${SERVICE_NAME}/ services/java/${SERVICE_NAME}/
RUN cd services/java/${SERVICE_NAME} && ../../../gradlew bootJar --no-daemon

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
ARG SERVICE_NAME
COPY --from=build /workspace/services/java/${SERVICE_NAME}/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
