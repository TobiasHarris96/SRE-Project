from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest
import random
import time

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "app_requests_total",
    "Total number of requests",
    ["method", "endpoint", "status"]
)

REQUEST_LATENCY = Histogram(
    "app_request_latency_seconds",
    "Application request latency"
)

ERROR_COUNT = Counter(
    "app_errors_total",
    "Total application errors"
)


@app.route("/")
@REQUEST_LATENCY.time()
def home():
    REQUEST_COUNT.labels("GET", "/", "200").inc()

    return jsonify({
        "application": "SRE Observability Demo",
        "status": "running"
    })


@app.route("/health")
def health():
    REQUEST_COUNT.labels("GET", "/health", "200").inc()

    return jsonify({
        "status": "healthy"
    })


@app.route("/simulate-error")
def simulate_error():
    ERROR_COUNT.inc()
    REQUEST_COUNT.labels(
        "GET",
        "/simulate-error",
        "500"
    ).inc()

    return jsonify({
        "error": "Simulated application failure"
    }), 500


@app.route("/simulate-latency")
def simulate_latency():
    delay = random.uniform(1, 3)
    time.sleep(delay)

    REQUEST_COUNT.labels(
        "GET",
        "/simulate-latency",
        "200"
    ).inc()

    return jsonify({
        "latency_seconds": delay
    })


@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {
        "Content-Type": "text/plain"
    }


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000
    )
