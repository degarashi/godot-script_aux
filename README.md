![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)

godot-script_aux
---

# 概要
自分用に組んだエディタ拡張。<br>
(現状はシーンのノードをスクリプトに@onreadyの形で追加する機能のみ)<br>
Godot内のエディタではドラッグアンドドロップで出来るけど外部エディタの場合はそうも行かないので作ってみた。

# インストール
godotプロジェクトディレクトリのaddonsに置く

# 使い方
<img src="./images/context_menu.png" alt="usage image"/>
ノードツリーでノードを右クリックすると、スクリプトにメンバ変数が宣言される。
<img src="./images/result.png" alt="usage image2"/>
宣言される位置は固定なので各自なんとかしてください。
