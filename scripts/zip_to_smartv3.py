#!/usr/bin/python3

import sys
from os import path
from hashlib import sha256
from Crypto.Cipher import AES


# IV and AAD are statically defined
IV_HEX  = "95 A6 34 68 4A 46 A9 70 EE 90 76 49"
AAD_HEX = "4A 14 B3 A5 7B C9 F4 92 EB 46 87 94 62 EF B9 C6"

# default password if file is not to be password-protected
DEFAULT_PASSWORD = b'SMART200_V3_PRJ_KEY'
# TODO: allow user to specify password


# initialize encryption parameters
iv  = bytes.fromhex(IV_HEX)
aad = bytes.fromhex(AAD_HEX)

# project file name
zip_file = sys.argv[1]
zip_basename = path.basename(zip_file)
project_name, zip_ext = path.splitext(zip_basename)
if ".zip" != zip_ext.lower():
  print("Error: specify a zip archive to process into a '.smartv3' project file")
  sys.exit(1)
# TODO: maybe use ".smartV3" instead? just like how MWSmart V3 does it
# or maybe scan the directory and figure out whether we use the capitalized form or not
# just use ".smartV3" for now
project_file = project_name + ".smartV3"

with open(sys.argv[1], "rb") as f:
  plaintext = f.read()

# TODO: allow user to password-protect the project
# TODO: allow user to select version here
# as of today, 2026-01-04, there are two versions: R03.00.00.00 and R03.01.00.00
header = b'\0' * 4 \
  + b'R03.00.00.00' \
  + b'\0' * 104 \
  + bytes.fromhex('00 02') \
  + b'\0' * 134

key = sha256(DEFAULT_PASSWORD).digest()

try:
  cipher = AES.new(key, AES.MODE_GCM, iv)
  cipher.update(aad)
  ciphertext, tag = cipher.encrypt_and_digest(plaintext)
except (ValueError, KeyError):
  print("Encryption failed")
  sys.exit(1)

with open(project_file, "xb") as f:
  f.write(header)
  f.write(ciphertext)
  f.write(tag)
  print(f"Created project file {project_file}")
