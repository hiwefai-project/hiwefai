# Import the websocket-client package for WebSocket interactions.
import websocket

# Import logging for structured, configurable output.
import logging

# Import json for parsing incoming messages.
import json

# Import Path for loading the shared configuration file.
from pathlib import Path

# Import rel for reconnection and signal handling utilities.
import rel

# ---------------------------

from collections import deque

import requests

import os

import subprocess




# Define the path to the shared JSON configuration file.
CONFIG_PATH = Path(__file__).with_name("config.json")

# Load and return the JSON configuration used by all scripts.
def load_config() -> dict:
    # Open the configuration file with UTF-8 encoding.
    with CONFIG_PATH.open("r", encoding="utf-8") as config_file:
        # Parse the JSON payload into a dictionary.
        return json.load(config_file)

# Load the shared configuration once at startup.
config = load_config()

# Extract the logging configuration section.
logging_config = config.get("logging", {})

# Normalize the configured log level to uppercase.
log_level_name = logging_config.get("level", "INFO").upper()

# Resolve the log level or fall back to INFO.
log_level = getattr(logging, log_level_name, logging.INFO)

# Configure logging with a default INFO level.
logging.basicConfig(level=log_level)

# Create a module-level logger for this client.
logger = logging.getLogger(__name__)

# Extract the download configuration section.
download_config = config.get("download", {})

# Extract the WebSocket client configuration section.
client_config = config.get("websocket_client", {})

# Define the WebSocket URL for subscribing to updates.
url_ws = client_config.get("url", "ws://localhost:8765/subscribe")

# Define the product type to filter on for logging.
product_type = client_config.get("product_type", "VMI")

# Log a startup banner so operators know the client is running.
logger.info("Weather Radar Websocket Client")

path_inference_input = download_config.get("path_inference_input", "/data/infer/input")

queue = deque(maxlen=18)

# Handle incoming messages from the server.
def on_message(ws, message):

    # Parse the JSON payload into a Python dictionary.
    json_message = json.loads(message)

    # Check that the message contains a product type field.
    if "productType" in json_message:

        # Focus on the configured product type of interest.
        if json_message["productType"] == product_type:

            # File path associated with the update.
            path_data = json_message["file"]

            # File name associated with the update.
            filename_data = os.path.basename(path_data)

            # Url associated with the update.
            url_data = json_message["url"]
            logger.info(f"url_data: {url_data}")

            #queue.append(filename_data)
            queue.append(url_data)
            logger.info(f"len queue : {len(queue)}")

            logger.info(f"queue list : {list(queue)}")
            if len(queue) == queue.maxlen:

                logger.info(f"quque: {list(queue)}")

                logger.info("CALL WORKFLOW")

                queue_list = json.loads(str(list(queue)).replace("'", '"'))
                #subprocess.run(["python3", "app.py", "--queue", f"{list(queue)}"])
                subprocess.run(["python3", "app.py", "--queue", " ".join(queue_list)])
    

# Handle errors raised by the websocket-client library.
def on_error(wsock, error):

    # Log errors at error severity to highlight issues.
    logger.error(error)

# Handle the close event from the server.
def on_close(wsock, close_status_code, close_msg):

    # Use debug-level logging for close events to reduce noise.
    logger.debug("### closed ###")

# Handle the open event when the connection is established.
def on_open(wsock):

    # Use debug-level logging for connection establishment details.
    logger.debug("Opened connection")

# Run the client only when the script is executed directly.
if __name__ == "__main__":

    #if not os.path.isdir(path_inference_input):
    #    os.mkdir(path_inference_input)


    # Enable this for verbose WebSocket tracing.
    #websocket.enableTrace(True)

    # Create the WebSocketApp with handlers for each event.
    wsock = websocket.WebSocketApp(
        url_ws,
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close,
    )

    # Run the event loop with auto-reconnect behavior.
    wsock.run_forever(dispatcher=rel, reconnect=5)

    # Register a signal handler to terminate on Ctrl+C.
    rel.signal(2, rel.abort)

    # Enter the dispatcher loop to process events.
    rel.dispatch()