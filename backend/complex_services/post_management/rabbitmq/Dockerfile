FROM rabbitmq:3.9.12-management-alpine

USER root

RUN chown -R rabbitmq:rabbitmq /var/lib/rabbitmq /var/log/rabbitmq && \
    chmod -R 777 /var/lib/rabbitmq /var/log/rabbitmq

USER rabbitmq
