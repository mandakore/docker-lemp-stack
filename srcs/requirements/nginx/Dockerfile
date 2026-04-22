FROM alpine:3.23.3

RUN apk update && apk upgrade && apk add --no-cache \
    nginx \
    openssl
RUN mkdir -p /etc/nginx/ssl

# 自己署名 SSL 証明書と秘密鍵を生成する
# req -x509: 自己署名証明書を直接生成（CAによる署名なし）
# -nodes: 秘密鍵をパスフレーズなしで生成（コンテナ起動時にパスフレーズ入力が不要）
# -newkey rsa:4096: 4096ビットのRSA鍵ペアを生成
# -keyout: 秘密鍵の出力先
# -out: 証明書の出力先
# -days 365: 証明書の有効期限（365日）
# -subj: 証明書の識別情報（対話入力を省略するため）
RUN openssl req -x509 -nodes \
    -newkey rsa:4096 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem \
    -days 365 \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42Tokyo/OU=Inception/CN=atashiro.42.fr"

COPY conf/nginx.conf /etc/nginx/http.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
