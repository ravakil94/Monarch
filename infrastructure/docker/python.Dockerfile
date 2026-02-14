FROM python:3.13-slim AS build
WORKDIR /app
ARG SERVICE_NAME
COPY services/python/${SERVICE_NAME}/pyproject.toml ./
RUN pip install --no-cache-dir poetry && poetry export -f requirements.txt -o requirements.txt --without-hashes 2>/dev/null || pip install --no-cache-dir .
COPY services/python/${SERVICE_NAME}/ ./

FROM python:3.13-slim
WORKDIR /app
COPY --from=build /app ./
RUN pip install --no-cache-dir -r requirements.txt 2>/dev/null || pip install --no-cache-dir .
EXPOSE 8080
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
