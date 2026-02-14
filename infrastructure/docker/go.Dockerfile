FROM golang:1.23-alpine AS build
WORKDIR /workspace
COPY go.work ./
COPY libs/common-go/ libs/common-go/
ARG SERVICE_NAME
COPY services/go/${SERVICE_NAME}/ services/go/${SERVICE_NAME}/
RUN cd services/go/${SERVICE_NAME} && go build -o /app/service ./cmd/

FROM alpine:3.19
WORKDIR /app
COPY --from=build /app/service ./service
EXPOSE 8080
ENTRYPOINT ["./service"]
