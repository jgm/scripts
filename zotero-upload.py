#!/usr/bin/env python

# Uploads files specified on the command line to zotero
# Assumes ZOTERO_KEY and ZOTERO_USER are set

from pyzotero import zotero
# import json
import sys
import os

if len(sys.argv) < 2:
  sys.stderr.write("No filenames specified\n")
  sys.exit(1)

try:
  key = os.environ['ZOTERO_KEY']
except KeyError:
  sys.stderr.write("ZOTERO_KEY environment variable must be set\n")
  sys.exit(1)

try:
  user = os.environ['ZOTERO_USER']
except KeyError:
  sys.stderr.write("ZOTERO_USER environment variable must be set\n")
  sys.exit(1)

zot = zotero.Zotero(user, 'user', key, True)

# def prettyprint(x):
#   print(json.dumps(x, sort_keys=False, indent=2, separators=(',', ': ')))

zot.attachment_simple(sys.argv[1:])
sys.exit(0)

