#!/usr/bin/env python

# Uploads contents of argv[1] to zotero, with name if specified
# Assumes ZOTERO_KEY and ZOTERO_USER are set

from pyzotero import zotero
# import json
import sys
import os

if len(sys.argv) < 2:
  sys.stderr.write("Need filename as first argument")
elif len(sys.argv) == 2:
  filename = sys.argv[1]
  bettername = filename
else:
  filename = sys.argv[1]
  bettername = sys.argv[2]

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

zot.attachment_both([(bettername, filename)])

sys.exit(0)

