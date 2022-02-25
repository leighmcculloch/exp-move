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
```

Initialize the Coin module:
```
move sandbox run sources/scripts/0_coin_init.move --signers 0x2
```

Setup two accounts that trust the coin:
```
move sandbox run sources/scripts/1_coin_trust.move --signers 0x3
move sandbox run sources/scripts/1_coin_trust.move --signers 0x4
```

Mint some coin for the two accounts:
```
move sandbox run sources/scripts/2_coin_mint.move --signers 0x2 --args 0x3 --args 100
move sandbox run sources/scripts/2_coin_mint.move --signers 0x2 --args 0x4 --args 100
```

Make a payment between the accounts:
```
move sandbox run sources/scripts/3_pay.move --signers 0x3 --args 0x4 --args 2
```

Initialize the time module which we need for a channel. This module would be
provided by the system supposedly.
```
move sandbox run sources/scripts/4_time_init.move
```

Initialize a channel between the two accounts:
```
move sandbox run sources/scripts/5_channel_init.move --signers 0x3 --args 0x3 --args 0x4
```

Have both accounts join the channel:
```
move sandbox run sources/scripts/6_channel_join.move --signers 0x3
move sandbox run sources/scripts/6_channel_join.move --signers 0x4
```

Have both accounts deposit some amount into the channel:
```
move sandbox run sources/scripts/7_channel_deposit.move --signers 0x3 --args 0x3 --args 50
move sandbox run sources/scripts/7_channel_deposit.move --signers 0x4 --args 0x4 --args 50
```

Both accounts can transact offline by signing any number of transactions that
call the close operation with a new final balance. We will submit a few of
those.

First run the following command any number of times to move time to some point:
```
move sandbox run sources/scripts/9_time_tick.move
```

Submit a close that is signed by both participants. It is agreement 120 in the
sequence of payments the participants have made with each other offline, where
0x3 is to pay as a final payment to 0x4 a total of 10, and both participants
agreed to a delay of 2 units of time must pass before they can withdraw:
```
move sandbox run sources/scripts/8_channel_close.move --signers 0x3 --signers 0x4 --args 120 --args 10 --args 2
```

Lets try and withdraw straight away, we should see an error:
```
move sandbox run sources/scripts/10_channel_withdraw.move --signers 0x3
```

Submit another close that has a different agreement, that occurred before the
120 seq, but has 0x4 pay 0x3 instead, we should see an error:
```
move sandbox run sources/scripts/8_channel_close.move --signers 0x4 --signers 0x3 --args 111 --args 30 --args 2
```

Submit another close that has a different agreement, that occurred after the
120 seq, we should see it succeed:
```
move sandbox run sources/scripts/8_channel_close.move --signers 0x4 --signers 0x3 --args 136 --args 10 --args 2
```

Move time along at least two units:
```
move sandbox run sources/scripts/9_time_tick.move
move sandbox run sources/scripts/9_time_tick.move
```

Lets try and withdraw, we should succeed:
```
move sandbox run sources/scripts/10_channel_withdraw.move --signers 0x3
move sandbox run sources/scripts/10_channel_withdraw.move --signers 0x4
```

Inspecting the amounts that 0x3 and 0x4 have in storage should be updated:
```
move sandbox view ...
```
