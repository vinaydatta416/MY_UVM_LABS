```markdown
# Router 1x3 Project
```
---
## 🧱 Block-Level RTL Design

The RTL is structured into **6 modules**:

### 1️⃣ FSM Controller

- Central controller driving states based on inputs.
- Generates synchronization, register, and FIFO control signals.

### 2️⃣ Synchronizer

- Decodes header to determine destination FIFO.
- Generates **write enable** for FIFOs.
- Controls **valid_out** signals to destinations.
- Performs **soft reset** if FIFO data isn’t read in 30 cycles.

### 3️⃣ Register Block

- Holds header, parity, and intermediate states.
- Computes internal parity for error checking.

### 4️⃣ FIFO Buffers (x3)

- One FIFO per destination.
- Stores payload data and outputs on valid read.

### 5️⃣ Router Top

- Integrates FSM, Synchronizer, Register, and FIFOs.

📌 **Diagram:**

![Router Top Block](1.png)

---
![Router Top Block](2.png)

---
![Router Top Block](3.png)

------

## 📦 Packet Structure

```
+-------------+-------------------+---------------+
| Header Byte | Payload (n Bytes) | Parity Byte   |
+-------------+-------------------+---------------+
|                   PYALOAD 0                      |
+-------------+-------------------+---------------+
|                       |                         |
+-------------+-------------------+---------------+
|                  PYALOAD 63                     |
+-------------+-------------------+---------------+
```

- **Header Byte**:
  - Bits [7:2] → Payload length (max 64 bytes)
  - Bits [1:0] → Destination address
- **Payload**: Actual data bytes [63:0].
- **Parity**: Single-byte  error detection.

## Project Overview

The Router 1x3 is a digital design that:
- Routes packets from one input port to three output ports
- Uses FIFOs for output buffering (16x9 bits each)
- Implements parity checking for error detection
- Features a FSM-based control system

---

## Architecture

### RTL Block Diagram
![Router RTL Architecture](arch.jpeg)

### UVM Testbench Architecture
![UVM Architecture](uvmarch.jpeg)

---

## Key Features

### Input Protocol
- Active low signals (except reset)
- Header byte contains routing address
- Packet validation and parity checking
- Busy signal handling for flow control

### Output Protocol
- Three independent output ports (data_out_0, data_out_1, data_out_2)
- Valid signal indication for each port
- 16x9 FIFO buffering per output
- 30-cycle timeout mechanism

### FIFO Features
- 16 bytes depth with 9-bit width
- Header byte detection (9th bit)
- Synchronous reset support
- Overflow and underflow protection
- Simultaneous read/write capability

---

## RTL Components

1. **Router Top**: Main module integrating all submodules
2. **FSM**: Controls packet routing and state management
3. **FIFO**: Implements 16x9 output buffers
4. **Synchronizer**: Handles communication between FSM and FIFOs
5. **Register**: Implements internal registers for data handling

## UVM Testbench Components

1. **Source Agent**: Handles input port stimulus
2. **Destination Agent**: Monitors output ports
3. **Environment**: Contains scoreboard and virtual sequencer
4. **Sequences**: Various test scenarios
5. **Scoreboard**: Validates router functionality

## Simulation and Verification

### Running Tests
```bash
cd sim
make clean
make regress # for running all the test cases
```

### Coverage Reports
Coverage reports are available in the `report/` directory:
- Assertion Coverage

## FSM States

1. DECODE_ADDRESS: Initial packet processing
2. LOAD_FIRST_DATA: Header byte handling
3. LOAD_DATA: Payload processing
4. LOAD_PARITY: Parity byte handling
5. FIFO_FULL_STATE: Overflow protection
6. LOAD_AFTER_FULL: Post-full state handling
7. WAIT_TILL_EMPTY: FIFO empty wait
8. CHECK_PARITY_ERROR: Error detection

---




# 📌 Router 1x3 Interface – Signal Description

| **Signal**                                                         | **Direction** | **Width**   | **Active / Type**           | **Description**                                                                                      |
| ------------------------------------------------------------------ | ------------- | ----------- | --------------------------- | ---------------------------------------------------------------------------------------------------- |
| **clock**                                                          | Input         | 1 bit       | Active on **posedge**       | System clock that drives all synchronous logic inside the router.                                    |
| **resetn**                                                         | Input         | 1 bit       | Active **low**, synchronous | Resets FSM, FIFOs, counters, and internal registers to a known state.                                |
| **pkt\_valid**                                                     | Input         | 1 bit       | Active **high**             | Indicates arrival of a new packet from source network at `data_in`.                                  |
| **data\_in**                                                       | Input         | 8 bits      | –                           | Packet data bus from source to router. First byte is header, last byte is parity.                    |
| **read\_enb\[2:0]** <br>(read\_enb\_0, read\_enb\_1, read\_enb\_2) | Input         | 1 bit each  | Active **high**             | Read enable for each output port. When high, router drives `data_out_x` to the corresponding client. |
| **data\_out\[2:0]** <br>(data\_out\_0, data\_out\_1, data\_out\_2) | Output        | 8 bits each | –                           | Packet data bus from router to destination clients (3 outputs).                                      |
| **vld\_out\[2:0]** <br>(vld\_out\_0, vld\_out\_1, vld\_out\_2)     | Output        | 1 bit each  | Active **high**             | Indicates valid data is available on corresponding `data_out_x`. Works with `read_enb_x`.            |
| **busy**                                                           | Output        | 1 bit       | Active **high**             | Indicates router is currently processing a packet and cannot accept new data. Prevents packet loss.  |
| **error**                                                          | Output        | 1 bit       | Active **high**             | Indicates **parity mismatch** between received packet parity and internally computed parity.         |

---

# 📌 Quick Bullets (Grouped Explanation)

* **Input side (source → router):**

  * `clock` → main timing reference.
  * `resetn` → reset all logic (active low).
  * `pkt_valid` → signals arrival of new packet.
  * `data_in[7:0]` → 8-bit packet data bus.

* **Output control (router → client):**

  * `read_enb[2:0]` → enables reading for each destination.
  * `data_out[2:0][7:0]` → 8-bit output bus for clients 0,1,2.
  * `vld_out[2:0]` → tells client that valid byte is available.

* **Status/Error signals:**

  * `busy` → router is occupied, no new packets accepted.
  * `error` → parity error detected in packet.

---

# 📌 Router 1x3 – Key Features

| **Feature**                          | **Description**                                                                                                                                                                                                                                        |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Packet Routing**                   | - Incoming packet arrives on the single **input port** (`data_in`). <br>- The **header field** contains the destination address. <br>- Based on this address, router directs the packet to one of the **three output ports** (`data_out_0/1/2`).       |
| **Parity Checking**                  | - Ensures **data integrity** between source (server) and destination (client). <br>- Router computes **internal parity** while receiving the packet. <br>- Compares with **parity byte** sent in packet. <br>- If mismatch → `error` signal goes high. |
| **Reset**                            | - Controlled by **active-low synchronous reset (`resetn`)**. <br>- When asserted: <br>  • Router FSM returns to IDLE. <br>  • All **output FIFOs emptied**. <br>  • All `vld_out_x` signals go low (no valid data available).                          |
| **Sending Packet (Input Protocol)**  | - Source sends packet byte-by-byte over `data_in`. <br>- **`pkt_valid`** high indicates packet transfer. <br>- **Busy** signal prevents new packet arrival if router is occupied.                                                                      |
| **Reading Packet (Output Protocol)** | - Destination reads data from router using **`read_enb_x`**. <br>- Corresponding **`vld_out_x`** goes high when data is ready. <br>- Packet is read sequentially until last byte (parity).                                                             |

---



