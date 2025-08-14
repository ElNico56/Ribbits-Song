#!/usr/bin/env python3

import urllib.request
import os.path

base = "https://github.com/yungnickyoung/Ribbits/raw/refs/heads/1.20.1/Common/src/main/resources/assets/ribbits/sounds/music/"
names = [
    "maraca.ogg",
    "ribbit_bass.ogg",
    "ribbit_bongo.ogg",
    "ribbit_flute.ogg",
    "ribbit_guitar.ogg",
]
for name in names:
    print(f"Downloading '{name}'")
    urllib.request.urlretrieve(base + name, os.path.join("assets", name))
