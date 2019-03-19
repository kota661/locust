# Locust

Locust をIKS上にデプロイして負荷テスト


## Locustとは？
  https://locust.io/

Python で書かれた分散負荷試験ツールです。
  * pythonでtaskを記載
  * GUIで実行回数、スレッド数を指定しテスト
  * 結果もGUIで確認可能
 

## 手順
1. docker image の作成とPush
   
   ```
   DOCKER_REGISTRY=kota661
   git clone git@github.com:locustio/locust.git
   cd locust
   docker builc -t kota661/locust:latest .
   docker login -p $PASSOWRD -u $USER
   docker push kota661/locust:latest
   ```

2. Localで実行してみる

   ```
   docker run -d -p 8089:8089 --name locust kota661/locust:latest -f locust_files/tasks_index.py --host=http://example.com 
   ```

   ブラウザで **http://localhost:8089** を開きます

   * Number of users to simulate
      - 最大時にくる毎秒のリクエスト数
   * Hatch rate (users spawned/second)
      - 1秒間にどれくらいのペースでクライアント数を増やすか
   * 例
     * 10台(毎秒10リクエスト)の同時アクセスに耐えれるかを見たい
       * Number of users to simulate: 10
       * Hatch rate: 10
     * 1000台の同時アクセスに耐えられるかを見るため毎秒10台ずつ増やして見ていきたい
       * Number of users to simulate: 1000
       * Hatch rate: 10

    ```
    # 停止と削除
    docker stop locust
    docker rm locust
    ```

3. Kubernetesの設定ファイルを作成

   予めdeploymentとserviceのyamlを作成してあります
   * configmapにて負荷テストのサイトURLと、マスターのURLを定義
   * deployment.yamlではそれぞれlocustの実行時引数にてモードを指定（master/slave)
   * master <-> slave通信用に5557、5558を利用しているようなのでserviceの作成
   * 外部からダッシュボードにアクセスするためにLBにて8089を開放

   設定変更箇所 (configmap.yaml)
   ```: configmap.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: locust-config
      labels:
        app: locust
    data:
      master_host: locust-master
      target_host: http://example.com　　＜　このURLを負荷テストのURLに変更してください
   ```

4. Deploy
  ```
  kubectl apply -f configmap.yaml
  kubectl apply -f master-deployment.yaml
  kubectl apply -f master-service.yaml
  kubectl apply -f slave-deployment.yaml
  ```

5. GUIにアクセスしてテスト


## お掃除
```
kubectl delete deploy,svc,configmap -l app=locust
```


## 参考サイト
* https://qiita.com/yamionp/items/17ffcc465272ad83c490
* OfficialのDockerImage（何故か空。。）
  * https://hub.docker.com/r/locustio/locust