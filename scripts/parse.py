#!/usr/bin/python3

import sys
import zlib
import json
from dotmap import DotMap


def check_null(data: bytes, pos: int, length: int):
  all_nulls = False
  if data[pos:pos+length] == b'\0' * length:
    all_nulls = True
  return (all_nulls, pos+length)


def check_null_warn(data: bytes, pos: int, length: int):
  all_nulls, newpos = check_null(data, pos, length)
  if not(all_nulls):
    print(f"Warning: expected {length} null bytes, but got this instead: {data.hex(' ')}")
  return newpos


def get_string(data: bytes, pos: int, length_bytes: int):
  length = int.from_bytes(data[pos:pos+length_bytes], 'little')
  pos += length_bytes
  ver_str = data[pos:pos+length].decode('ascii')
  pos += length
  return (pos, ver_str)


def get_int(data: bytes, pos: int, length_bytes: int):
  int_data = int.from_bytes(data[pos:pos+length_bytes], 'little')
  pos += length_bytes
  return (pos, int_data)


def get_hex(data: bytes, pos: int, length_bytes: int):
  hex_data = data[pos:pos+length_bytes].hex(' ')
  pos += length_bytes
  return (pos, hex_data)


def get_timestamp(data: bytes, pos: int):
  ts_bytes = data[pos:pos+16]
  pos += 16
  year = int.from_bytes(ts_bytes[0:2], 'little')
  month = int.from_bytes(ts_bytes[2:4], 'little')
  day = int.from_bytes(ts_bytes[6:8], 'little')
  hour = int.from_bytes(ts_bytes[8:10], 'little')
  min = int.from_bytes(ts_bytes[10:12], 'little')
  sec = int.from_bytes(ts_bytes[12:14], 'little')
  unknown0 = int.from_bytes(ts_bytes[4:6], 'little')
  unknown1 = int.from_bytes(ts_bytes[14:16], 'little')
  ts = f"{year:04d}-{month:02d}-{day:02d}T{hour:02d}:{min:02d}:{sec:02d} {unknown0} {unknown1}"
  return (pos, ts)


# different versions have different formats
VER_NONE = 0
VER_2_4 = 24
VER_1_0 = 10
VER_3_0 = 30
file_version = VER_NONE


with open(sys.argv[1], "rb") as f:
  whole_file = f.read()

pos = 0

m = DotMap()

#################################################
# start parsing the file itself


bsign = whole_file[0:4]
m.signature = str(bsign)
pos = 4

m.version_string = whole_file[pos:pos+12].decode('ascii')
print("Version string: " + m.version_string)
pos += 12

match bsign:
  case b'SH3\0': # R02.04.00.00
    file_version = VER_2_4
  case b'DEM\0': # R01.00.00.00
    file_version = VER_1_0
  case b'\0\0\0\0': # possibly smart V3
    if m.version_string == "R03.00.00.00":
      file_version = VER_3_0
    else:
      print("Error: unsupported file format")
      sys.exit(0)
  case _:
    print("Error: unsupported file header " + m.signature)
    sys.exit(0)

if file_version == VER_2_4:
  pos = check_null_warn(whole_file, pos, 92)
if file_version == VER_1_0:
  pos = check_null_warn(whole_file, pos, 48)
if file_version == VER_3_0:
  pos = check_null_warn(whole_file, pos, 104)
  pass
  data = whole_file[pos:pos+4]
  pos += 4
  print(f"Possible decompressed length of {int.from_bytes(data, 'little')} bytes ({data.hex(' ')})")
  pass
  pos = check_null_warn(whole_file, pos, 132)
  pass
  print(f"File version {m.version_string} is not supported yet")
  sys.exit(0)


m.decompressed_length = int.from_bytes(whole_file[pos:pos+4], 'little')
pos += 4

compressed_data = whole_file[pos:]
try:
  decompressed_data = zlib.decompress(compressed_data)
except:
  print(f"Error decompressing stream: {compressed_data[0:10].hex(' ')} ...")
  sys.exit(1)

if m.decompressed_length != len(decompressed_data):
  print(f"Warning: uncompressed data length is wrong, recorded {m.decompressed_length} bytes, actual {len(decompressed_data)} bytes")

print(f"{len(compressed_data)} bytes successfully decompressed into {len(decompressed_data)} bytes: {decompressed_data[0:10].hex(' ')} ...")


#################################################
# start parsing the compressed data

pos = 0

m.s.header.editor_majmin_version = decompressed_data[0]
pos += 1

if file_version == VER_2_4:
  # todo: split up the decimals. this is like a BCD but not actually: 0xd000 = 208 = 0208 = V02.08
  m.s.header.encoded_version = list(decompressed_data[pos:pos+8])
  pos += 8
if file_version == VER_1_0:
  m.s.header.encoded_version = list(decompressed_data[pos:pos+4])
  pos += 4

# TODO: check that this is 0x03
m.s.marker0 = int.from_bytes(decompressed_data[pos:pos+1])
pos += 1

m.s.last_connected.modbus_station_number = int.from_bytes(decompressed_data[pos:pos+1])
pos += 1

pos = check_null_warn(decompressed_data, pos, 3)

m.s.last_connected.ip_address = list(decompressed_data[pos:pos+4])
pos += 4

pos = check_null_warn(decompressed_data, pos, 1)

pos, m.s.software_version = get_string(decompressed_data, pos, 2)

pos = check_null_warn(decompressed_data, pos, 1)

pos, m.s.project_name = get_string(decompressed_data, pos, 2)

pos = check_null_warn(decompressed_data, pos, 1)

# TODO: map the codes to LAD / FBD / STL modes
pos, m.s.editor_mode = get_int(decompressed_data, pos, 1)

pos = check_null_warn(decompressed_data, pos, 3)

# TODO: check that this is 0x01
pos, m.s.marker1 = get_int(decompressed_data, pos, 1)

if file_version == VER_2_4:
  pos = check_null_warn(decompressed_data, pos, 156)
if file_version == VER_1_0:
  # TODO: the first part is a null-padded 32-byte string that holds the name of the last used printer
  # so 148 = 32 + 114
  pos, m.s.data0_printer = get_hex(decompressed_data, pos, 148)

if file_version == VER_2_4:
  m.s.data1 = str(decompressed_data[pos:pos+16])
  pos += 16
  expected_data = b'\x6e\x04\x00\x00' * 4
  if m.s.data1 != str(expected_data):
    print("Warning: unexpected data")
    print("Expected: " + str(expected_data))
    print("Actual:   " + str(m.s.data1))
if file_version == VER_1_0:
  m.s.data1 = str(decompressed_data[pos:pos+16])
  pos += 16
  expected_data = b'\x08\x07\x00\x00\xa0\x05\x00\x00' * 2
  if m.s.data1 != str(expected_data):
    print("Warning: unexpected data")
    print("Expected: " + str(expected_data))
    print("Actual:   " + str(m.s.data1))

if file_version == VER_2_4:
  pos = check_null_warn(decompressed_data, pos, 10)
if file_version == VER_1_0:
  m.s.data2 = str(decompressed_data[pos:pos+10])
  pos += 10

# TODO: check that this is 0x02 0x00 0x02 0x00 -> 131074
pos, m.s.marker2 = get_int(decompressed_data, pos, 4)

pos, m.s.data3 = get_hex(decompressed_data, pos, 256)

if file_version == VER_2_4:
  expected_data = "%[PROJECT]  /  %[OBJECT]".encode('ascii')
  expected_data += b'\0' * (256-len(expected_data))
  if m.s.data3 != expected_data.hex(' '):
    print("Warning: unexpected data")
    print("Expected: " + expected_data.hex(' '))
    print("Actual:   " + m.s.data3)
if file_version == VER_1_0:
  expected_data = "%[PROJECT], %[OBJECT]".encode('ascii')
  expected_data += b'\0' * (256-len(expected_data))
  if m.s.data3 != expected_data.hex(' '):
    print("Warning: unexpected data")
    print("Expected: " + expected_data.hex(' '))
    print("Actual:   " + m.s.data3)

pos, m.s.data4_page = get_hex(decompressed_data, pos, 256)
expected_data = "%[PAGE]".encode('ascii')
expected_data += b'\0' * (256-len(expected_data))
if m.s.data4_page != expected_data.hex(' '):
  print("Warning: unexpected data")
  print("Expected: " + expected_data.hex(' '))
  print("Actual:   " + m.s.data4_page)

pos = check_null_warn(decompressed_data, pos, 512)

pos = check_null_warn(decompressed_data, pos, 2)

if file_version == VER_2_4:
  pos, m.s.data5 = get_hex(decompressed_data, pos, 80)
if file_version == VER_1_0:
  pos, m.s.data5 = get_hex(decompressed_data, pos, 88)

# creation?, last modified
# 01
# last modified, data pages modified
pos, m.s.timestamp.created = get_timestamp(decompressed_data, pos)
pos, m.s.timestamp.last_modified0 = get_timestamp(decompressed_data, pos)

# TODO: check that this is 0x01
pos, m.s.marker3 = get_int(decompressed_data, pos, 1)

pos, m.s.timestamp.last_modified1 = get_timestamp(decompressed_data, pos)
pos, m.s.timestamp.last_modified_data_pages = get_timestamp(decompressed_data, pos)






print(json.dumps(m.toDict(), sort_keys=False, indent=2))