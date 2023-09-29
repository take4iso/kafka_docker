FROM alpine:latest
EXPOSE 9092
EXPOSE 9093

ENV KAFKA_VERSION=3.5.1
ENV SCALA_VERSION=2.13
# KAFKA_CLUSTER_ID はUUIDにする必要がある #KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
ENV KAFKA_CLUSTER_ID=KafkaClusterID12345678
ENV NODE_ID=1


RUN apk add --no-cache wget bash openjdk17-jre
WORKDIR /usr
RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    mv kafka_${SCALA_VERSION}-${KAFKA_VERSION} kafka

COPY run.sh /usr/kafka/bin/run.sh
RUN chmod +x /usr/kafka/bin/run.sh

#configファイルをバックアップ
RUN cp /usr/kafka/config/kraft/server.properties /usr/kafka/config/kraft/server.properties.org

#configファイルを書き換え　NODE_IDを指定
RUN sed -i -e "s/^node.id=1/node.id=${NODE_ID}/g" /usr/kafka/config/kraft/server.properties && \
    sed -i -e "s/^controller.quorum.voters=1@localhost:9093/controller.quorum.voters=${NODE_ID}@localhost:9093/g" /usr/kafka/config/kraft/server.properties

ENTRYPOINT ["/bin/sh", "-c", "/usr/kafka/bin/run.sh"]
