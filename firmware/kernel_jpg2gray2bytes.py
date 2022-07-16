#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

# Convert a JPG file to grayscale bytes for Verilog - 1st byte is row_ct, 2nd byte is col_ct 
# Limit memory to 1M = 256*1024*4
# Needs opencv

from sys import argv

MAX_BYTES = 25


<<<<<<< HEAD
# kernel_values = [0,-1,0,-1,5,-1,0,-1,0] + [0]*16
# Edit here to change filter values, write in row major
kernel_values = [1]*25
=======
kernel_values = [0,-1,0,-1,5,-1,0,-1,0] + [0]*16
>>>>>>> 7814bb9 (Added readmemh for taking custom image)
kernel_bytes = [i.to_bytes(1, byteorder='big', signed=True) for i in kernel_values]
k_bytes = b''
for i in kernel_bytes:
    k_bytes += i
filesize = len(k_bytes)

print("%08x" % filesize)
for i in range(MAX_BYTES-1):
    if i < filesize:
        w = k_bytes[i]
        print("%02x" % (w))
    else:
        print("%02x" % 0)

