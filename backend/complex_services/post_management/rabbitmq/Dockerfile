FROM rabbitmq:3.11.17-management-alpine

USER root

RUN chown -R rabbitmq:rabbitmq /var/lib/rabbitmq /var/log/rabbitmq && \
    chmod -R 777 /var/lib/rabbitmq /var/log/rabbitmq

USER rabbitmq
