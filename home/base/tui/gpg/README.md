# GNU Privacy Guard(GnuPG)

> Official Website: `https://www.gnupg.org/`

GNU Privacy Guard — это полноценная и свободная реализация стандарта OpenPGP (RFC4880), также
известного как **PGP**. GnuPG позволяет шифровать и подписывать данные/коммуникации, даёт
универсальную систему управления ключами и модули доступа к разным типам public key directories.

> Далее я использую GPG как обозначение утилиты GnuPG, а PGP — для понятий стандарта OpenPGP
> (например PGP key, PGP key server).

Ключевые функции GnuPG:

1. Управление keypair (keyring)
2. Подпись и проверка данных
3. Шифрование и расшифровка данных

Основные сценарии использования GnuPG:

1. Подпись или шифрование email
   1. Проверка подписи или расшифровка полученного письма
2. Подпись git commit
3. Управление ssh key
4. Шифрование данных и хранение их где-то ещё

GnuPG/OpenPGP — штука сложная, поэтому параллельно я всегда искал инструмент шифрования, который был
бы проще, при этом достаточно функционален и широко распространён.

Сейчас я использую и age, и GnuPG:

1. Age — для шифрования secrets (ssh key и другие secret files): просто и удобно.
2. GnuPG — для password-store и шифрования email.

> Сейчас безопасное и удобное использование GPG часто предполагает hardware keys вроде yubikey. Но у
> меня его нет, поэтому здесь это не рассматриваю.

## Practical Cryptography for Developers

Чтобы пользоваться GnuPG уверенно, полезно иметь базовые знания по практической криптографии. Вот
несколько материалов:

- English version: <https://github.com/nakov/Practical-Cryptography-for-Developers-Book>
- Chinese version: <https://thiscute.world/tags/cryptography/>

## Обзор GnuPG

> Official User Guides: <https://www.gnupg.org/documentation/guides.html>

> ArchWiki: <https://wiki.archlinux.org/title/GnuPG>

### 0. Как GnuPG генерирует и защищает keypair?

Материалы:

- [2021年，用更现代的方法使用PGP（上）][2021年，用更现代的方法使用PGP（上）]
- [Predictable, Passphrase-Derived PGP Keys][Predictable, Passphrase-Derived PGP Keys]
- [OpenPGP - The almost perfect key pair][OpenPGP - The almost perfect key pair]

GnuPG генерирует каждый secret key отдельно и шифрует его symmetric key, полученным из passphrase.
Стандарт OpenPGP определяет алгоритм
[String-to-Key (S2K)](https://datatracker.ietf.org/doc/html/rfc4880#section-3.7) algorithm to derive
a symmetric key from your passphrase.

GnuPG:
[OpenPGP protocol specific options](https://gnupg.org/documentation/manuals/gnupg/OpenPGP-Options.html#OpenPGP-Options)
показывает:

```
--s2k-cipher-algo name

    Use name as the cipher algorithm for symmetric encryption with a passphrase if --personal-cipher-preferences and --cipher-algo are not given. The default is AES-128.
--s2k-digest-algo name

    Use name as the digest algorithm used to mangle the passphrases for symmetric encryption. The default is SHA-1.
--s2k-mode n

    Selects how passphrases for symmetric encryption are mangled. If n is 0 a plain passphrase (which is in general not recommended) will be used, a 1 adds a salt (which should not be used) to the passphrase and a 3 (the default) iterates the whole process a number of times (see --s2k-count).
--s2k-count n

    Specify how many times the passphrases mangling for symmetric encryption is repeated. This value may range between 1024 and 65011712 inclusive. The default is inquired from gpg-agent. Note that not all values in the 1024-65011712 range are legal and if an illegal value is selected, GnuPG will round up to the nearest legal value. This option is only meaningful if --s2k-mode is set to the default of 3.
```

Самые «сильные» параметры будут примерно такими:

```
gpg --s2k-mode 3 --s2k-count 65011712 --s2k-digest-algo SHA512 --s2k-cipher-algo AES256 ...
```

Чтобы использовать эти параметры глобально, можно прописать их в `~/.gnupg/gpg.conf`. Я добавил их в
опцию Home Manager `programs.gpg.settings`.

### 1. Генерация PGP key (Primary Key)

Key management — это ядро OpenPGP / GnuPG.

GnuPG использует public-key cryptography, чтобы пользователи могли общаться безопасно. В public-key
системе у каждого пользователя есть пара ключей: private key и public key. **Private key хранится в
секрете и не должен быть раскрыт. Public key можно передавать всем, с кем вы хотите безопасно
общаться**. В GnuPG схема чуть сложнее: есть primary keypair и затем 0+ subordinate keypairs. Primary
и subordinate ключи объединяются для удобства управления; часто это воспринимается как один keypair
или keyring/keychain (с несколькими sub key-pairs).

Сгенерируем keypair интерактивно:

> В 2024 году GnuPG 2.4.1 по умолчанию предлагает ECC algorithm (9) и Curve 25519 — это современно и
> безопасно, рекомендую оставить defaults.

```bash
gpg --full-gen-key
```

Эта команда спросит настройки алгоритмов (ECC и Curve 25519), ваши персональные данные и сильный
passphrase для защиты PGP key, например:

```bash
› gpg --full-gen-key
gpg (GnuPG) 2.4.1; Copyright (C) 2023 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

gpg: directory '/Users/ryan/.gnupg' created
Please select what kind of key you want:
   (1) RSA and RSA
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (9) ECC (sign and encrypt) *default*
  (10) ECC (sign only)
  (14) Existing key from card
Your selection? 9
Please select which elliptic curve you want:
   (1) Curve 25519 *default*
   (4) NIST P-384
   (6) Brainpool P-256
Your selection? 1
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 10y
Key expires at 一  1/ 4 13:50:31 2044 CST
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name:
Email address:
Comment:
You selected this USER-ID:
    "Ryan Yin (For pass For Work ssh only) <ryan4yin@linux.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: /Users/ryan/.gnupg/trustdb.gpg: trustdb created
gpg: directory '/Users/ryan/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/Users/ryan/.gnupg/openpgp-revocs.d/C8D84EBC5F82494F432ACEF042E49B284C30A0DA.rev'
public and secret key created and signed.

pub   ed25519 2024-01-09 [SC] [expires: 2034-01-04]
      C8D84EBC5F82494F432ACEF042E49B284C30A0DA
uid                      Ryan Yin (For pass For Work ssh only) <ryan4yin@linux.com>
sub   cv25519 2024-01-09 [E] [expires: 2034-01-04]
```

### 2. Конфигурационные файлы

> https://www.gnupg.org/documentation/manuals/gnupg/GPG-Configuration.html

Сгенерированные ключи по умолчанию лежат в `~/.gnupg`. Назначение файлов примерно такое:

```bash
› tree ~/.gnupg/
/Users/ryan/.gnupg/
|-- S.gpg-agent           # socket file
|-- S.gpg-agent.browser   # socket file
|-- S.gpg-agent.extra     # socket file
|-- S.gpg-agent.ssh       # socket file
|-- S.keyboxd             # socket file
|-- common.conf              # config file
|-- openpgp-revocs.d         # Revocation certificates
|   `-- F680C6D7215674ADEA421CC5E22EC419FF93EA98.rev
|-- private-keys-v1.d        # private keys with user info & protect by passphrase
|   |-- 2083133619AB24DC32DA68F9FE83C58D375284E3.key
|   `-- 9350704F120643C504491E92CA97255223778C8A.key
|-- public-keys.d            # public keys
|   |-- pubring.db
|   `-- pubring.db.lock
`-- trustdb.gpg              # a trust database

4 directories, 12 files
```

Назначение большинства файлов довольно очевидно, но `trustdb.gpg` может быть не таким понятным. Вот
подробности: <https://www.gnupg.org/gph/en/manual/x334.html>

Home Manager будет управлять всем в `~/.gnupg/`, КРОМЕ `~/.gnupg/openpgp-revocs.d/` и
`~/.gnupg/private-keys-v1.d/` — так и задумано.

### 3. Генерация sub keys и best practice

В PGP у каждого ключа есть **usage flag**, который обозначает назначение:

- `C` means this key can be used to **Certify** other keys, which means this key can be used to
  **create/delete/revoke/modify** other keys.
- `S` means this key can be used to **Sign** data.
- `E` means this key can be used to **Encrypt** data.
- `A` means this key can be used to **Authenticate** data with various non-GnuPG programs. The key
  can be used as e.g. an **SSH key**.

Best practice обычно такой:

1. Сгенерировать primary key с сильными параметрами криптографии (например ECC + Curve 25519).
2. Затем сгенерировать 3 sub keys с usage flag `E`, `S` и `A` соответственно.
3. **Primary Key критически важен**: сделайте backup в максимально безопасное место (например, два
   зашифрованных USB-накопителя в разных местах) и затем **удалите его с компьютера**.
4. Sub key тоже важны, но их проще пересоздать и заменить. Можно хранить backup отдельно и импортнуть
   на другую машину, чтобы пользоваться keypair.
5. Сохраните revocation certificate для primary key в надёжном месте — это «последняя линия обороны»,
   если primary key скомпрометирован.
6. Если скомпрометирован revocation certificate — это проблема, но не самая страшная: он лишь
   позволяет отозвать keypair, данные остаются в безопасности. Но лучше сгенерировать новый keypair и
   отозвать старый.
7. Если скомпрометирован primary key и у вас нет revocation certificate — это уже серьёзно. При этом
   в OpenPGP нет хорошего способа распространения revocation certificate, так что даже если он есть,
   распространять его всё равно непросто.

Чтобы держать keypair в безопасности, делайте backup по шагам ниже.

Теперь добавим sub keys в keypair, который мы сгенерировали выше:

> `E` sub key уже создаётся по умолчанию, поэтому нужно сгенерировать только `S` и `A` sub keys.

> GnuPG попросит ввести passphrase, чтобы разблокировать primary key.

```bash
› gpg --expert --edit-key ryan4yin@linux.com
gpg (GnuPG) 2.4.1; Copyright (C) 2023 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Secret key is available.

sec  ed25519/42E49B284C30A0DA
     created: 2024-01-09  expires: 2034-01-04  usage: SC
     trust: ultimate      validity: ultimate
ssb  cv25519/6CB4A81FFB3C99B6
     created: 2024-01-09  expires: 2034-01-04  usage: E
[ultimate] (1). Ryan Yin (For pass For Work ssh only) <ryan4yin@linux.com>

gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 10
Please select which elliptic curve you want:
   (1) Curve 25519 *default*
   (2) Curve 448
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 10y
Key expires at Mon Jan  4 17:47:24 2044 CST
Is this correct? (y/N) y
Really create? (y/N) y
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

sec  ed25519/42E49B284C30A0DA
     created: 2024-01-09  expires: 2034-01-04  usage: SC
     trust: ultimate      validity: ultimate
ssb  cv25519/6CB4A81FFB3C99B6
     created: 2024-01-09  expires: 2034-01-04  usage: E
ssb  ed25519/A42813E03A10F504
     created: 2024-01-09  expires: 2034-01-04  usage: S
[ultimate] (1). Ryan Yin (For pass For Work ssh only) <ryan4yin@linux.com>

gpg> addkey
Please select what kind of key you want:
   (3) DSA (sign only)
   (4) RSA (sign only)
   (5) Elgamal (encrypt only)
   (6) RSA (encrypt only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (12) ECC (encrypt only)
  (13) Existing key
  (14) Existing key from card
Your selection? 11

Possible actions for this ECC key: Sign Authenticate
Current allowed actions: Sign

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? S

Possible actions for this ECC key: Sign Authenticate
Current allowed actions:

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? A

Possible actions for this ECC key: Sign Authenticate
Current allowed actions: Authenticate

   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? Q
Please select which elliptic curve you want:
   (1) Curve 25519 *default*
   (2) Curve 448
   (3) NIST P-256
   (4) NIST P-384
   (5) NIST P-521
   (6) Brainpool P-256
   (7) Brainpool P-384
   (8) Brainpool P-512
   (9) secp256k1
Your selection? 1
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 10y
Key expires at Mon Jan  4 17:48:27 2044 CST
Is this correct? (y/N) y
Really create? (y/N) y
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.

sec  ed25519/42E49B284C30A0DA
     created: 2024-01-09  expires: 2034-01-04  usage: SC
     trust: ultimate      validity: ultimate
ssb  cv25519/6CB4A81FFB3C99B6
     created: 2024-01-09  expires: 2034-01-04  usage: E
ssb  ed25519/A42813E03A10F504
     created: 2024-01-09  expires: 2034-01-04  usage: S
ssb  ed25519/5469C4FACC81B60F
     created: 2024-01-09  expires: 2034-01-04  usage: A
[ultimate] (1). Ryan Yin (For pass For Work ssh only) <ryan4yin@linux.com>

gpg> save
```

Проверьте сгенерированные secret keys и public keys:

```bash
› gpg --list-secret-keys --with-subkey-fingerprint
[keyboxd]
---------
sec   ed25519 2024-01-09 [SC] [expires: 2034-01-04]
      C8D84EBC5F82494F432ACEF042E49B284C30A0DA
uid           [ultimate] Ryan Yin (For pass For Work ssh only) <ryan4yin@linux.com>
ssb   cv25519 2024-01-09 [E] [expires: 2034-01-04]
      1146D48B93C2177C92D186026CB4A81FFB3C99B6
ssb   ed25519 2024-01-09 [S] [expires: 2034-01-04]
      DF64002A822948B17783BBB1A42813E03A10F504
ssb   ed25519 2024-01-09 [A] [expires: 2034-01-04]
      65E2C6C1C3559362ABB7047C5469C4FACC81B60F

› gpg --list-public-keys
...
```

### 4. Backup и восстановление

Экспорт public keys (и Primary Key, и Sub Keys):

```bash
gpg --armor --export ryan4yin@linux.com > ryan4yin-gpg-keys.pub
# check what we have exported, we should see 4 public keys
nix run nixpkgs#pgpdump ryan4yin-gpg-keys.pub
```

Экспорт Primary Key (экспортированный ключ всё ещё зашифрован вашим passphrase):

> `!` в конце key ID заставляет GnuPG экспортировать только указанный ключ, без subkeys.

> GnuPG попросит passphrase, чтобы разблокировать keypair: при экспорте нужно преобразовать формат
> secret key из внутреннего «защищённого» формата в формат, определённый протоколом OpenPGP.

```bash
# replace the key ID with your own sec key's ID
gpg --armor --export-secret-keys C8D84EBC5F82494F432ACEF042E49B284C30A0DA! > ryan4yin-primary-key.priv

# Check the exported primary key's detail info,
nix run nixpkgs#pgpdump ryan4yin-primary-key.priv
...
Old: Secret Key Packet(tag 5)(134 bytes)
        Ver 4 - new
        Public key creation time - Sat Jan 27 14:13:13 CST 2024
        Pub alg - EdDSA Edwards-curve Digital Signature Algorithm(pub 22)
        Elliptic Curve - Ed25519 (0x2B 06 01 04 01 DA 47 0F 01)
        EdDSA Q(263 bits) - ...
        Sym alg - AES with 128-bit key(sym 7)
        Iterated and salted string-to-key(s2k 3):
                Hash alg - SHA1(hash 2)
                Salt - 8c 78 58 c0 87 83 8c 2c
                Count - 65011712(coded count 255)
        IV - xx xx xx xx xx xx xx xx xx xx xx xx xx xx xx
        Encrypted EdDSA x
        Encrypted SHA1 hash
...
```

Как сказано в [Predictable, Passphrase-Derived PGP Keys][Predictable, Passphrase-Derived PGP Keys],
можно обнаружить, что gpg проигнорировал `--s2k-count`, указанный при генерации keypair, а также
`--s2k` опции из `~/.gnupg/gpg.conf`. В итоге экспортированный primary key защищён `SHA1` и `AES128`,
что недостаточно безопасно.

Чтобы повысить безопасность экспортированного primary key, нужно зашифровать его повторно более
сильным алгоритмом. Я использую `age` (он применяет `scrypt` для шифрования file key по passphrase):

```bash
# for simplicity, use the same passphrase as your gpg keypair here
age --passphrase -o ryan4yin-primary-key.priv.age ryan4yin-primary-key.priv
rm ryan4yin-primary-key.priv
```

Экспорт sub keys (экспортированные ключи всё ещё зашифрованы вашим passphrase):

```bash
gpg --armor --export-secret-subkeys > ryan4yin-gpg-subkeys.priv

# Check the exported primary key's detail info,
nix run nixpkgs#pgpdump ryan4yin-gpg-subkeys.priv

# encrypt it again with age(scrypt)
age --passphrase  -o ryan4yin-gpg-subkeys.priv.age ryan4yin-gpg-subkeys.priv
rm ryan4yin-gpg-subkeys.priv
```

Экспортированный private key можно импортировать через `gpg --import <keyfile>`, но сначала нужно
расшифровать его через age.

Public keys лучше импортировать через опцию Home Manager `programs.gpg.publicKeys`. Не импортируйте
их вручную (через `gpg --import <keyfile>`).

Чтобы обеспечить безопасность, сразу после завершения backup удалите master key и revocation
certificate:

```bash
# delete the primary key and all its sub keys
gpg --delete-secret-keys ryan4yin@linux.com

# delete the revocation certificate
rm ~/.gnupg/openpgp-revocs.d/C8D84EBC5F82494F432ACEF042E49B284C30A0DA.rev

# import our subkeys back
age --decrypt -o ryan4yin-primary-key.priv ryan4yin-primary-key.priv.age
gpg --import ryan4yin-gpg-subkeys.priv
```

Теперь снова проверьте secret keys и public keys:

> `#` в конце key ID означает, что ключ недоступен, потому что мы его удалили.

```bash
› gpg --list-secret-keys --keyid-format=long
/home/ryan/.gnupg/pubring.kbx
-----------------------------
sec#  ed25519/D1C5FFA3118A41FC 2024-01-09 [SC] [expires: 2034-01-04]
      Key fingerprint = E267 943C 33AD C5AF 3D76  4D96 D1C5 FFA3 118A 41FC
uid                 [ unknown] Ryan Yin (Personal) <ryan4yin@linux.com>
ssb   cv25519/62526A4A0CF43E33 2024-01-09 [E] [expires: 2034-01-04]
ssb   ed25519/433A66D63805BD1A 2024-01-09 [S] [expires: 2034-01-04]
ssb   ed25519/441E3D8FBD313BF2 2024-01-09 [A] [expires: 2034-01-04]


› gpg --list-public-keys --keyid-format=long
/home/ryan/.gnupg/pubring.kbx
-----------------------------
pub   ed25519/D1C5FFA3118A41FC 2024-01-09 [SC] [expires: 2034-01-04]
      Key fingerprint = E267 943C 33AD C5AF 3D76  4D96 D1C5 FFA3 118A 41FC
uid                 [ unknown] Ryan Yin (Personal) <ryan4yin@linux.com>
sub   cv25519/62526A4A0CF43E33 2024-01-09 [E] [expires: 2034-01-04]
sub   ed25519/433A66D63805BD1A 2024-01-09 [S] [expires: 2034-01-04]
sub   ed25519/441E3D8FBD313BF2 2024-01-09 [A] [expires: 2034-01-04]
```

### 5. Подпись и проверка (Signing & Verification)

```bash
#  Make a cleartext signature.
gpg --clearsign <file>

# Make a detached signature, with text output.
gpg --armor --detach-sign <file>

# verify the file contains a valid signature.
gpg --verify <file>

# verify the file with a detached signature.
gpg --verify <file> <signature-file>
```

### 6. Шифрование и расшифровка (Encryption & Decryption)

```bash
# Encrypt a file via recipient's public key, sign it via your private key for signing, and output cleartext.
# so that the reciiptent can decrypt it via his/her private key.
gpg --armor --sign --encrypt --recipient ryan4yin@linux.com <file>
# or use this short version
gpg -aser ryan4yin@linux.com <file>

# Descrypt a file via your private key, and verify the signature via the sender's public key.
gpg --decrypt <file>
# or
gpg -d <file>
```

Если нужно быстро encrypt/decrypt файл, можно использовать `age` с passphrase. `gpg` тоже умеет, но
это не рекомендуется (age(scrypt) безопаснее):

```bash
# Encrypt a file via symmetric encryption(AES256), and output cleartext.
gpg --armor --symmetric --cipher-algo AES256 <file>
# or
gpg -ac <file>

# Decrypt a file via symmetric encryption.
gpg --decrypt <file>
# or
gpg -d <file>
```

### 7. Обмен public keys и отзыв (revocation)

Когда пользователей много, надёжно и безопасно обмениваться public keys становится сложно. В web-мире
эту проблему решает **Chain of Trust\*\***:

- A Certificate Authority(CA) is responsible to verify & sign all the certificate signing request.
- Web Server can safely transmit its Web Certificate to the client via TLS protocol.
- Client can verify the received Web Certificate via the CA's root certificate(which is built in
  Browser/OS).

А в OpenPGP:

- Есть key servers для распространения (exchange) public keys, но они **не проверяют личность владельца
  ключа**, а загруженные данные **нельзя удалить**. Это делает их **небезопасными и опасными**.
  - Почему key server опасен?
    - Многие новички по PGP по туториалам загружают ключи с персональными данными (например real name)
      на public key server, а потом выясняют, что удалить это нельзя — неприятно.
    - Любой может загрузить ключ на key server и заявить, что это ключ конкретного человека (например
      Linus) — очевидная проблема.
  - **key server** не рекомендуется использовать.
- GnuPG генерирует revocation certificate при создании keypair
  (`~/.gnupg/private-keys-v1.d/<Key-ID.rev>`). Любой, кто импортирует этот сертификат, сможет отозвать
  keypair. Но стандарт OpenPGP **не предоставляет хорошего способа распространять этот сертификат**.
  - И уж тем более нет протокола проверки статуса ключа наподобие OCSP из Web PKI.
  - Пользователям приходится публиковать revocation certificate в блоге, GitHub profile или где-то
    ещё, а всем остальным — вручную проверять и выполнять `gpg --import <revocation-certificate>`.

Итого: **в OpenPGP нет хорошего способа распространять public keys и надёжно отзывать их**, и это
большая проблема.

Сейчас остаётся распространять public key или revocation certificate через блог, GitHub profile или
другие каналы, а остальным — проверять это и вручную делать `gpg --import`.

Ладно, попробуем отозвать keypair:

```bash
› gpg --list-keys
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
/home/ryan/.gnupg/pubring.kbx
-----------------------------
pub   ed25519/0x55859965C2742B4B 2024-01-09 [SC]
      Key fingerprint = A2CD 07BD 9631 44CB 2725  5A6B 5585 9965 C274 2B4B
uid                   [ultimate] test <test@test.t>
sub   cv25519/0x9E78E897B6490D6B 2024-01-09 [E]

# encrypt some file before revoke the keypair
› gpg -are test@test.t README.md > README.md.asc

# try to decrypt the file, it should works
› gpg -d README.md.asc
gpg: encrypted with cv25519 key, ID 0x9E78E897B6490D6B, created 2024-01-09
      "test <test@test.t>"
# ......

# take a look at the revocation certificate
› cat gpg-test-revoke.rev
This is a revocation certificate for the OpenPGP key:

pub   ed25519/0x55859965C2742B4B 2024-01-09 [S]
      Key fingerprint = A2CD 07BD 9631 44CB 2725  5A6B 5585 9965 C274 2B4B
uid                            test <test@test.t>

A revocation certificate is a kind of "kill switch" to publicly
declare that a key shall not anymore be used.  It is not possible
to retract such a revocation certificate once it has been published.

Use it to revoke this key in case of a compromise or loss of
the secret key.  However, if the secret key is still accessible,
it is better to generate a new revocation certificate and give
a reason for the revocation.  For details see the description of
of the gpg command "--generate-revocation" in the GnuPG manual.

To avoid an accidental use of this file, a colon has been inserted
before the 5 dashes below.  Remove this colon with a text editor
before importing and publishing this revocation certificate.

:-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: This is a revocation certificate

iHgEIBYKACAWIQSizQe9ljFEyyclWmtVhZllwnQrSwUCZZ1T9wIdAAAKCRBVhZll
wnQrS2LVAQCegRF1qPqY/OCS5QCz8G0ra0XgPYlQYo9pSOjHgfY39AD+Psin2/6t
STuJCp+gru6OtbTCu8Y2LugQeDh7UicM7Ak=
=Xfs6
-----END PGP PUBLIC KEY BLOCK-----
```

Как сказано в revocation certificate, нужно убрать первый двоеточие (`:`) перед строкой из 5 дефисов
(`-----BEGIN PGP PUBLIC KEY BLOCK-----`), а затем импортировать:

```bash
› gpg --import gpg-test-revoke.rev
gpg: key 0x55859965C2742B4B: "test <test@test.t>" revocation certificate imported
gpg: Total number processed: 1
gpg:    new key revocations: 1
gpg: no ultimately trusted keys found

› gpg --list-secret-keys --keyid-format=long
/home/ryan/.gnupg/pubring.kbx
-----------------------------
sec   ed25519/55859965C2742B4B 2024-01-09 [SC] [revoked: 2024-01-09]
      Key fingerprint = A2CD 07BD 9631 44CB 2725  5A6B 5585 9965 C274 2B4B
uid                 [ revoked] test <test@test.t>


# try to decrypt the file, it still works, but will indicate that the key is revoked.
› gpg -d README.md.asc
gpg: encrypted with cv25519 key, ID 0x9E78E897B6490D6B, created 2024-01-09
      "test <test@test.t>"
gpg: Note: key has been revoked
gpg: reason for revocation: No reason specified
# ......

# try to encrypt some file via the revoked key, it will fail.
› gpg -are 9E78E897B6490D6B README.md
gpg: 9E78E897B6490D6B: skipped: Unusable public key
gpg: README.md: encryption failed: Unusable public key
```

Но если удалить `trustdb.gpg` и `pubring.kbx`, а затем снова импортировать отозванный public key, он
снова станет валидным и пригодным к использованию… это очень опасно.

## References

- [2021年，用更现代的方法使用PGP（上）][2021年，用更现代的方法使用PGP（上）]
- [Predictable, Passphrase-Derived PGP Keys][Predictable, Passphrase-Derived PGP Keys]
- [OpenPGP - The almost perfect key pair][OpenPGP - The almost perfect key pair]

[2021年，用更现代的方法使用PGP（上）]:
  https://ulyc.github.io/2021/01/13/2021%E5%B9%B4-%E7%94%A8%E6%9B%B4%E7%8E%B0%E4%BB%A3%E7%9A%84%E6%96%B9%E6%B3%95%E4%BD%BF%E7%94%A8PGP-%E4%B8%8A/
[Predictable, Passphrase-Derived PGP Keys]: https://nullprogram.com/blog/2019/07/10/
[OpenPGP - The almost perfect key pair]:
  https://blog.eleven-labs.com/en/openpgp-almost-perfect-key-pair-part-1/
