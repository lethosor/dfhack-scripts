#! /usr/bin/env python
from __future__ import print_function
import argparse, os, re, shutil, sys, zipfile
from contextlib import contextmanager

def die(*args):
    print(*args)
    sys.exit(1)

def mkdir_r(path):
    try:
        os.makedirs(path)
    except OSError:
        if not os.path.isdir(path):
            raise

def zip_dir(path, dest):
    zf = zipfile.ZipFile(dest, 'w')
    for root, dirs, files in os.walk(path):
        for f in files:
            zf.write(os.path.join(root, f))
    zf.close()

@contextmanager
def chdir(path):
    oldcwd = os.getcwd()
    try:
        os.chdir(path)
        yield
    finally:
        os.chdir(oldcwd)

parser = argparse.ArgumentParser()
parser.add_argument('-o', '--overwrite', action='store_true')
args = parser.parse_args()

with open('manipulator/main.lua') as f:
    version = re.search(r'VERSION\s*\=.+?([\.\d]+)', f.read()).group(1)

dirname = 'manipulator-%s' % version
full_dirname = 'pkg/manipulator/' + dirname
mkdir_r('pkg/manipulator')
if os.path.exists(full_dirname + '.zip'):
    if not args.overwrite:
        die('Would overwrite %s.zip' % full_dirname)
    else:
        if os.path.exists(full_dirname):
            shutil.rmtree(full_dirname)
        os.remove(full_dirname + '.zip')

shutil.copytree('manipulator', full_dirname + '/manipulator')
os.mkdir(full_dirname + '/gui')
shutil.copy('gui/manipulator.lua', full_dirname + '/gui/manipulator.lua')
with chdir('pkg/manipulator'):
    zip_dir(dirname, dirname + '.zip')
shutil.rmtree(full_dirname)
