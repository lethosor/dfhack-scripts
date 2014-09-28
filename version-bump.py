#! /usr/bin/env python

from __future__ import print_function
import os, re, subprocess, sys

def die(s):
    print(s)
    sys.exit()

version_map = {
    'major': lambda a, b, c: [a+1, 0, 0],
    'minor': lambda a, b, c: [a, b+1, 0],
    'patch': lambda a, b, c: [a, b, c+1],
}

if len(sys.argv) < 3:
    die('Usage: version-bump.py FILE [major/minor/patch]')
path = sys.argv[1]
if sys.argv[2] not in version_map:
    die('Argument 2 must be one of: ' + ', '.join(list(version_map.keys())))
short_filename = os.path.splitext(os.path.split(path)[-1])[0]
if not os.path.isfile(path):
    die('Not found: ' + path)

# Avoid making changes in a dirty tree
if len(subprocess.check_output(["git", "status", "--porcelain"])):
    die("Tree is dirty - commit or stash changes first")

with open(path, 'r') as f:
    contents = f.read()

try:
    cur_version = [int(i) for i in re.search(r"VERSION = '([^']+)'", contents).group(1).split('.')]
except Exception:
    die('Invalid version number in ' + path)

new_version = '.'.join([str(i) for i in version_map[sys.argv[2]](*cur_version)])
contents = re.sub(r"VERSION = '[^']+'", "VERSION = '%s'" % new_version, contents)
with open(path, 'w') as f:
    f.write(contents)

subprocess.call(["git", "add", path])
subprocess.call(["git", "commit", "-m", "Bump %s to %s" % (short_filename, new_version)])
