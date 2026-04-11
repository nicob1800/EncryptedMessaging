# Encrypted Messaging

STILL WORKING ON IT

A stream cipher implementation using Linear Feedback Shift Register (LFSR) keystream with both VHDL hardware and Ada software components.

## Overview

This project implements an LFSR-based stream cipher with the following components:

- **Hardware (VHDL)**: LFSR keystream generator and XOR codec for encryption/decryption
- **Software (Ada)**: String-to-byte conversion utilities and network client for encrypted communication

## Project Structure

```
EncryptedMessaging/
├── hardware/          # VHDL modules
│   ├── LFSR.vhd       # 16-bit LFSR keystream generator
│   ├── codec.vhd      # XOR encryption/decryption core
│   └── ...
├── software/          # Ada source code
│   ├── Character_Conversion.ads/adb    # Character to byte conversion
│   ├── String_Conversion.ads/adb       # String to byte array conversion
│   ├── test.adb       # Test harness for conversion routines
│   └── client.adb     # Network client (WIP)
├── README.md
├── LICENSE
└── .gitignore
```

## Building

### Hardware (VHDL with GHDL)

```bash
cd hardware
ghdl -a LFSR.vhd codec.vhd codec_top.vhd enc_dec_top.vhd testbench.vhd
ghdl -e testbench
ghdl -r testbench --stop-time=200ns --vcd=output.vcd
gtkwave output.vcd
```

### Software (Ada with GNAT)

```bash
cd software
gnatmake test.adb
./test.exe
```

## Usage

### Test the Conversion

Running the test harness shows ASCII-to-byte conversion:

```bash
gnatmake test.adb && ./test.exe
```

Expected output for `"Hello"`:

```
 72
101
108
108
111
```

## Features

- 16-bit LFSR with configurable tap polynomial
- Byte-by-byte encryption/decryption
- Ada utilities for string encoding

## Future Work

- Complete client/server socket implementation
- Add server-side decryption

## License

MIT License - See LICENSE file for details.
