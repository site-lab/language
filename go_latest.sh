#!/bin/sh

#rootユーザーで実行 or sudo権限ユーザー

<<COMMENT
作成者：サイトラボ
URL：https://www.site-lab.jp/
URL：https://www.logw.jp/

Go言語のインストールを行います

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

#CentOS7か確認
if [ -e /etc/redhat-release ]; then
    DIST="redhat"
    DIST_VER=`cat /etc/redhat-release | sed -e "s/.*\s\([0-9]\)\..*/\1/"`

    if [ $DIST = "redhat" ];then
      if [ $DIST_VER = "7" ];then
        #EPELリポジトリのインストール
        start_message
        yum remove -y epel-release
        yum -y install epel-release
        end_message

        # yum updateを実行
        start_message
        echo "yum updateを実行します"
        echo ""
        yum -y update
        end_message

        #Go言語のインストール
        start_message
        echo "Go言語のインストールをします"
        echo "yum install -y golang"
        yum install -y golang
        #バージョン確認
        go version
        end_message

        #Go言語の設定変更
        start_message
        echo "Go言語のパスを通します"
        mkdir /usr/local/gocode
        mkdir /usr/local/gocode/{src,bin,pkg}
        touch /etc/profile.d/golang.sh
        export GOROOT=/usr/lib/golang >> /etc/profile.d/golang.sh
        export GOPATH=/usr/local/gocode >> /etc/profile.d/golang.sh
        export PATH=$PATH:$GOROOT/bin:$GOPATH/bin >> /etc/profile.d/golang.sh

        #設定の反映
        source /etc/profile.d/golang.sh
        end_message

        #ユーザー作成
        start_message
        echo "centosユーザーを作成します"
        USERNAME='centos'
        PASSWORD=$(more /dev/urandom  | tr -d -c '[:alnum:]' | fold -w 10 | head -1)

        useradd -m -G nobody -s /bin/bash "${USERNAME}"
        echo "${PASSWORD}" | passwd --stdin "${USERNAME}"
        echo "パスワードは"${PASSWORD}"です。"
        end_message

        umask 0002

        #ファイルの保存
        start_message
        echo "パスワードなどを保存"
        cat <<EOF >/root/pass.txt
ログインユーザー
centos = ${PASSWORD}
EOF

        #コピー作成
        cp /root/pass.txt /home/centos/
        chown -R centos:nobody /home/centos
        end_message



        #サンプルファイル作成
        start_message
        cat > /home/centos/hello.go <<'EOF'
        package main

        import "fmt"

        func main(){
          fmt.Printf("こんにちは！世界！\n")
        }
EOF
        end_message

        #実行
        start_message
        echo "実行します"
        echo "go run hello.go"
        su -l centos -c "go run hello.go"
        end_message

        cat <<EOF
-----------------
Go言語のみのインストールとなります。ブラウザなどの連携はしておりません。
デーモン化などで使う場合にお勧めします
Goのバージョンは最新となっています
-----------------
パスワードのテキストファイルは、rootとcentosと両方にあります
-----------------
EOF
        echo "centosユーザーのパスワードは"${PASSWORD}"です。"
        #所有者変更
        start_message
        chown -R centos:nobody /home/centos/
        su -l centos
        end_message


      else
        echo "CentOS7ではないため、このスクリプトは使えません。このスクリプトのインストール対象はCentOS7です。"
      fi
    fi

else
  echo "このスクリプトのインストール対象はCentOS7です。CentOS7以外は動きません。"
  cat <<EOF
  検証LinuxディストリビューションはDebian・Ubuntu・Fedora・Arch Linux（アーチ・リナックス）となります。
EOF
fi
exec $SHELL -l
