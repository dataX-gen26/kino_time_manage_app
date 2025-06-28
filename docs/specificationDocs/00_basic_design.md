# 基本設計書

## 1. 概要

本ドキュメントは、「予実管理AIアシスタントアプリ」の全体的な設計思想、アーキテクチャ、そして各機能仕様書へのリンクを定義する。

## 2. 設計思想

- **データ中心**: ユーザーの時間の使い方に関するデータを正確に記録・可視化することを最優先とする。
- **シンプル & 直感的なUI**: 毎日の利用が苦にならないよう、直感的でシンプルな操作性を実現する。
- **AIによる付加価値**: AIによる分析とフィードバックを通じて、単なる記録ツールに留まらない、ユーザーの生産性向上に貢献するインサイトを提供する。

## 3. システムアーキテクチャ

要件定義書に基づき、以下の構成を採用する。

- **フロントエンド**: Vue.js 3で構築されるSPA（Single Page Application）。UIの描画とユーザーインタラクションを担当する。
- **バックエンド**: Ruby on RailsをAPIモードで利用。ビジネスロジック、データベースとの連携、外部API（Google Calendar, Gemini）との通信を担当する。
- **データベース**: MySQLを使用し、全ての永続データを格納する。
- **認証**: Googleアカウントを利用したOAuth 2.0認証。

![System Architecture](https://placehold.jp/150x150.png?text=System+Architecture+Diagram)
*(ここにC4モデルなどを参考に詳細な図を挿入)*

## 4. 機能仕様書一覧

各機能の詳細は、以下の個別仕様書を参照すること。

- **[01_user_authentication.md](./01_user_authentication.md)**: ユーザー認証機能
- **[02_calendar_integration.md](./02_calendar_integration.md)**: Googleカレンダー連携
- **[03_main_ui.md](./03_main_ui.md)**: メイン画面UIとナビゲーション
- **[04_actual_record_management.md](./04_actual_record_management.md)**: 実績の記録・管理機能
- **[05_analysis_dashboard.md](./05_analysis_dashboard.md)**: 分析ダッシュボード機能
- **[06_ai_feedback.md](./06_ai_feedback.md)**: AIによるフィードバック機能
- **[07_database_design.md](./07_database_design.md)**: データベース設計
