# Schedule Sprout

Schedule Sproutは、複数のカレンダーを共有しながらスケジュールを管理できるアプリケーションです。新しい計画やアイディアが「芽吹く」場所というコンセプトから、この名が名付けられました。

![ScheduleSprout Logo](https://github.com/at-construct/at_calperapp/assets/53667957/ae709d2e-bb89-4c44-bba4-1de151504390)

## 特徴

- 複数のカレンダー共有
- スケジュールのリアルタイム管理
- 特定のユーザーグループや目的に最適化された機能
- スマートデバイス対応のユーザーフレンドリーなデザイン

アプリはこちらで体験できます: [Schedule Sprout on Heroku](https://atcalperapp.herokuapp.com)

## 利用方法

テストアカウントを使用してログインできます。詳細は、アプリのログインページを参照してください。

## 使用技術

### 言語

- フロントエンド: HTML/CSS/JavaScript
- バックエンド: Ruby 3.0.3

### フレームワーク

- Vue.js: version 2.6.12
- Vuetify: version 2.5.0
- Ruby on Rails: version 6.1.7.3

### その他の重要な技術スタック

- バンドラー: Bundler version 2.2.3
- データベース: psql (PostgreSQL) 14.7
- デプロイ: Heroku, Node.js, npm, yarn など
- バージョン管理: rbenv, nodenv
- 仮想コンテナ: Docker version 20.10.21
- テスト: RSpec version 3.12

完全な技術スタックのリストは、上記を参照してください。

## 開発ドキュメント
- **ER図**: [draw.ioで見る](https://drive.google.com/file/d/16WPz3Gy2zRo2jvZ1gurGjPuHZK5V9D_e/view?usp=sharing)

![スクリーンショット 2023-10-22 7 59 28](https://github.com/at-construct/at_calperapp/assets/53667957/45940dca-2b4f-464f-a8dc-790406e4d146)


  - **ワイヤーフレーム**: [Figmaで見る](https://www.figma.com/file/9sbh0YsDvY7A1g6dT118Wg/CalApp-FrameWork?type=design&node-id=0%3A1&mode=design&t=knC9uxerccmTCOUC-1)

![スクリーンショット 2023-10-22 8 04 26](https://github.com/at-construct/at_calperapp/assets/53667957/5bf26daf-3a30-46fc-92ed-2e9c8c0ee2bb)

## 機能一覧

- ログイン/サインアップ機能: ユーザーがアカウントを作成し、ログインできる機能。
- カレンダーへの参加機能:ユーザー登録の際、所属するカレンダーを選べる機能。
- カレンダービュー: 日、週、月のビューでスケジュールや予定を確認できるカレンダー機能。
- カレンダーの作成: 新しいカレンダーを作成できる機能。
- カレンダーの編集: 既存のカレンダーの情報や設定を変更できる機能。
- カレンダーの削除: 既存のカレンダーを削除できる機能。
- イベントの追加・編集: 日付や時間を指定してイベントを追加・編集できる機能。
- 他のユーザーをイベントに追加: 予定やイベントに他のユーザーを招待や追加できる機能。
- 重複チェック & アラート機能: ユーザーや参加者の予定が重複していた場合、警告やアラートを出す機能。
- イベントの詳細: イベントの詳細情報を表示できるモーダルウィンドウ。
- イベントの削除: イベントを削除する機能。
- 色のカスタマイズ: イベントのカテゴリーや重要度に応じて色をカスタマイズできる機能。
- 時間の指定: 特定の時間帯にイベントを追加する際のスライダーや時刻ピッカー。
- 通知機能: 作成された予定に参加者として追加されている場合、参加者に通知が送られる機能。
- 通知の既読: 既読した通知を判別する機能。





