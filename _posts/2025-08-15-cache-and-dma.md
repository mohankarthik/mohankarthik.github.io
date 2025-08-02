---
layout: single
title:  "Cache and DMA: A Match Made in Hell"
date:   2025-08-15 10:00:00 +0530
categories: engineering
tags: embedded
toc: true
---

# **Cache and DMA: A Match Made in Hell**

## **Introduction: The Unseen Accelerators**

In the world of embedded systems, performance is paramount. Two of the most powerful tools in our arsenal for boosting performance are the **CPU Cache** and **Direct Memory Access (DMA)**. On their own, they are marvels of engineering. The cache provides the CPU with lightning-fast access to frequently used data, breaking the bottleneck of slow main memory. DMA, on the other hand, liberates the CPU from the tedious task of shuffling data between peripherals and memory, allowing it to focus on more important computations.

They are the silent workhorses that make our modern, high-performance embedded systems possible. But when these two powerful forces interact with the same region of memory, they can create some of the most subtle, frustrating, and difficult-to-debug bugs imaginable. This isn't a simple software bug; it's a fundamental conflict in how the system views the state of memory. This is one variant of a problem of **cache coherency**.

## **A Quick Primer on Cache and DMA**

Before diving into the conflict, let's quickly recap how each component works.

### **How a CPU Cache Works**

A CPU cache is a small, extremely fast block of memory (SRAM) that sits between the CPU core and the much slower main memory (DRAM). It stores copies of frequently accessed data from main memory. When the CPU needs to read data, it checks the cache first. If the data is there (a "cache hit"), it gets it almost instantly. If not (a "cache miss"), it fetches the data from main memory, brings it into the cache, and then provides it to the CPU. This simple mechanism dramatically speeds up most operations, as the CPU avoids the long wait times associated with accessing main memory.

*Source: [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Cache_operation.svg)*

### **How DMA Works**

A Direct Memory Access (DMA) controller is like a secondary, specialized processor dedicated to moving data. Without DMA, if a peripheral (like an ADC) needs to send data to RAM, the CPU has to stop what it's doing, read the data from the peripheral's register, and write it to RAM, byte by byte. A DMA controller automates this. The CPU simply tells the DMA controller the source address (the peripheral), the destination address (the buffer in RAM), and the amount of data to transfer. The DMA then handles the entire transfer on its own, directly accessing main memory and signaling the CPU with an interrupt only when the entire block of data has been moved.

*Source: [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:DMA_block_diagram.svg)*

*For a deeper dive into the fundamentals, here are some excellent resources on [CPU Caching](https://lwn.net/Articles/252125/) and [Direct Memory Access (DMA)](https://www.eetimes.com/dma-fundamentals-1-what-is-dma/).*

## The Problem

To understand why this conflict happens, we need to understand one key concept: a CPU with a cache doesn't always see the "true" state of main memory (RAM). It sees its own fast, local copy. This is usually fine, but DMA operates directly on the main memory, completely bypassing the CPU and, crucially, its cache.

This creates two failure scenarios:

1. **CPU Writes, DMA Reads (Stale Data in RAM):**  
   * The CPU prepares a data buffer to be sent out by a peripheral (e.g., an Ethernet packet). It writes the data.  
   * If the cache is in "[write-back](https://www.geeksforgeeks.org/computer-organization-architecture/write-through-and-write-back-in-cache/)" mode (the most common for performance), the new data is **only written to the cache**, not immediately to RAM. The cache marks this data as "dirty."  
   * You then instruct the DMA controller to send the data from the buffer in RAM.  
   * The DMA, which normally knows nothing about the CPU's cache, reads the buffer directly from RAM. It reads the old, stale data because the new "dirty" data is still sitting in the cache.  
   * **Result:** The Ethernet peripheral sends out a corrupted or empty packet.  
2. **DMA Writes, CPU Reads (Stale Data in Cache):**  
   * A peripheral (e.g., an ADC) uses DMA to write incoming sensor data into a buffer in RAM.  
   * The DMA transfer completes, and the new data is now sitting in RAM. The DMA engine notifies the CPU application via an Interrupt.  
   * The CPU, which previously accessed this buffer, now goes to read the new data.  
   * However, the CPU already has the *old* contents of that buffer in its cache. It sees a "cache hit" and reads the stale data from its cache, never bothering to check the updated RAM.  
   * **Result:** The CPU processes old, incorrect data, completely oblivious to the new information the peripheral just provided.

The same as above is also applicable in MDMA (memory to memory DMA) where two applications are trying to transfer data between their memory regions using hardware offload.

## Approaches

So, how do we solve this? There are three main strategies, each with its own trade-offs.

### Option 1: Manual Cache Management (The Brute Force Method)

The most direct approach is to manually force the cache and main memory to synchronize. This involves two main operations:

* **Cache Cleaning (or Flushing):** This forces "dirty" data in the cache to be written back to main memory. You do this *before* a DMA read from memory (the "CPU Writes, DMA Reads" scenario).  
* **Cache Invalidation:** This marks the contents of the cache as invalid, forcing the CPU to fetch fresh data from main memory on its next access. You do this *after* a DMA write to memory (the "DMA Writes, CPU Reads" scenario).

While this works, it comes at a significant performance cost. Cache maintenance operations are expensive. They often require the CPU to halt other operations and can saturate the memory bus. As [this analysis on an ARM Cortex-M7 shows](https://www.google.com/search?q=https://community.st.com/t5/stm32-mcus-products/dma-and-cache-coherency-on-stm32h7-series/td-p/64462), a cache clean operation can take **hundreds of cycles** for even a moderately sized buffer, potentially negating the very performance benefit you were trying to achieve.

### Option 2: Hardware Cache Coherency (The Expensive Method)

On high-end application processors (like [ARM's Cortex-A series with its AMBA architecture](https://www.google.com/search?q=https://developer.arm.com/documentation/101211/0100/Introduction-to-the-AMBA-AXI-Coherency-Extensions)), the hardware can handle this automatically. These systems often include a **Cache Coherency Interconnect (CCI)** or, in newer systems, a **Coherent Mesh Network (CMN)**. This hardware "snoops" the memory bus. When it sees a DMA controller trying to access a memory location that a CPU has cached, it automatically forces the necessary clean or invalidate operations. This is powerful, but it's complex and expensive, which is why you rarely find it on resource-constrained microcontrollers.

### Option 3: Disable Cache (My Preferred Method)

This is, in my opinion, the cleanest, safest, and often most efficient solution. The vast majority of DMA buffers are for "streaming" data—data that is written once and read once (like a network packet or an audio buffer). Caching this kind of data provides almost no performance benefit, as you're unlikely to get a cache hit on it anyway.

The solution is to tell the hardware to never cache that memory region in the first place. By placing your DMA buffers in a region of RAM that is explicitly marked as non-cacheable, you eliminate the problem entirely. The CPU and the DMA controller will always see the exact same state of memory because there is no cache to create a second, conflicting copy.

## How to Do It

Here’s how you can implement these strategies on popular architectures.

### Bare-metal / RTOS on ARM Cortex-M (e.g., STM32H7)

On these microcontrollers, the most robust method is to use the linker script and the Memory Protection Unit (MPU) together to create a dedicated, non-cacheable memory region for DMA.

* Step 1: Define a DMA Memory Region in the Linker Script (GNU LD)  
  First, you define a specific section in your linker script (.ld file) for DMA buffers and place it in a distinct RAM region. Many MCUs have multiple RAM blocks, which is ideal for this.

```
  /\* In your linker script (e.g., STM32H750XB\_FLASH.ld) \*/  
  MEMORY  
  {  
    RAM\_D1 (xrw)      : ORIGIN \= 0x24000000, LENGTH \= 512K /\* Main cached RAM \*/  
    RAM\_D2 (xrw)      : ORIGIN \= 0x30000000, LENGTH \= 288K /\* Let's use this for non-cached DMA \*/  
    FLASH (rx)        : ORIGIN \= 0x08000000, LENGTH \= 128K  
  }

  SECTIONS  
  {  
    /\* ... other sections ... \*/

    /\* Section for DMA buffers, placed in the dedicated RAM\_D2 region \*/  
    .dma\_buffers (NOLOAD) :  
    {  
      . \= ALIGN(4);  
      \*(.dma\_buffers)  
      \*(.dma\_buffers\*)  
      . \= ALIGN(4);  
    } \> RAM\_D2  
  }
```

  Then, in your C code, you can place buffers in this section using an attribute:  
```
uint8\_t my\_dma\_buffer\[1024\] \_\_attribute\_\_((section(".dma\_buffers")));
```

* Step 2: Configure the MPU to Make the Region Non-Cacheable  
  Next, in your system startup code (e.g., SystemInit() which is called before main), you configure the MPU to apply non-cacheable attributes to the entire RAM region you designated for DMA.
```
  /\* In your system\_stm32h7xx.c or similar startup file \*/  
  // Conceptual MPU configuration for the RAM\_D2 region  
  MPU\_Region\_InitTypeDef MPU\_InitStruct;

  HAL\_MPU\_Disable();

  // Configure the main RAM (RAM\_D1) as cacheable  
  // ... MPU config for 0x24000000 ...

  // Configure the DMA RAM (RAM\_D2) as non-cacheable  
  MPU\_InitStruct.Enable \= MPU\_REGION\_ENABLE;  
  MPU\_InitStruct.BaseAddress \= 0x30000000; // Start of RAM\_D2  
  MPU\_InitStruct.Size \= MPU\_REGION\_SIZE\_256KB; // Cover the region  
  MPU\_InitStruct.AccessPermission \= MPU\_REGION\_FULL\_ACCESS;  
  MPU\_InitStruct.IsBufferable \= MPU\_ACCESS\_NOT\_BUFFERABLE;  
  MPU\_InitStruct.IsCacheable \= MPU\_ACCESS\_NOT\_CACHEABLE; // The magic bit\!  
  MPU\_InitStruct.IsShareable \= MPU\_ACCESS\_NOT\_SHAREABLE;  
  MPU\_InitStruct.Number \= MPU\_REGION\_NUMBER1; // Use a different region number  
  MPU\_InitStruct.TypeExtField \= MPU\_TEX\_LEVEL0;  
  MPU\_InitStruct.SubRegionDisable \= 0x00;  
  MPU\_InitStruct.DisableExec \= MPU\_INSTRUCTION\_ACCESS\_ENABLE;  
  HAL\_MPU\_ConfigRegion(\&MPU\_InitStruct);

  HAL\_MPU\_Enable(MPU\_PRIVILEGED\_DEFAULT);
```

* Alternative: Manual Flush/Invalidate  
  If you must use cached memory, the CMSIS core headers provide standard functions.
```
  // Before a DMA read from a buffer the CPU wrote to:  
  SCB\_CleanDCache\_by\_Addr((uint32\_t\*)buffer\_address, buffer\_size);

  // After a DMA write to a buffer the CPU will read from:  
  SCB\_InvalidateDCache\_by\_Addr((uint32\_t\*)buffer\_address, buffer\_size);
```

### Linux on ARM Cortex-A (e.g., Raspberry Pi)

In a Linux environment with a Memory Management Unit (MMU), the kernel abstracts this away for you through its DMA API. You should not be manually flushing caches from user space.

* **Coherent Memory:** The preferred method is to request a special type of memory that is guaranteed to be coherent. The kernel handles making it non-cacheable or ensures proper flushing. See the [Kernel Documentation for dma\_alloc\_coherent](https://www.google.com/search?q=%5Bhttps://www.kernel.org/doc/html/latest/core-api/dma-api.html%5D\(https://www.kernel.org/doc/html/latest/core-api/dma-api.html\)).

```
  // Request a coherent DMA buffer  
  dma\_addr\_t dma\_handle;  
  void \*cpu\_addr \= dma\_alloc\_coherent(dev, size, \&dma\_handle, GFP\_KERNEL);
```

* **Streaming DMA:** For single-shot transfers, you use the streaming DMA API. The dma\_map\_single() function takes a buffer you allocated (e.g., with kmalloc) and does whatever is necessary (flushing, creating a bounce buffer, etc.) to make it safe for DMA. See the [Kernel Documentation for dma\_map\_single](https://www.google.com/search?q=%5Bhttps://www.kernel.org/doc/html/latest/core-api/dma-api.html%5D\(https://www.kernel.org/doc/html/latest/core-api/dma-api.html\)).
```
  // Prepare a buffer for a CPU-to-peripheral DMA transfer  
  dma\_handle \= dma\_map\_single(dev, cpu\_addr, size, DMA\_TO\_DEVICE);

  // After the transfer, unmap it  
  dma\_unmap\_single(dev, dma\_handle, size, DMA\_TO\_DEVICE);
```

By using these kernel APIs correctly, you ensure that cache coherency is handled for you in the most efficient way for the underlying hardware.