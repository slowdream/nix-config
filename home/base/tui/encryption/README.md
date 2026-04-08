# Encryption

По умолчанию у нас установлены GnuPG и password-store — в основном для управления паролями,
аутентификации и шифрования коммуникаций.

Также используется LUKS2 для disk encryption на Linux и [rclone](https://rclone.org/crypt/) для
cross-platform шифрования данных и синхронизации.

[age](https://github.com/FiloSottile/age) may be more general for file encryption.

[Sops](https://github.com/getsops/sops/tree/main) тоже можно использовать для шифрования файлов,
если вы предпочитаете Cloud provider для key management.

## Asymmetric Encryption

age, Sops и GnuPG поддерживают asymmetric encryption — это удобно, когда нужно шифровать файлы для
конкретного пользователя.

For modern use, age is recommended, as it use [AEAD encryption function -
ChaCha20-Poly1305][age Format v1], If you do not want to manage the keys by yourself, Sops is
recommended, as it use KMS for key management.

## Symmetric Encryption

age и GnuPG поддерживают symmetric encryption — удобно, когда нужно быстро зашифровать файл «для
себя».

As described in [age Format v1][age Format v1], age use scrypt to encrypt and decrypt the file key
with a provided passphrase, which is more secure than GnuPG's symmetric encryption.

[age Format v1]: https://age-encryption.org/v1
