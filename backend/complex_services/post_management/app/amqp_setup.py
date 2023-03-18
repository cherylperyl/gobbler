import pika


def setup():
    hostname = "post-management-rabbitmq"  # default hostname
    port = 5672  # default port
    exchangename = "new_posts"
    queue_name = "Notification"
    exchangetype = "topic"

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

    return connection, channel


# def check_setup():
#     """
#     This function in this module sets up a connection and a channel to a local
#     AMQP broker, and declares a 'topic' exchange to be used by the
#     microservices in the solution.
#     """
#     # The shared connection and channel created when the module is imported
#     # may be expired, timed out, disconnected by the broker or a client;
#     # - re-establish the connection/channel is they have been closed
#     global connection, channel, hostname, port, exchangename, exchangetype

#     if not is_connection_open(connection):
#         connection = pika.BlockingConnection(pika.ConnectionParameters(
#             host=hostname,
#             port=port,
#             heartbeat=3600,
#             blocked_connection_timeout=3600))

#     if channel.is_closed:
#         channel = connection.channel()
#         channel.exchange_declare(
#             exchange=exchangename,
#             exchange_type=exchangetype,
#             durable=True
#         )

#         # when you drop the exchange the queues wont be dropped but the
#         # bindings to it will be dropped so need to rebind the queues
#         channel.queue_bind(
#             exchange=exchangename,
#             queue=queue_name,
#             routing_key='#'
#         )


# def is_connection_open(connection):
#     # For a BlockingConnection in AMQP clients,
#     # when an exception happens when an action is performed,
#     # it likely indicates a broken connection.
#     # So, the code below actively calls a method in the 'connection' to check if an exception happens
#     try:
#         connection.process_data_events()
#         return True
#     except pika.exceptions.AMQPError as e:
#         print("AMQP Error:", e)
#         print("...creating a new connection.")
#         return False
