# AXI4-Lite Signal & Interface Guide

This document explains every single signal used in the AXI4-Lite UVM testbench interface (`axi4lite_if.sv`). It breaks down what each signal does, which component drives it, and how the testbench avoids simulation race conditions.

## 1. Global Signals
These are the foundational signals that synchronize the entire system.
*   **`clk`**: The master system clock. All AXI transactions are perfectly synchronized to the rising edge (`posedge`) of this clock.
*   **`rst_n`**: Active-low reset. When this is `0`, all components must instantly clear their internal queues and reset to an idle state.

---

## 2. The 5 AXI4-Lite Channels

The AXI4-Lite protocol groups its signals into 5 distinct "channels". Every channel uses a fundamental **VALID/READY** handshake.
*   **`VALID`**: Driven by the Sender. Means "I have put valid data on the bus, please take it."
*   **`READY`**: Driven by the Receiver. Means "I am not busy. I will accept the data on the next rising clock edge."

### A. Write Address Channel (AW)
*Used by the Master (Driver) to tell the Slave where it wants to write data.*
*   **`awaddr` [31:0]**: The 32-bit physical memory address. Must be 4-byte aligned (e.g., ends in `0x0`, `0x4`, `0x8`, `0xC`).
*   **`awvalid`**: Master asserts this to say the `awaddr` is correct and ready.
*   **`awready`**: Slave asserts this to say it is ready to accept the address.

### B. Write Data Channel (W)
*Used by the Master (Driver) to send the actual 32-bit payload to the Slave.*
*   **`wdata` [31:0]**: The 32-bit data payload.
*   **`wstrb` [3:0]**: Write Strobes. Each bit corresponds to 1 byte of the `wdata`. If `wstrb = 4'b0001`, only the lowest 8 bits are written. If `4'b1111`, all 32 bits are written.
*   **`wvalid`**: Master asserts this to say `wdata` and `wstrb` are valid.
*   **`wready`**: Slave asserts this to say it has successfully captured the data.

### C. Write Response Channel (B)
*Used by the Slave to tell the Master if the write was successful.*
*   **`bresp` [1:0]**: The Response Code. `2'b00` (`AXI_OKAY`) means success. `2'b10` (`AXI_SLVERR`) means the slave rejected the write.
*   **`bvalid`**: Slave asserts this to say "I have finished the write and here is your status code."
*   **`bready`**: Master asserts this to say "I am listening for your response."

### D. Read Address Channel (AR)
*Used by the Master to tell the Slave what address it wants to read from.*
*   **`araddr` [31:0]**: The 32-bit physical memory address to read.
*   **`arvalid`**: Master asserts this to say the read address is valid.
*   **`arready`**: Slave asserts this to say it accepted the read request.

### E. Read Data Channel (R)
*Used by the Slave to send the requested data back to the Master.*
*   **`rdata` [31:0]**: The 32-bit requested data.
*   **`rresp` [1:0]**: The Response Code (same as `bresp`). `AXI_OKAY` means the read was successful.
*   **`rvalid`**: Slave asserts this to say the `rdata` is valid.
*   **`rready`**: Master asserts this to say "I have captured the read data."

---

## 3. How the UVM Environment Connects (Clocking Blocks)

To avoid "delta-cycle race conditions" (where the driver drives a signal at the exact same picosecond the monitor tries to read it, leading to corrupted data), the interface uses **SystemVerilog Clocking Blocks**. 

These blocks force the UVM components to interact with the signals strictly at the clock boundaries.

> [!TIP]
> **What does `#1step` mean?**
> In the clocking block, you will see `default input #1step output #1;`. This means when a UVM component reads an input, it reads the value from the picosecond *right before* the clock edge (guaranteeing it reads stable data). When it drives an output, it applies it `1ns` *after* the clock edge (guaranteeing it doesn't cause race conditions).

### The Three Modports
The interface is split into three "Views" (Modports) so each UVM component only sees what it is supposed to see:

1. **`master_cb` (Used by `axi4lite_driver.sv`)**
   - **Outputs**: `awaddr`, `awvalid`, `wdata`, `wstrb`, `wvalid`, `bready`, `araddr`, `arvalid`, `rready`
   - **Inputs**: `awready`, `wready`, `bresp`, `bvalid`, `arready`, `rdata`, `rresp`, `rvalid`
   - *Logic*: The driver pushes commands out and listens for ready/response signals.

2. **`slave_cb` (Used by `axi4lite_slave_bfm.sv`)**
   - **Outputs**: `awready`, `wready`, `bresp`, `bvalid`, `arready`, `rdata`, `rresp`, `rvalid`
   - **Inputs**: `awaddr`, `awvalid`, `wdata`, `wstrb`, `wvalid`, `bready`, `araddr`, `arvalid`, `rready`
   - *Logic*: The exact opposite of the Master. It listens for commands and pushes out responses.

3. **`monitor_cb` (Used by `axi4lite_monitor.sv`)**
   - **Inputs**: *Everything.*
   - **Outputs**: *Nothing.*
   - *Logic*: The monitor is completely passive. It cannot drive any signal. It just sits silently on the bus, observing the `VALID` and `READY` handshakes perfectly synchronized to the clock.
