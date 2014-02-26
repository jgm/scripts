#!/usr/bin/env python

# Uploads contents of stdin with name derived from first argument
# Assumes ZOTERO_KEY and ZOTERO_USER are set

from pyzotero import zotero
# import json
import sys
import os
import os.path
import tempfile

if len(sys.argv) < 2:
  sys.stderr.write("Give filename as first argument")
  sys.exit(1)
else:
  nicename = sys.argv[1]

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

try:
  tmpdir = tempfile.mkdtemp()
  tmpfile = tmpdir + "/" + nicename
  f = open(tmpfile, 'w')
  f.write(sys.stdin.read())
  sys.stdin.flush()
  f.flush()
  f.close
  zot.attachment_simple([tmpfile])
finally:
  os.remove(tmpfile)

sys.exit(0)
