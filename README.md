# kafka_docker
実験用のKafkaをdocker-composeで構築します。

## 構成  
- KRiftを使ってKafkaを構築しています。
  - alpne:latest
  - OpenJDK17-jre
- ボリュームの構成
  - kafka_docker_logs: /tmp/kafka-logs
  - kafka_docker_combined-logs: /tmp/kraft-combined-logs
- Kafkaインストールフォルダ
  - /usr/kafka
- ポート
  - 9092(tcp)
  - 9093(tcp)
- ENTORYPOINT
  - /usr/kafka/bin/run.sh


```
