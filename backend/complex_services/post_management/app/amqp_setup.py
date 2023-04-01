import pika

amqp_configs = {
    "newpost": {
        "exchangename": "newpost",
        "queue_name": "newpost",
        "exchangetype": "topic",
    },
    "updatepost": {
        "exchangename": "updatepost",
        "queue_name": "updatepost",
        "exchangetype": "topic",
    },
    "deletepost": {
        "exchangename": "deletepost",
        "queue_name": "deletepost",
        "exchangetype": "topic",
    },
}


def setup(hostname, port):
    # connect to the broker and set up a communication channel in the connection
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(
            host=hostname,
            port=port,
            # these parameters to prolong the expiration time (in seconds)
            # of the connection
            heartbeat=3600,  # when server down
            blocked_connection_timeout=3600,  # when server busy
        )
    )

    channel = connection.channel()

    # Set up the exchange if the exchange doesn't exist
    for _, amqp_config in amqp_configs.items():
        channel.exchange_declare(
            exchange=amqp_config["exchangename"],
            exchange_type=amqp_config[
                "exchangetype"
            ],  # - use a 'topic' exchange to enable interaction
            durable=True,  # 'durable' makes the exchange survive broker restarts
        )

        # delcare/ create Error queue
        channel.queue_declare(queue=amqp_config["queue_name"], durable=True)

        # bind/ add Error queue to exchange
        channel.queue_bind(
            exchange=amqp_config["exchangename"],
            queue=amqp_config["queue_name"],
            routing_key="#",  # any routing_key would be matched
        )

    return channel
