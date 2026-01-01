#!/usr/bin/python3

# this script extracts the zip file containing non-portable Windows backslash directory separators using portable directory separators
# it also creates the root folder automatically

import sys
from zipfile import ZipFile
import os


zip_file = sys.argv[1]
zip_basename = os.path.basename(zip_file)
zip_dirname, zip_ext = os.path.splitext(zip_basename)

os.mkdir(zip_dirname)

with ZipFile(zip_file, 'r') as zip:
  for member in zip.infolist():
    member.filename = member.filename.replace('\\', '/')
    zip.extract(member, zip_dirname)
  print(f"Successfully extracted {zip_file} into {zip_dirname}/")
