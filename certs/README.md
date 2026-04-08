# My Private PKI / CA

Это мой личный Private Key Infrastructure (PKI) / Certificate Authority (CA). Он используется для
выпуска сертификатов для моих серверов и сервисов.

## Текущая структура

- **ecc-ca.crt** - ECC CA certificate file
- **ecc-ca.srl** - CA serial number file for certificate tracking
- **ecc-csr.conf** - OpenSSL configuration file for certificate signing requests
- **ecc-server.crt** - Server certificate signed by the ECC CA
- **gen-certs.sh** - Shell script to generate certificates automatically

## Заметки по безопасности

Все private keys (файлы `.key`) игнорируются git и хранятся в приватном репозитории секретов. Public
certificates и конфигурационные файлы закоммичены в этот репозиторий как reference.

## Usage

Run `./gen-certs.sh` to generate new certificates using the ECC CA configuration.

See [../secrets](../secrets/) for the corresponding private key management.
