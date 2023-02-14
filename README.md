# Magic3サーバ構築

DockerコンテナベースのMagic3サーバ環境を構築します。

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

DockerコンテナにMagic3が動作するLEMP環境を構築し、Magic3の最新を配置してインストーラが実行できるところまで準備を整えます。

# 使い方

Dockerをインストールしたサーバに`root`でログインし、以下の１行のコマンドをそのままコピーして実行します。

## 実行コマンド

```
curl https://raw.githubusercontent.com/magic3org/oneliner-install-with-docker/master/script/build_env.sh | bash
```