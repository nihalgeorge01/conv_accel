#include "firmware.h"
#include "njmem.c"
#include "stats_helper.c"

#define RESULT_BASE 0x50000000
#define CONV_BASE 0x60000000
#define READY_BASE 0x60000000
#define START_SIG 0x01
#define TIMEOUT 100000

// Protos
int conv_baseline(unsigned char * im_start, signed char * k_start, unsigned char * res_start, int im_size_x, int im_size_y, int k_size);
int next_mul_4(int val);
int conv_test(int im_size_x, int im_size_y, int k_size);
void Conv_StartAndWait(void);
unsigned char Conv_GetResult(void);

// Defs
int conv_baseline(unsigned char * im_start, signed char * k_start, unsigned char* res_start, int im_size_x, int im_size_y, int k_size)
{   
    /*
    Peforms convolution of rect image with odd-length square kernel, with zero padding to preserve size
    Naive baseline algorithm
    No error handling for now. Possible improvements --
        1. Report if image too small for given kernel
        2. Need proper way of ahndling even length filters
    */

	int sum_here, cur_x, cur_y, im_val, ker_val;
	int ksb2 = k_size/2;
	for (int kx=0; kx<im_size_x; ++kx)
	{
		for (int ky=0; ky<im_size_y; ++ky)
		{
			sum_here = 0;
			for (int ix=-ksb2; ix<=ksb2; ++ix)
			{
				for (int iy=-ksb2; iy<=ksb2; ++iy)
				{	
					cur_x = kx + ix;
					cur_y = ky + iy;

					if (cur_x >= 0 && cur_y >= 0 && cur_x < im_size_x && cur_y < im_size_y)
					{// valid image pixel, sum_here += image_pixel * kernel value
						im_val = *(im_start + im_size_x*cur_x + cur_y);
						ker_val = *(k_start + k_size*(ix+ksb2) + (iy+ksb2));
						sum_here += im_val * ker_val;
					}
				}
			}
			*(res_start + im_size_x*kx + ky) = (unsigned char) sum_here;
		}
	}
    return 0;
}

int next_mul_4(int val)
{
    int rem = val & (0x3);
    int a_val = val & (~(0x3));
    if (rem != 0) a_val += 4;
    return a_val;
}

int conv_test(int im_size_x, int im_size_y, int k_size)
{
	print_str("\n[INFO] Testing conv on ");
	print_dec(im_size_x);
	print_str("x");
	print_dec(im_size_y);
	print_str(" image, and kernel length ");
	print_dec(k_size);
	print_str("\n");

	int t0, t1;
	int i0, i1;
	int k_area = k_size*k_size;
	int im_area = im_size_x*im_size_y;
	
	// Alloc mem for image, note down actual size after safely allocating a multiple of 4 bytes
	unsigned char* im_start = (unsigned char*) njAllocMem(im_area);
	int im_asize = next_mul_4(im_area);

	// Populate values of image
	njFillMem(im_start, 127, im_asize);
	// print_str("[SANITY] image pixel 0,0: ");
	// print_dec(*(im_start));
	// print_str("\n");

	// Alloc mem for 3x3 kernel, each value signed char so 1 byte per pixel
	// Using sharpen filter (check wiki)
	signed char* k_start = (signed char*) njAllocMem(k_area);
	int k_asize = next_mul_4(k_area);

	if (k_size == 3)
	{
		// Populate values of sharpen kernel. Done manually since declaring array needs malloc and we use njAllocMem instead
		// njFillMem(k_start, 1, k_asize);
		*(k_start + 0) =  0;	*(k_start + 1) = -1;	*(k_start + 2) =  0;

		*(k_start + 3) = -1;	*(k_start + 4) =  5;	*(k_start + 5) = -1;

		*(k_start + 6) =  0;	*(k_start + 7) = -1;	*(k_start + 8) =  0;
	}
	else if (k_size == 5)
	{
		// Populate values of sharpen kernel. Done manually since declaring array needs malloc and we use njAllocMem instead
		// njFillMem(k_start, 1, k_asize);
		*(k_start + 0)  = -1;	*(k_start + 1)  = -1;	*(k_start + 2)  = -1;	*(k_start + 3)  = -1;	*(k_start + 4)  = -1;

		*(k_start + 5)  = -1;	*(k_start + 6)  = -1;	*(k_start + 7)  = -1;	*(k_start + 8)  = -1;	*(k_start + 9)  = -1;

		*(k_start + 10) = -1;	*(k_start + 11) = -1;	*(k_start + 12) = 25;	*(k_start + 13) = -1;	*(k_start + 14) = -1;

		*(k_start + 15) = -1;	*(k_start + 16) = -1;	*(k_start + 17) = -1;	*(k_start + 18) = -1;	*(k_start + 19) = -1;

		*(k_start + 20) = -1;	*(k_start + 21) = -1;	*(k_start + 22) = -1;	*(k_start + 23) = -1;	*(k_start + 24) = -1;	
	}
	else
	{	// Filter not supported
		return 1;
	}

	// Kernel sanity check
	// print_str("[SANITY] ker pixel 1,1: ");
	// print_dec(*(k_start + k_size + 1));
	// print_str("\n");
	
	// Alloc mem for result image (same size as original due to zero padding)
	unsigned char* res_start = (unsigned char*) njAllocMem(im_area);

	// Main convolution part with timing
	t0 = get_num_cycles();
	i0 = get_num_instr();
	conv_baseline(im_start, k_start, res_start, im_size_x, im_size_y, k_size);
	i1 = get_num_instr();
	t1 = get_num_cycles();

	// Result sanity check, first two result pixels
	// int p00 = *(res_start);
	// int p01 = *(res_start + 1);
	// print_str("[SANITY] p00, p01: ");
	// print_dec(p00);
	// print_str(", ");
	// print_dec(p01);
	// print_str("\n");

	// Free mem of result, kernel and image in reverse order
	njFreeMem((void *) res_start, im_asize);
	njFreeMem((void *) k_start, k_asize);
	njFreeMem((void *) im_start, im_asize);

	print_str("[INFO] Convolved in ");
	print_dec(t1-t0);
	print_str(" cycles and ");
	print_dec(i1-i0);
	print_str(" instructions.\n");

	return 0;
}

void Conv_StartAndWait(void)
{
	volatile int *p = (int *)CONV_BASE;
	volatile int *cv_ready = (int *)READY_BASE;
	// Set the "reset" signal to 1 - assume the LSB bit of MULT_BASE
	// is connected to the "reset" signal
	*p = START_SIG; 
	// Remove the reset signal.  Since each instruction anyway takes
	// multiple cycles, the reset will be high for at least one clock
	// which is enough
	// *p = 0;
	// Keep reading back from MULT_BASE and check if the LSB is set to 1
	// If the "rdy" signal is connected to the LSB, this should happen
	// after multiplication is complete.
	// Note: you can condense all the code below into a single line.
	// It is written this way for clarity, not efficiency.
	bool rdy = false;
	int count = 0;
	int t0, t1;
	t0 = get_num_cycles();
	while (!rdy && (count < TIMEOUT)) {
		volatile int x = (*cv_ready); // read from MULT_BASE
		if ((x & 0x01) == 1) {
			rdy = true;
			t1 = get_num_cycles();
		}
		count ++;
	}

	if (count == TIMEOUT) {
		print_str("TIMED OUT: did not get a 'rdy' signal back!");
	}
	else
	{
		print_str("Accelerator convolved in ");
		print_dec(t1-t0);
		print_str(" cycles.\n");
	}
}

unsigned char Conv_GetResult(void)
{
	volatile unsigned char *p = (unsigned char *)RESULT_BASE;
	return (*p);
}
