// memory management for nanojpeg
// directly #include'd into the main file for simplicity
#define NULL ((void *)0)
#define JPGBASE 0x30000000
#define MEMBASE 0x40000000
void *base = (void *)MEMBASE;
void* njAllocMem(int size);
void njFreeMem(void* block, int asize);
void njFillMem(void* block, unsigned char byte, int size);
void njCopyMem(void* dest, const void* src, int size);
void* njAllocMem(int size)
{
	// Always allocate mult of 4 to be safe
	int rem = size & (0x3);       
	int asize = size & (~(0x3));  // Mask off LSB 2 bits
	if (rem != 0) asize += 4;     // round up to multiple of 4
	void *ret = base;
	base = (void *)((int)base + asize);
	return ret;
}
void njFreeMem(void* block, int asize)
{
	// standalone code - no concept of memory leaks 
	(void)(block);
	// bring base pointer back to allow freed memory to be reallocated
	// NOTE: Free memory in reverse order of allocation so that base is in correct location
	base = (void *)((int)base - asize);
	return;
}
void njFillMem(void* block, unsigned char byte, int size)
{
	unsigned int *p = (unsigned int *)block;
	unsigned int val = (byte << 24) | (byte << 16) | (byte << 8) | byte;
	for (int i=0; i<size/4; i++) {
		*(p+i) = val;
	}
}
void njCopyMem(void* dest, const void* src, int size)
{
	char *p = (char *)dest;
	const char *q = (const char *)src;
	for (int i=0; i<size; i++) {
		*(p+i) = *(q+i);
	}
}
