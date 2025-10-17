# ---- Stage 1: build ----
FROM gradle:8.7-jdk17-alpine AS build
WORKDIR /workspace

# Copier le wrapper/dépendances d'abord pour profiter du cache
COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle settings.gradle ./
RUN chmod +x gradlew

# Télécharger les dépendances (cache Gradle)
RUN ./gradlew --no-daemon dependencies || true

# Copier le code et builder le JAR
COPY src src
RUN ./gradlew --no-daemon bootJar

# ---- Stage 2: runtime ----
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# Copie le JAR construit
COPY --from=build /workspace/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java","-XX:MaxRAMPercentage=75.0","-jar","/app/app.jar"]
