FROM python:3.12-slim AS builder

WORKDIR /build

RUN pip install --upgrade pip --no-cache-dir

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.12-slim AS runtime

WORKDIR /app

COPY --from=builder /install /usr/local

COPY . .

EXPOSE 8080

CMD ["sh", "-c", "python -m alembic upgrade head && python -m uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}"]
