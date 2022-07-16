// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

// #include "firmware.h"
// Include the stats helper functions up front so they can also be used
// inside the nj* functions to profile if needed


// #include "njmem.c"
// define and include for nanojpeg
// #define NJ_USE_LIBC 0
// #define NJ_USE_WIN32 0
// #include "nanojpeg.c"

// Routines for outputing the final PPM
// #include "njppmprint.c"

// Conv functions
#include "conv.c"

#define CONV_BASE 0x60000000
#define RESULT_BASE 0x50000000
#define START_SIG 0x01
#define TIMEOUT 100000

void Conv_StartAndWait(void);
unsigned char Conv_GetResult(void);

void Conv_StartAndWait(void)
{
	volatile int *p = (int *)CONV_BASE;
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
	while (!rdy && (count < TIMEOUT)) {
		volatile int x = (*p); // read from MULT_BASE
		if ((x & 0x01) == 1) rdy = true;
		count ++;
	}
	if (count == TIMEOUT) {
		print_str("TIMED OUT: did not get a 'rdy' signal back!");
	}
}

unsigned char Conv_GetResult(void)
{
	volatile unsigned char *p = (unsigned char *)RESULT_BASE;
	return (*p);
}

void hello(void)
{
	// Run baseline convolution on varying image sizes
<<<<<<< HEAD
<<<<<<< HEAD
	for (int i=10; i<20 ; i += 10)
=======
	for (int i=10 ; i<200 ; i += 10)
>>>>>>> 7814bb9 (Added readmemh for taking custom image)
=======
	for (int i=10 ; i<20 ; i += 10)
>>>>>>> 0e5f741 (Add accelerator driver code)
	{
		conv_test(i,i,5);
	}

<<<<<<< HEAD
	// Run 200x200 conv (very slow, around 10 mins to get result)
	// conv_test(200,200,5);
	print_str("\nBaseline tests done...\n");
	

	// Accelerator part
	Conv_StartAndWait();
	unsigned char res;
	res = Conv_GetResult() ;
=======
	print_str("\nBaseline tests done...\n");
	
	Conv_StartAndWait();
	unsigned char res;
<<<<<<< HEAD
	res = Conv_GetResult();
>>>>>>> 0e5f741 (Add accelerator driver code)
=======
	res = Conv_GetResult() ;
>>>>>>> 1b5abf6 (More debugs)
	print_str("Conv first pixel: ");
	print_dec(res);
	print_str("\n");
	print_str("\nAccel test done...\n");

}

