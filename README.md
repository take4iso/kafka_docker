# kafka_docker
実験用のKafkaをdocker-composeで構築します。

## 構成  
- KRiftを使ってKafkaを構築しています。
  - alpne:latest
  - OpenJDK17-jre
- ボリュームの構成
  - kafka_docker_logs: /tmp/kafka-logs
  - kafka_docker_combined-logs: /tmp/kafka-combined-logs
- Kafkaインストールフォルダ
  - /usr/kafka
- ポート
  - 9092(tcp)
  - 9093(tcp)
- ENTORYPOINT
  - /usr/kafka/bin/run.sh

## エントリーポイントについて
Dockerfileで、run.shを作成しています。以下の内容です。KAFKA_CLUSTER_IDは.envファイルから指定しています。
```sh
#!/bin/bash
cd /usr/kafka
bin/kafka-storage.sh format -t ${KAFKA_CLUSTER_ID} -c /usr/kafka/config/kraft/server.properties
bin/kafka-server-start.sh config/kraft/server.properties
```

## 設定ファイルについて
Dockerfileで、Kafkaの設定ファイルのconfig/kraft/server.propertiesを編集しています。以下の内容です。NODE_IDは.envファイルから指定しています。
```sh
node.id=${NODE_ID}
controller.quorum.voters=${NODE_ID}@localhost:9093
```
