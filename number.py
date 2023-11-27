#!/usr/bin/python3

# number.py takes a non-numbered BASIC program with LABELs i
# and outputs a nicely numbered file

import re
import sys

def wline(s):
    if outfile:
        outfile.write(s)
    else:
        print(s)

def wtmp(s):
    tmpfile.write(s)

def usage():
    print("usage : ")
    print(sys.argv[0]+" <input file> [output file]")
    print("")
    print("  output file is optional - will print to stdout otherwise")

filename=""
outfilename=""
outfile = 0
tmpfile = 0

if len(sys.argv[1:]) == 0:
    usage()
    quit()

filename=sys.argv[1]
print("Process file : "+filename)

if len(sys.argv[2:]) != 0:
    outfilename=sys.argv[2]
    print("Write to : "+outfilename)
    outfile=open(outfilename,"w")

tmpfilename = "/tmp/renum.tmp"
tmpfile = open(tmpfilename,"w")

infile = open(filename, "r")
if not infile:
    if outfile: 
        outfile.close()
    if tmpfile: 
        tmpfile.close()
    print("Failed to open file "+filename) 
    quit()

lnum=10
pat_proc = re.compile("DEF PROC[a-zA-Z]+")
pat_fn = re.compile("DEF FN[a-zA-Z]+")
pat_empty = re.compile("^\s*$")
pat_label = re.compile("^(LABEL\w+):")
pat_labelref = re.compile("(LABEL\w+)(?!:)\s")
pat_sep = re.compile ("REM\s*---")

labs = {}

# Pass 1 write tmp file
for fline in infile.readlines():
    if pat_empty.match(fline):
        continue

    if pat_proc.search(fline) or pat_fn.search(fline):
        r=(lnum+100) % 100
        lnum=(lnum+100-r)
        wtmp("\n")
    if pat_sep.search(fline):
        wtmp("\n")

    m = re.match(pat_label, fline)
    if m:
        labs.update({m.group(1): str(lnum)})
        wtmp(str(lnum) +" REM " + fline)
    else:
        wtmp(str(lnum) +" " + fline)

    lnum=lnum+10

tmpfile.close()

# Pass 2, sort out referenes to labels
print("Labels:")
for l,n in labs.items():
    print(l,n)

tmpfile = open(tmpfilename,"r")
for tline in tmpfile.readlines():
    m = re.search(pat_labelref, tline)
    if m:
        wline(tline.replace(m.group(1),labs[m.group(1)]))
    else:
        wline(tline)

# Close everything
infile.close()
if outfile: 
    outfile.close()
if tmpfile: 
    tmpfile.close()
