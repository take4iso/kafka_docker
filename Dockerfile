FROM alpine:latest
EXPOSE 9092
EXPOSE 9093

# KAFKA_CLUSTER_ID はUUIDにする必要がある #KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
ARG KAFKA_CLUSTER_ID=KafkaClusterID00000000
ARG NODE_ID=1
ARG KAFKA_VERSION=3.5.1
ARG SCALA_VERSION=2.13

RUN apk update && \
    apk upgrade && \
    apk add --no-cache bash && \
    apk add --no-cache openjdk17-jre && \
    apk add --no-cache wget && \
    apk add --no-cache sed

WORKDIR /usr
RUN wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    tar -xzf kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    rm kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz && \
    mv kafka_${SCALA_VERSION}-${KAFKA_VERSION} kafka

#実行スクリプトを作成
RUN echo "#!/bin/bash" > /usr/kafka/bin/run.sh && \
    echo "echo \"Starting Kafka\"" >> /usr/kafka/bin/run.sh && \
    echo "echo \"KAFKA_CLUSTER_ID=${KAFKA_CLUSTER_ID}\"" >> /usr/kafka/bin/run.sh && \
    echo "cd /usr/kafka" >> /usr/kafka/bin/run.sh && \
    echo "bin/kafka-storage.sh format -t ${KAFKA_CLUSTER_ID} -c /usr/kafka/config/kraft/server.properties" >> /usr/kafka/bin/run.sh && \
    echo "bin/kafka-server-start.sh config/kraft/server.properties" >> /usr/kafka/bin/run.sh && \
    chmod +x /usr/kafka/bin/run.sh
#改行コードをLFに変換
#RUN sed -i -e 's/\r//' /usr/kafka/bin/run.sh

#configファイルをバックアップ
RUN cp /usr/kafka/config/kraft/server.properties /usr/kafka/config/kraft/server.properties.org

#configファイルを書き換え　NODE_IDを指定
RUN sed -i -e "s/^node.id=1/node.id=${NODE_ID}/g" /usr/kafka/config/kraft/server.properties && \
    sed -i -e "s/^controller.quorum.voters=1@localhost:9093/controller.quorum.voters=${NODE_ID}@localhost:9093/g" /usr/kafka/config/kraft/server.properties

ENTRYPOINT ["/bin/sh", "-c", "/usr/kafka/bin/run.sh"]
