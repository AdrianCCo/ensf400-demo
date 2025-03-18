
FROM gradle:7.6-jdk11 

WORKDIR /app

COPY . .

RUN ./gradlew build

ENV PORT=8080

EXPOSE 8080

CMD [ "gradle", "apprun" ]

