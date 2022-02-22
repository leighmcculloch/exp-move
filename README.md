# Experimenting with Move

## Setup

```
sudo apt update
sudo apt install libssl-dev pkg-config
cargo install --git https://github.com/diem/move move-cli --branch main
```

## Usage

Deploy the modules:
```
move sandbox publish
move sandbox run sources/scripts/init.move --signers 0x2
```

Setup two accounts that trust the coin:
```
move sandbox run sources/scripts/trust.move --signers 0x3
move sandbox run sources/scripts/trust.move --signers 0x4
```

Mint some coin for the two accounts:
```
move sandbox run sources/scripts/mint.move --signers 0x2 --args 0x3 --args 10
move sandbox run sources/scripts/mint.move --signers 0x2 --args 0x4 --args 10
```

Do some things with the accounts and coin:
```
move sandbox run sources/scripts/give.move --signers 0x2 --args 0x4 --args 2
```
