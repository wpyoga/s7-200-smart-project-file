#!/usr/bin/python3

# this script extracts the zip file containing non-portable Windows backslash directory separators using portable directory separators
# it also creates the root folder automatically

import sys
import os
from zipfile import ZipFile
from xml.dom import minidom


zip_file = sys.argv[1]
zip_basename = os.path.basename(zip_file)
zip_dirname, zip_ext = os.path.splitext(zip_basename)

os.mkdir(zip_dirname)

# need to specify GBK as encoding, otherwise Chinese characters will be malformed
# the file entries (references) in project.devproj is still UTF-8 though,
# which is consistent with the XML declaration on the first line
# do we need to convert back to GBK when writing the zip file?
with ZipFile(zip_file, 'r', metadata_encoding="gbk") as zip:
  for member in zip.infolist():
    member.filename = member.filename.replace('\\', '/')
    # zip.extract(member, zip_dirname)
    # TODO: accept a command-line parameter to skip formatting and get the raw bytes instead
    member_root, member_ext = os.path.splitext(member.filename)
    if member_ext.lower() in ['.xml', '.devproj', '.smartprojs']:
      xml_data = minidom.parseString(zip.read(member))
      os.makedirs(os.path.join(zip_dirname, os.path.dirname(member.filename)), exist_ok=True)
      with open(os.path.join(zip_dirname, member.filename), "xb") as f:
        f.write(xml_data.toprettyxml(indent='  ', encoding=xml_data.encoding))
    else:
      zip.extract(member, zip_dirname)
  print(f"Successfully extracted {zip_file} into {zip_dirname}/")
