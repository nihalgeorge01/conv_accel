# Convolution Accelerator Peripheral  
EE2003 Computer Organization July-Nov 2021  
Authors: Jayakar Reddy, Nihal John George, Abhigyan Chattopadhyay -- EE19B {028, 131, 146}

*Note*: This is a forked repository of PicoRV32 - the original README is available at [[README_picorv32.md]].

Acknowledgements:

- [PicoRV32](https://github.com/YosysHQ/picorv32) - from C. Wolf (YosysHQ).  
- [NanoJPEG](https://keyj.emphy.de/nanojpeg/)


## Problem statement

Convolution is a commonly used operation in most image processing and machine learning workflows, among various others. However, on general-purpose computing hardware (CPUs), this process needs multiple levels of software optimization to run quickly enough.

We aim to build a basic proof-of-concept accelerator hardware to provide a significant speedup over existing software implementations, using pipelining and dedicated hardware to perform the convolution.

## Proposed Solution

General-purpose CPU hardware is optimized to perform general computations serially with multiple repeated memory accesses.

We propose a solution where the hardware can perform any number of multiplications required for up to 5x5 convolutions in parallel, and then add them using a multi-level tree adder, all while the next multiplication is carried out, after which its results are sent over to the first layer of the tree adder while the previous results are being added in the next layer, through pipelining.

The result is that, while there is some input lag between the first input and the first output, the entire image is convolved over in O(l*m) cycles, where l = (Image Width - Filter size + 1) and m = (Image Height - Filter size + 1) cycles.

The speedup gained is mainly due to the parallel multiplications and the pipelining of various steps.

## How to run

### Running the Convolution (Baseline Slow Code):

There are 2 versions of code available in the file `hello.c`. The naive version is available on line 28 `(conv_test())`, and the accelerated version starts on line 39 (`Conv_StartAndWait()`).

You can change the image generation and the kernel in the `conv_test()` function to perform convolutions using naive slow code.

By default, a uniform image will be generated with all the same pixel values, of increasing sizes (10x10, 20x20 and so on until 200x200). This will be convolved with a 5x5 sharpen filter and the number of cycles taken will be displayed for each.


### Preparing your image for use:

__NOTE__: OpenCV for Python is required for this step.

Take an image (supports only up to 200x200 pixels, only .jpg format was tested to work) and convert it into a hex file using the `jpg2gray2bytes.py` file available in the `firmware` folder.

#### Example:

`python jpg2gray2bytes.py image.jpg > image.hex`

(Run in the firmware folder)

Here `image.jpg` is your chosen 200x200 file, `image.hex` is your hex file that you can use for convolution.

### Prepare your kernel/filter coefficients:

Open up the file `kernel_jpg2gray2bytes.py` and edit line 21 to your own kernel values, and run the python script.

#### Example:

`python kernel_jpg2gray2bytes.py > coeffs.hex`

(Run in the firmware folder)

### Running the Convolution

Run `make test_verilator` in the root folder.
