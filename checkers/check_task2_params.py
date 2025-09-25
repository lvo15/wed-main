#! /usr/bin/env python3

import sys

line = sys.argv[1]
xval = 0

key,val = line.split('=',1)

key = key.strip()
val = val.strip()

if not key.islower():
    xval += 1
    key = key.lower()
    print("[Parameters checker] Keys should be all lowercase (-1)", file=sys.stderr)

if key.find('-') >= 0:
    xval += 1
    key = ''.join(key.split('-'))
    print("[Parameters checker] Keys should not have dashes (-1)", file=sys.stderr)

if '"user"' == key:
    xval += 1
    key = "name"
    print("[Parameters checker] Key should be 'name', not 'user' (-1)", file=sys.stderr)

print('[{}]=[{}]'.format(key.strip(),val.strip()))
exit(xval)
