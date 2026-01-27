#!/usr/bin/python3

# convenience script to create zip archive from directory
# TODO: mimic the original zip archive by setting flags etc (is it possible?)

import sys
from zipfile import ZipFile, ZIP_DEFLATED
import os


dir_name = sys.argv[1]

if not os.path.isdir(dir_name):
  print(f"Error: {dir_name} must be a directory")
  sys.exit(1)

dir_basename = os.path.basename(os.path.normpath(dir_name))
zip_file = dir_basename + ".zip"

with ZipFile(zip_file, 'x', ZIP_DEFLATED, compresslevel=9) as zip:
  for root, dirs, files in os.walk(dir_name):
    for file in files:
      # zip file names must use forward slashes
      file_name = (root + "/" + file).removeprefix(dir_name).replace('\\', '/')
      zip.write(os.path.join(root, file), arcname=file_name)
  print(f"Successfully created {zip_file} from {os.path.normpath(dir_name)}/")
