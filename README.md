# transcribe-slack-bot
 - Slackに投稿された音声データを自動で文字起こししてテキストで返すbot
 - 概要は [Qiita](https://qiita.com/bSRATulen2N90kL/items/f061a6a1a604dfbf989d) に記載しています

## 構成

## 準備
 - AWSアカウント
 - Slackアカウント
 - Serverless Framework (https://serverless.com/)
 - Docker

### Slack App の作成
1. https://api.slack.com/ で新規にアプリを作成します。
2. OAuth & Permissions のページから Bot Token Scopes として`channels:history`,`chat:write`,`files:read`,`files:write` を追加。
3. App Home のページから How Your App Displays として Display Name と Default Name を入力をします。
4. OAuth & Permissions のページから Install App to Warkspace のボタンを押して、 Bot User OAuth Access Token の値を取得します。

### AWSサービスのデプロイ方法

```bash
$ git clone git@github.com:creamstew/transcribe-slack-bot.git
```

```bash
$ cd transcribe-slack-bot
```

```bash
$ npm install
```

```bash
$ cp config/setting_sample.yml config/setting.yml
```

`config/setting.yml` で下記の値を入力します。

| Key | Value |
|------|-------|
| `input_s3_bucket_name` | S3 バケット名（例：input-bucket） |
| `output_s3_bucket_name` | S3 バケット名（例：output-bucket） |
| `aws_region` | AWS リージョン（例：ap-northeast-1） |
| `slack_oauth_token` | Bot User OAuth Access Token の値 |
| `slack_channel` | 文字起こししたテキストを投稿するSlackChannel の値（例：#transcribe） |
※ S3のバケットネームが既に誰かが使用している名前だとデプロイ時にエラーとなります。

```bash
$ docker run --rm -it -v $PWD:/var/gem_build -w /var/gem_build lambci/lambda:build-ruby2.5 bundle install --path vendor/bundle
```
※LambdaでNative_Extensionsを用いたgemを使いたい場合はLambdaの実行環境と同等環境でbundle installする必要があるため。

```bash
$ serverless deploy
```

### Slack App の設定

1. API Gateway の URL を取得します。

> URL は https://xxxxxxxx.amazonaws.com/dev/transcribe のようになります。

2. Event Subscriptions のページを開き、Enable Events を On にします。
3. Request URL に API Gateway の URL を入力して Save します。（URLが合っていれば、Verified となります）
4. Subscribe to Bot Events で `messages.channels` を追加します。
5. 指定したワークスペースで `setting.yml` で記載したチャンネルに Bot を参加させて使用可能になります。
6. 参加させたチャンネルで音声・動画ファイルを投稿してください。時間差で文字起こしされたテキストが返ってきます。

### 注意点

 - AWSのサービスを使用するため料金がかかります。ご使用は自己責任でお願いします。
 - 文字起こしの価格等は(公式サイト)[https://aws.amazon.com/jp/transcribe/]をご覧ください。