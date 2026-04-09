# 1. Приватный ключ Root CA
openssl ecparam -genkey -name secp384r1 -out ecc-ca.key
# 2. Сертификат Root CA на 10 лет
# по приватному ключу и полям в -subj
# NOTE: подпись sha512 — важно
openssl req -x509 -new -SHA512 -key ecc-ca.key -subj "/CN=Ryan4Yin's Root CA 1" -days 3650 -out ecc-ca.crt

# 3. Приватный ключ веб-сервера
openssl ecparam -genkey -name secp384r1 -out ecc-server.key
# 4. CSR для серверного сертификата
# ключ + ecc-csr.conf
openssl req -new -SHA512 -key ecc-server.key -out ecc-server.csr -config ecc-csr.conf
# 5. Подпись сертификата Root CA
# NOTE: подпись sha512 — важно
openssl x509 -req -SHA512 -in ecc-server.csr -CA ecc-ca.crt -CAkey ecc-ca.key \
  -CAcreateserial -out ecc-server.crt -days 3650 \
  -extensions v3_ext -extfile ecc-csr.conf

# 6. Просмотр сертификатов
openssl x509 -noout -text -in ecc-ca.crt
openssl x509 -noout -text -in ecc-server.crt
