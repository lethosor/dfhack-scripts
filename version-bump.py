#! /usr/bin/env python

from __future__ import print_function
import os, re, subprocess, sys

def die(s):
    print(s)
    sys.exit()

if len(sys.argv) < 3:
    die('Usage: version-bump.py FILE VERSION')
path = sys.argv[1]
short_filename = os.path.splitext(os.path.split(path)[-1])[0]
new_version = sys.argv[2]
if not os.path.isfile(path):
    die('Not found: ' + path)

# Avoid making changes in a dirty tree
if len(subprocess.check_output(["git", "status", "--porcelain"])):
    die("Tree is dirty - commit or stash changes first")

with open(path, 'r') as f:
    contents = f.read()
contents = re.sub(r"VERSION = '[^']+'", "VERSION = '%s'" % new_version, contents)
with open(path, 'w') as f:
    f.write(contents)

subprocess.call(["git", "add", path])
subprocess.call(["git", "commit", "-m", "Bump %s to %s" % (short_filename, new_version)])
