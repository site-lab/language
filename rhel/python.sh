#!/bin/sh

#rootユーザーで実行 or sudo権限ユーザー

<<COMMENT
作成者：サイトラボ
URL：https://www.site-lab.jp/
URL：https://buildree.com/

Pythonのインストールを行います

COMMENT

echo ""

start_message(){
echo ""
echo "======================開始======================"
echo ""
}

end_message(){
echo ""
echo "======================完了======================"
echo ""
}

#unicorn7か確認
if [ -e /etc/redhat-release ]; then
    DIST="redhat"
    DIST_VER=`cat /etc/redhat-release | sed -e "s/.*\s\([0-9]\)\..*/\1/"`

    if [ $DIST = "redhat" ];then
      if [ $DIST_VER = "8" -o $DIST_VER = "9" ];then
        #EPELリポジトリのインストール
        start_message
        dnf remove -y epel-release
        dnf -y install epel-release
        end_message

        #gitなど必要な物をインストール
        start_message
        dnf install -y gcc gcc-c++ make git  zlib-devel readline-devel sqlite-devel bzip2-devel libffi-devel perl perl-Test-Simple perl-Test-Harness openssl-devel


        # dnf updateを実行
        start_message
        echo "dnf updateを実行します"
        echo ""
        wget wget https://buildree.com/download/common/system/update.sh
        source ./update.sh
        end_message

        echo "pythonのインストールをします"
        wget wget https://buildree.com/download/common/system/pyenv.sh
        source ./pyenv.sh


        #ユーザー作成
        echo "pythonのインストールをします"
        wget wget https://buildree.com/download/common/user/centosonly.sh
        source ./centosonly.sh

        #コピー作成
        cp /root/pass.txt /home/unicorn/
        chown -R unicorn:nobody /home/unicorn
        end_message



        #サンプルファイル作成
        start_message
        cat > /home/unicorn/hello.py <<'EOF'
#coding:UTF-8

print ("こんにちは世界！")
EOF
        end_message

        #実行
        start_message
        echo "実行します"
        echo "python hello.py"
        su -l unicorn -c "python hello.py"
        #python hello.py
        end_message

        #ファイルの削除
        rm -rf pyenv.sh centosonly.sh update.sh

        cat <<EOF
-----------------
Pythonのみのインストールとなります。ブラウザなどの連携はしておりません。
デーモン化などで使う場合にお勧めします
-----------------
パスワードのテキストファイルは、rootとunicornと両方にあります
-----------------
EOF
        echo "unicornユーザーのパスワードは"${PASSWORD}"です。"
        #所有者変更
        start_message
        chown -R unicorn:nobody /home/unicorn/
        su -l unicorn
        end_message


      else
        echo "buildree対象OSではないため、このスクリプトは使えません。"
      fi
    fi

else
  echo "このスクリプトはインストール対象以外は動きません。"
  cat <<EOF
  検証LinuxディストリビューションはDebian・Ubuntu・Fedora・Arch Linux（アーチ・リナックス）となります。
EOF
fi
exec $SHELL -l
