import os
from flask import Flask, request
from flows.trading_flow import trading_flow

app = Flask(__name__)

@app.route("/run", methods=["POST"])
def run_flow():
    # Trigger the Prefect flow
    trading_flow()
    return "Flow triggered", 200

if __name__ == "__main__":
    # For local testing
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
