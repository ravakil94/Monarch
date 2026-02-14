FROM rust:1.83-alpine AS build
RUN apk add --no-cache musl-dev
WORKDIR /workspace
COPY Cargo.toml Cargo.lock* ./
COPY libs/common-rust/ libs/common-rust/
ARG SERVICE_NAME
COPY services/rust/${SERVICE_NAME}/ services/rust/${SERVICE_NAME}/
RUN cargo build --release -p ${SERVICE_NAME}

FROM alpine:3.19
WORKDIR /app
ARG SERVICE_NAME
COPY --from=build /workspace/target/release/${SERVICE_NAME} ./service
EXPOSE 8080
ENTRYPOINT ["./service"]
