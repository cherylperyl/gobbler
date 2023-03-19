import pika

exchangename = "newposts"
queue_name = "newposts"
exchangetype = "topic"


def setup(hostname, port):

    global exchangename, queue_name, exchangetype

    # connect to the broker and set up a communication channel in the connection
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(
            host=hostname,
            port=port,
            # these parameters to prolong the expiration time (in seconds)
            # of the connection
            heartbeat=3600,  # when server down
            blocked_connection_timeout=3600,  # when server busy
        ))

    channel = connection.channel()

    # Set up the exchange if the exchange doesn't exist
    channel.exchange_declare(
        exchange=exchangename,
        exchange_type=exchangetype,  # - use a 'topic' exchange to enable interaction
        durable=True  # 'durable' makes the exchange survive broker restarts
    )

    # delcare/ create Error queue
    channel.queue_declare(queue=queue_name, durable=True)  # 'durable' makes the queue survive broker restarts

    # bind/ add Error queue to exchange
    channel.queue_bind(
        exchange=exchangename,
        queue=queue_name,
        routing_key='#'  # any routing_key would be matched
    )

    return channel
