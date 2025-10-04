```markdown
# AHB2APB_BRIDGE  

AHB2APB_BRIDGE is a complete RTL + UVM verification environment for the **AHB-to-APB Bridge Protocol**.  

It connects the high-performance **AMBA AHB bus** to the low-power **APB bus**,

enabling communication between high-speed masters and low-speed peripherals.  

```
# AHB2APB_BRIDGE
```
# AHB2APB_BRIDGE
├── circuit_diagram.png
├── TB_ARCH.png
├── rtl
│   ├── ahb_apb_top.v
│   ├── ahb_slave.v
│   ├── apb_controller.v
│   ├── apb_interface.v
│   ├── definitions.v
│   ├── master_interface.sv
│   └── slave_interface.sv
├── master_agent_top
│   ├── master_agent_config.sv
│   ├── master_agent.sv
│   ├── master_agent_top.sv
│   ├── master_driver.sv
│   ├── master_monitor.sv
│   ├── master_sequencer.sv
│   ├── master_sequence.sv
│   └── master_xtn.sv
├── slave_agent_top
│   ├── slave_agent_config.sv
│   ├── slave_agent.sv
│   ├── slave_agent_top.sv
│   ├── slave_driver.sv
│   ├── slave_monitor.sv
│   ├── slave_sequencer.sv
│   ├── slave_sequence.sv
│   └── slave_xtn.sv
├── tb
│   ├── bridge_env_config.sv
│   ├── bridge_scoreboard.sv
│   ├── bridge_tb.sv
│   ├── bridge_virtual_seqs.sv
│   ├── bridge_virtual_sequencer.sv
│   └── top.sv
├── test
│   ├── bridge_test_pkg.sv
│   └── bridge_test.sv
├── sim
│   ├── Makefile
│   └── waves.do
└── docs
    ├── README.md
    ├── protocol_notes.md
    └── design_spec.pdf
```

---

### **AHB Interface Signals (Connected via `ahb_if`)**

* **HCLK** – Clock
* **HRESETn** – Reset (active-low)
* **HTRANS** – Transaction type (IDLE, NONSEQ, SEQ, BUSY)
* **HSIZE** – Transfer size
* **HREADYin** – Ready input from previous stage
* **HWDATA** – Write data from master
* **HADDR** – Address bus
* **HWRITE** – Read/Write indicator
* **HRDATA** – Read data to master
* **HRESP** – Response from slave
* **HREADYout** – Ready output to master
---
### **APB Interface Signals (Connected via `apb_if`)**

* **PSELx** – Peripheral select
* **PWRITE** – Write enable for APB
* **PENABLE** – Transfer enable
* **PADDR** – Address bus for APB
* **PWDATA** – Write data to APB peripheral
* **PRDATA** – Read data from APB peripheral

✅ **Summary:**

* The **AHB signals** are the **master-side interface**.
* The **APB signals** are the **slave-side interface**.
* Together, these signals let the bridge translate AHB transactions into APB transactions and vice versa.

---

## **AHB Interface Signals**

### **1. HCLK (AHB Clock)**

* Input to the bridge from the AHB master.
* Synchronizes all AHB transactions.
* Every rising edge triggers evaluation of inputs and latching of outputs.

### **2. HRESETn (AHB Reset, Active Low)**

* Resets the bridge and clears internal state machines.
* Active-low: `0` means reset active, `1` means normal operation.
* All signals default to IDLE or zero during reset.

### **3. HTRANS (Transaction Type)**

* 2-bit signal defining the type of AHB transfer:

  * **IDLE (00):** No transfer; master is inactive.
  * **BUSY (01):** Bus is busy, next transfer may follow; no data transfer occurs.
  * **NONSEQ (10):** Start of a new burst transfer or standalone transfer. Address is unrelated to previous.
  * **SEQ (11):** Sequential transfer, part of a burst; address is consecutive after previous transfer.

**Usage in bridge:**

* Bridge samples HTRANS to determine if it should initiate a new APB transaction.
* IDLE/BUSY → No APB transaction.
* NONSEQ → Start a new APB transaction.
* SEQ → Continue APB transaction in a burst.

### **4. HSIZE (Transfer Size)**

* 3-bit signal describing data size for transfer:

  * `000` → Byte (8 bits)
  * `001` → Halfword (16 bits)
  * `010` → Word (32 bits)
  * `011` → Double word (64 bits) (if supported)
* Determines how many bytes of data are written/read.

**Usage in bridge:**

* Bridge converts HSIZE to APB write/read size or selects proper byte lanes.

### **5. HREADYin (Input Ready)**

* Indicates whether the previous stage (or slave) is ready to accept a transfer.
* `1` → ready, `0` → wait
* Used for **handshaking**: Bridge starts transaction only when HREADYin is high.

### **6. HWDATA (Write Data)**

* Data coming from AHB master to write into APB peripheral.
* Only valid during **write transfers** (HWRITE = 1).

### **7. HADDR (Address Bus)**

* 32-bit address from AHB master.
* Used to select APB peripheral and internal registers.
* In a burst, sequential addresses are generated automatically by bridge if HTRANS=SEQ.

### **8. HWRITE**

* 1-bit signal: 1 → write, 0 → read
* Bridge uses this to decide whether to forward data to APB PWDATA (write) or expect PRDATA (read).

### **9. HRDATA (Read Data)**

* Data from bridge to AHB master during read transfers.
* Captured from APB peripheral via bridge.

### **10. HRESP (Response)**

* 1-bit or 2-bit (implementation dependent) indicating transfer status:

  * `OKAY` → normal
  * `ERROR` → failed transfer
* Bridge sets HRESP after APB transfer completes.

### **11. HREADYout**

* 1-bit output from bridge to AHB master indicating when the transfer is complete.
* Synchronizes next transfer; master waits if HREADYout = 0.

##  AMBA Signals

### AMBA AHB Signals

| Name | Source | Description |
| ----------- | ----------- |  ----------- |
| HCLK | Clock source |  This clock times all bus transfers. All signal timings are related to the rising edge of HCLK. |
| HRESETn | Reset controller | The bus reset signal is active LOW and is used to reset the system and the bus.This is the only active LOW signal. |
| HADDR[31:0] | Master | The 32-bit system address bus.
| HTRANS[1:0] | Master | Indicates the type of the current transfer, which can be NONSEQUENTIAL, SEQUENTIAL, IDLE or BUSY. |
| HWRITE | Master | When HIGH this signal indicates a write transfer and when LOW a read transfer. |
| HSIZE[2:0] | Master | Indicates the size of the transfer, which is typically byte (8-bit), halfword (16-bit) or word (32-bit). The protocol allows for larger transfer sizes up to a maximum of 1024 bits. |
| HBURST[2:0] | Master | Indicates if the transfer forms part of a burst. Four, eight and sixteen beat bursts are supported and the burst may be either incrementing or wrapping. |
| HPROT[3:0] | Master | The protection control signals provide additional information about a bus access and are primarily intended for use by any module that wishes to implement some level of protection. This is optional |
| HWDATA[31:0] | Master | The write data bus is used to transfer data from the master to the bus slaves during write operations. A minimum data bus width of 32 bits is recommended.
| HSELx | Decoder | Each AHB slave has its own slave select signal and this signal indicates that the current transfer is intended for the selected slave. This signal is simply a combinatorial decode of the address bus. |
| HRDATA[31:0] | Slave | The read data bus is used to transfer data from bus slaves to the bus master during read operations. A minimum data bus width of 32 bits is recommended.|
| HREADY | Slave | When HIGH the HREADY signal indicates that a transfer has finished on the bus. This signal may be driven LOW to extend a transfer. **Note: Slaves on the bus require HREADY as both an input and an output signal.**
| HRESP[1:0] | Slave |  The transfer response provides additional information on the status of a transfer. Four different responses are provided, OKAY, ERROR, RETRY and SPLIT.


## **APB Interface Signals**

### **1. PSELx (Peripheral Select)**

* One-hot signal selecting which APB peripheral is active.
* Bridge asserts PSELx when a transaction targeting that peripheral occurs.

### **2. PWRITE**

* 1-bit write enable to APB peripheral.
* Derived from HWRITE of AHB transaction.

### **3. PENABLE**

* Indicates **start of APB transfer** (setup + enable phase).
* Asserted **1 cycle after PSELx** according to APB protocol.

### **4. PADDR**

* APB address, mapped from HADDR.
* Used to select registers in the peripheral.


### **5. PWDATA**

* Write data from bridge to APB peripheral.
* Only valid if PWRITE = 1.


### **6. PRDATA**

* Read data from APB peripheral to bridge, then forwarded to HADDR.

### AMBA APB Signals

| Name | Source | Description |
| ----------- | ----------- |  ----------- |
|PCLK  | Clock Source|The rising edge of PCLK is used to time all transfers on the APB.|
|PRESETn  | Reset Controller| The APB bus reset signal is active LOW and this signal will normally be connected directly to the system bus reset signal.|
|PADDR[31:0]  | Master |This is the APB address bus, which may be up to 32-bits wide and is driven by the peripheral bus bridge unit.|
|PSELx  | Decoder | A signal from the secondary decoder, within the peripheral bus bridge unit, to each peripheral bus slave x. This signal indicates that the slave device is selected and a data transfer is required. There is a PSELx signal for each bus slave.|
|PENABLE  |  Master | This strobe signal is used to time all accesses on the peripheral bus. The enable signal is used to indicate the second cycle of an APB transfer. The rising edge of PENABLE occurs in the middle of the APB transfer.|
|PWRITE  |  Master | When HIGH this signal indicates an APB write access and when LOW a read access.|
|PRDATA[31:0]  | Slave | The read data bus is driven by the selected slave during read cycles (when PWRITE is LOW). The read data bus can be up to 32-bits wide.|
|PWDATA[31:0]  | Master | The write data bus is driven by the peripheral bus bridge unit during write cycles (when PWRITE is HIGH). The write data bus can be up to 32-bits wide.|


### **Additional Concepts**

#### **Burst Length**

* Defines number of transfers in a sequence (for NONSEQ + SEQ transfers).
* Bridge tracks burst to generate sequential APB accesses.

#### **Wrapping vs. Incrementing Burst**

* **Incrementing burst:** Next address = previous + transfer size
* **Wrapping burst:** Address wraps around a boundary, e.g., 4-word wrap → after last word, address goes back to start

#### **How Bridge Uses Them**

* Converts AHB HADDR, HWRITE, HWDATA, HSIZE, HTRANS into **APB PSELx, PENABLE, PADDR, PWDATA, PWRITE**.
* Handles read/write timing, ready signals, and response back to AHB.

---





# AHB to APB Bridge




## About the AMBA Buses

The Advanced Microcontroller Bus Architecture (AMBA) specification defines an
on-chip communications standard for designing high-performance embedded
microcontrollers.
Three distinct buses are defined within the AMBA specification:
- Advanced High-performance Bus (AHB)
- Advanced System Bus (ASB)
- Advanced Peripheral Bus (APB).

### Advanced High-performance Bus (AHB)

The AMBA AHB is for high-performance, high clock frequency system modules.
The AHB acts as the high-performance system backbone bus. AHB supports the
efficient connection of processors, on-chip memories and off-chip external memory
interfaces with low-power peripheral macrocell functions. AHB is also specified to
ensure ease of use in an efficient design flow using synthesis and automated test
techniques.

### Advanced System Bus (ASB)

The AMBA ASB is for high-performance system modules.
AMBA ASB is an alternative system bus suitable for use where the high-performance
features of AHB are not required. ASB also supports the efficient connection of
processors, on-chip memories and off-chip external memory interfaces with low-power
peripheral macrocell functions.

### Advanced Peripheral Bus (APB)

The AMBA APB is for low-power peripherals.
AMBA APB is optimized for minimal power consumption and reduced interface
complexity to support peripheral functions. APB can be used in conjunction with either
version of the system bus.


The overall architecture looks like the following:

![AMBA System](https://user-images.githubusercontent.com/91010702/194475317-68a7f60d-65ea-48de-a13a-fd85e25c364b.png)

## Basic Terminology

#### Bus cycle 
A bus cycle is a basic unit of one bus clock period and for the
purpose of AMBA AHB or APB protocol descriptions is defined
from rising-edge to rising-edge transitions. 

#### Bus transfer 
An AMBA ASB or AHB bus transfer is a read or write operation of a data object, which may take one or more bus cycles. The bus
transfer is terminated by a completion response from the
addressed slave.
An AMBA APB bus transfer is a read or write operation
of a data object, which always requires two bus cycles.

#### Burst operation 
A burst operation is defined as one or more data transactions,
initiated by a bus master, which have a consistent width of
transaction to an incremental region of address space. The
increment step per transaction is determined by the width of
transfer (byte, halfword, word). No burst operation is supported
on the APB.

# Implementation 

## Objective

To design and simulate a synthesizable AHB to APB bridge interface using Verilog and run single read and single write tests using AHB Master and APB Slave testbenches.
The bridge unit converts system bus transfers into APB transfers and performs the following functions: 
- Latches the address and holds it valid throughout the transfer.
- Decodes the address and generates a peripheral select, PSELx. Only one select signal can be active during a transfer.
- Drives the data onto the APB for a write transfer.
- Drives the APB data onto the system bus for a read transfer.
- Generates a timing strobe, PENABLE, for the transfer
- Can implement single read and write operations successfully.

The diagram below shows the interface:

![APB Bridge](https://user-images.githubusercontent.com/91010702/194486314-3df5f435-e9f7-43a7-bd94-d5e2070f09c0.png)

## Basic Implementation Tools

- HDL Used : Verilog
- Simulator Tool Used: ModelSIM
- Synthesis Tool Used: Quartus Prime
- Family: Cyclone V
- Device: 5CSXFC6D6F31I7ES

## Design Modules

### AHB Slave Interface

An AHB bus slave responds to transfers initiated by bus masters within the system. The 
slave uses a HSELx select signal from the decoder to determine when it should respond 
to a bus transfer. All other signals required for the transfer, such as the address and 
control information, will be generated by the bus master.

### APB Controller

The AHB to APB bridge comprises a state machine, which is used to control the 
generation of the APB and AHB output signals, and the address decoding logic which 
is used to generate the APB peripheral select lines.
  

## Notes  
 
**The design files are attached in the repository along with the AHB Master and APB Slave which generates the appropriate signals. Only the Bridge is synthesizable and other modules are used as testbenches only to generate the necessary read/write operations. Below are the screenshots from the synthesis and the simulator tool**

# Simulation Results

It consists of a write operation followed by a read operation on the AHB Bus which is successfully mapped to the APB bus according to the interfacing.

![simulation_AHBtoAPB](https://user-images.githubusercontent.com/91010702/194483573-0e104260-c1b7-4810-88fe-c9aa4a32395f.png)

# Synthesis Results

RTL Model:
![bridge_rtl](https://user-images.githubusercontent.com/91010702/194485990-f8ff7727-387e-42ef-8fa7-d39034216ffc.png)

State Machine Viewer:
![bridge_fsm](https://user-images.githubusercontent.com/91010702/194485981-4a8f44e9-390b-4100-84b3-abe9c4930377.png)


# Further Work

- Include functionality for burst read and burst write operations in AHB Master
- Include an arbitration mechanism and arbitration signals to generalise the testbench

# Documentation

- AMBA Modules | Chapter 4 | [AMBA Modules.pdf](https://github.com/prajwalgekkouga/AHB-to-APB-Bridge/files/9731505/AMBA.Modules.pdf)
- AMBA Specifications | Chapter 1,2,3 and 5 | [AMBA Specifications.pdf](https://github.com/prajwalgekkouga/AHB-to-APB-Bridge/files/9731507/AMBA.Specifications.pdf)

---
## 🚀 Features

* Supports **read/write** transactions.
* Handles **burst transfers** on AHB side and translates to single APB transactions.
* **UVM compliant** reusable components.
* Configurable **virtual sequences** for multi-agent coordination.
* **Scoreboard-based checking** for transaction validation.

---


---
Here is a detailed comparison of **AHB pipelining** and **APB non-pipelined operation** explained in markdown format:

***

# AHB vs APB Pipeline Operation

## AHB Pipeline (Advanced High-performance Bus)

- **Pipelined protocol:** Allows overlapping of the address phase of transaction N+1 with the data phase of transaction N.
- **Address Phase:** Master places address and control signals (HADDR, HSIZE, HWRITE, HTRANS) on the bus.
- **Data Phase:** Slave or master transfers data (HWDATA for write, HRDATA for read).
- **Cycle Example:**
  - Cycle 1: Address phase for transfer 1
  - Cycle 2: Address phase for transfer 2 + data phase for transfer 1
  - Cycle 3: Address phase for transfer 3 + data phase for transfer 2
- This **overlap maximizes bus utilization and throughput**.
- Can include **burst transfers** where multiple data words are transferred sequentially with one initial address phase.
- Control signal **HREADY** allows the slave to insert wait states to stall the pipeline if needed.
- Suitable for **high-performance, high-bandwidth** on-chip communication.

| Cycle     | Address Phase                   | Data Phase                    |
|-----------|--------------------------------|-------------------------------|
| Cycle 1   | Transfer 1 address              |                               |
| Cycle 2   | Transfer 2 address              | Transfer 1 data               |
| Cycle 3   | Transfer 3 address              | Transfer 2 data               |
| ...       | ...                            | ...                           |

***

## APB Operation (Advanced Peripheral Bus)

- **Non-pipelined protocol:** Does NOT support overlapping address and data phases.
- Every transfer requires at least **two distinct clock cycles**:
  1. **Setup Cycle:** Master places address, control (PADDR, PSEL, PWRITE), and write data (PWDATA).
  2. **Access Cycle:** Master asserts PENABLE signal; slave performs the read/write operation, data is transferred (PRDATA for read).
- No overlapping of phases means the **next transfer starts only after the current transfer completes**.
- Designed for **low-speed, low-power peripherals** with simple interface requirements.
- Slave can assert **PREADY** low to insert wait states during access phase.
- Ideal for connecting peripherals like timers, UARTs, GPIO where throughput demand is low.

| Cycle     | Signals Active                 | Description                   |
|-----------|-------------------------------|-------------------------------|
| Cycle 1   | Setup signals (PADDR, PSEL, PWRITE, PWDATA) | Setup phase                   |
| Cycle 2   | PENABLE asserted; Slave acts  | Access phase (transfer occurs)|
| Cycle 3+  | Next transfer setup or idle   | Repeat                        |

***

## Key Differences

| Feature                    | AHB                                      | APB                                      |
|----------------------------|------------------------------------------|------------------------------------------|
| Pipeline Model             | Yes, overlapping address/data             | No, separate address and data phases      |
| Clock Cycles per Transfer  | Usually 1 cycle per phase, pipelined      | Minimum 2 cycles per transfer              |
| Complexity                 | High; supports bursts, multiple transfers | Low; simple interface                      |
| Main Use Case              | High-performance, high-bandwidth systems  | Low bandwidth peripherals                  |
| Throughput                | Higher due to pipelining                   | Lower due to non-pipelined operation       |

***

## Summary

AHB maximizes throughput by overlapping address and data phases via pipelining, speeding up transactions and allowing burst transfers. APB sacrifices speed and complexity for simplicity and low power by using strictly sequential, non-pipelined transfers taking a minimum of two cycles each. APB suits low-bandwidth peripherals where performance demand is not critical.
