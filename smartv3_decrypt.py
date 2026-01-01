#!/usr/bin/python3

import sys
from os import path
from hashlib import sha256
from Crypto.Cipher import AES


# IV and AAD are statically defined
IV_HEX  = "95 A6 34 68 4A 46 A9 70 EE 90 76 49"
AAD_HEX = "4A 14 B3 A5 7B C9 F4 92 EB 46 87 94 62 EF B9 C6"

# default password if file is not password-protected
DEFAULT_PASSWORD = b'SMART200_V3_PRJ_KEY'


# initialize encryption parameters
iv  = bytes.fromhex(IV_HEX)
aad = bytes.fromhex(AAD_HEX)

# initialize names and sanity check
project_file = sys.argv[1]
project_basename = path.basename(project_file)
project_name, file_ext = path.splitext(project_basename)
if ".smartv3" != file_ext.lower():
  print("Error: file name does not end in '.smartv3'")
  sys.exit(1)
zip_file = project_name + ".zip"

with open(sys.argv[1], "rb") as f:
  d = f.read()
  header = d[0:256]
  ciphertext = d[256:-16]
  tag = d[-16:]

if header[:4] != b'\0' * 4 \
  or header[4:16] != b'R03.00.00.00' \
  or header[16:120] != b'\0' * 104 \
  or header[122:] != b'\0' * 134:
  print("Warning: file header does not look right, see below")
  print(header.hex(' '))

password_protected = False
d = header[120:122].hex(' ')
if d == "00 01":
  password_protected = True
elif d == "00 02":
  pass
else:
  print(f"Warning: unrecognized project protection flag {d}, assuming file is not password-protected.")

if password_protected:
  password = input("Password: ").encode('ascii')
else:
  password = DEFAULT_PASSWORD

key = sha256(password).digest()

try:
  cipher = AES.new(key, AES.MODE_GCM, iv)
  cipher.update(aad)
  plaintext = cipher.decrypt_and_verify(ciphertext, tag)
except (ValueError, KeyError):
  print("Decryption failed -- please make sure the password is correct.")
  print("If you are sure the password is correct, please report this as a bug.")
  sys.exit(1)

with open(zip_file, "wb") as f:
  f.write(plaintext)
  print(f"Decrypted data written to {zip_file}")
