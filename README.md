# Magic3サーバ構築

1行コマンドを実行するだけで、即座にMagic3が使える環境ができます。
DockerコンテナベースのMagic3サーバです。

## 前提

サーバにDockerがインストールされていること。
Dockerの簡易インストーラはこちらが利用できます。

https://github.com/czbone/oneliner-docker

## 対象OS

- CentOS Stream 9
- CentOS Stream 8
- Ubuntu 22
- Ubuntu 20
- Ubuntu 18

## ライセンス

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

# 内容

DockerコンテナにMagic3が動作するLEMP環境を構築し、Magic3の最新を配置してインストーラが実行できるところまで構築します。
その後、インストーラを使ってインストール処理を完了させます。

# 使い方

Dockerをインストールしたサーバに`root`でログインし、以下の１行のコマンドをそのままコピーして実行します。

## 実行コマンド

```
curl https://raw.githubusercontent.com/magic3org/oneliner-install-with-docker/master/script/build_env.sh | bash
```

## インストーラ

環境構築後はMagic3のインストーラを実行します。

```
http://[IPアドレス]/admin
```

[インストールドキュメント](http://doc.magic3.org/index.php?%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%2F%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%A9)
