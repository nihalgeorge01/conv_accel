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
# Usage: 
# python/python3 jpg2gray2bytes.py [jpg image] > [output hex file]
# e.g. python kitten.jpg > kitten.hex

from sys import argv
import cv2

MAX_BYTES = 2**24

try:
    inpath = argv[1] 
except IndexError:
    inpath = './firmware/kitten.jpg'

# try:
#     outpath = argv[2]
# except IndexError:
#     outpath = './firmware/gray_bytes.hex'

# load as grayscale
im_arr = cv2.imread(inpath, 0)
# print(im_arr.shape)

im_x = im_arr.shape[0]
im_y = im_arr.shape[1]
im_xb = im_x.to_bytes(1,'big')
im_yb = im_y.to_bytes(1,'big')
im_bytes = im_arr.tobytes()
filesize = len(im_bytes)
<<<<<<< HEAD
<<<<<<< HEAD
# print(filesize)
=======
>>>>>>> 7814bb9 (Added readmemh for taking custom image)
=======
# print(filesize)
>>>>>>> 8cb865b (Debug some errors)
bytes_total = im_xb + im_yb + im_bytes

# outfile = open(outpath, 'wb')
# outfile.write()
# outfile.write(bytes_total[:MAX_BYTES])
# outfile.close()

print("%08x" % filesize)
<<<<<<< HEAD
for i in range(filesize):
    w = im_bytes[i]
    print("%02x" % (w))
tail_str = "%02x" % (0)
# print(tail_str*(MAX_BYTES-filesize-1))
for i in range(MAX_BYTES-filesize-1):
<<<<<<< HEAD
    print(tail_str)
=======
for i in range(MAX_BYTES-1):
    if i < filesize:
        w = im_bytes[i]
        print("%02x" % (w))
    else:
        print("%02x" % 0)

<<<<<<< HEAD
>>>>>>> 7814bb9 (Added readmemh for taking custom image)
=======
print("00\n"*(MAX_BYTES-filesize))
>>>>>>> 08957e5 (faster jpg to hex generator)
=======
    print(tail_str)
>>>>>>> 8cb865b (Debug some errors)
