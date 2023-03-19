#!/usr/bin/env python3
# The above shebang (#!) operator tells Unix-like environments
# to run this file as a python3 script

# This file shows an implementation example of how to consume from the New Post Queue

import json
import os

from app import amqp_setup
from app.amqp_setup import queue_name, exchangename

monitorBindingKey = '#'


def receivePost():
    channel = amqp_setup.setup("localhost", 5672)

    # set up a consumer and start to wait for coming messages
    channel.basic_consume(
        queue=queue_name,
        on_message_callback=callback,
        auto_ack=True
    )
    # an implicit loop waiting to receive messages;
    # it doesn't exit by default. Use Ctrl+C in the command window to terminate it.
    channel.start_consuming()


def callback(ch, method, properties, body):
    """
    required signature for the callback; no return
    """
    print("\nReceived a new post by " + __file__)
    processPost(body)
    print()  # print a new line feed


def processPost(post):
    print("Printing the Post details:")
    try:
        error = json.loads(post)
        print("--JSON:", error)
    except Exception as e:
        print("--NOT JSON:", e)
        print("--DATA:", post)
    print()


if __name__ == "__main__":
    print("\nThis is " + os.path.basename(__file__), end='')
    print(f": monitoring routing key '{monitorBindingKey}' in exchange '{exchangename}' ...")
    receivePost()
