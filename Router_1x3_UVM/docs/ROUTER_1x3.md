* **`fifo.v` 💾**

  * Temporary data storage buffer.
  * Handles rate mismatch between input/output.
  * Prevents packet loss during congestion.

* **`fsm.v` ⚙️**

  * Controls router operation sequence.
  * Manages packet read/write states.
  * Ensures correct routing flow.

* **`register.v` 📦**

  * Holds header/data temporarily.
  * Aligns data timing internally.
  * Stabilizes signals before routing.

* **`router_if.v` 🔌**

  * Interface bundling router signals.
  * Defines signal directions cleanly.
  * Simplifies TB–DUT connectivity.

* **`synchronizer_blocks.v` ⏱️**

  * Handles clock domain crossing.
  * Avoids metastability issues.
  * Ensures reliable signal transfer.

* **`top_model.v` 🚀**

  * Integrates all router modules.
  * Connects FIFO, FSM, registers, sync blocks.
  * Represents full 1×3 router RTL.

-------

| **Signal**        | **Description**                                    |
| ----------------- | -------------------------------------------------- |
| `clock`           | Active-high clock controlling router operations ⏱️ |
| `resetn`          | Active-low synchronous reset 🔄                    |
| `pkt_valid`       | Indicates arrival of a new packet 📦               |
| `data_in[7:0]`    | 8-bit input data bus from source 💾                |
| `read_enb_0`      | Read enable for output port 0 📤                   |
| `read_enb_1`      | Read enable for output port 1 📤                   |
| `read_enb_2`      | Read enable for output port 2 📤                   |
| `data_out_0[7:0]` | 8-bit output data to destination 1 🚀              |
| `data_out_1[7:0]` | 8-bit output data to destination 2 🚀              |
| `data_out_2[7:0]` | 8-bit output data to destination 3 🚀              |
| `vld_out_0`       | Valid data indicator for port 0 🔎                 |
| `vld_out_1`       | Valid data indicator for port 1 🔎                 |
| `vld_out_2`       | Valid data indicator for port 2 🔎                 |
| `busy`            | Router busy indicator ⚙️                           |
| `error`           | Parity mismatch error indicator 🚨                 |

--------
# fifo.v
----------

* **FIFO purpose 💾**

  * Temporary packet storage buffer.
  * Handles data flow mismatch between blocks.

* **Pointers ⚙️**

  * `wr_pt` → Write pointer (increments on `we`).
  * `rd_pt` → Read pointer (increments on `re`).
  * Extra MSB helps detect full condition.

* **Memory structure 📦**

  * `mem[15:0]` → 16-depth FIFO.
  * Each location = 9 bits (`lfd_state` + 8-bit data).

* **Write operation ✍️**

  * If `we=1` & not full → store `{lfd_state_s,din}`.
  * Data written at `wr_pt[3:0]`.

* **Read operation 📤**

  * If `re=1` & not empty → output data.
  * Reads from `rd_pt[3:0]`.

* **Header detect (`lfd_state`) 🔎**

  * Stored as extra bit.
  * Helps identify packet header start.

* **FIFO counter 📊**

  * Tracks packet length.
  * Loaded from header field.
  * Decrements during reads.

* **Full/Empty detection ⚡**

  * `full` → Pointer MSB differ + lower bits equal.
  * `empty` → Both pointers equal.

* **Reset handling 🔄**

  * `rstn` or `soft_rst` clears memory/pointers.
  * Ensures clean FIFO start.


-------

# # fsm.v

------

* **Purpose ⚙️**

  * Controls router packet flow.
  * FSM decides when to read/write FIFO.

* **States 🔄**

  * `decode_address` → Reads destination address.
  * `load_first_data` → Loads header byte.
  * `load_data` → Loads packet payload.
  * `wait_till_empty` → Waits until FIFO free.
  * `load_parity` → Loads parity byte.
  * `check_parity_error` → Verifies packet parity.
  * `fifo_full_state` → Handles FIFO full case.
  * `load_after_full` → Resume after full clears.

* **State transitions ⚡**

  * Based on `pkt_vd`, FIFO empty/full signals.
  * Soft reset forces FSM back to decode.

* **Control outputs 📦**

  * `detect_add` → Address detection enable.
  * `lfd_state`, `ld_state` → Data load control.
  * `write_enb_reg` → Enables register write.
  * `full_state`, `laf_state` → FIFO full handling.

* **Status signals 🔎**

  * `busy` → Router busy indicator.
  * `rst_in_reg` → Reset internal register.

* **Overall working 🚀**

  * Detect address → load data → check parity → handle FIFO conditions → repeat.

------

# register.v

-----


* **Purpose 📦**

  * Stores packet header, payload, parity.
  * Provides data output to FIFO/router path.

* **Header handling 🔎**

  * `detect_addr & pkt_vd` → Header stored.
  * `lfd_state` → Header sent to output.

* **Data handling 💾**

  * `ld_state & !fifo_full` → Payload sent directly.
  * If FIFO full → Data temporarily stored.
  * `laf_state` → Stored data forwarded later.

* **Parity generation ⚡**

  * Internal parity via XOR accumulation.
  * Packet parity captured separately.

* **Error detection 🚨**

  * Compares internal vs packet parity.
  * Mismatch → `error=1`.

* **Status signals 🔄**

  * `parity_done` → Parity byte processed.
  * `low_pkt_vd` → Packet valid dropped indication.

* **Reset behavior ⏱️**

  * Reset clears registers, parity, status flags.


-----------


### **INTRODUCTION 🚀**

* It decodes the header to determine the correct output channel, ensuring accurate packet delivery.
* It manages internal data communication between multiple modules within a digital system.
* In SoC and NoC architectures, it enables efficient on-chip data transfer.
* The design targets high throughput, low latency, and reliable packet transmission.

---
* Router 1×3 follows a **packet-based protocol** and receives data byte-by-byte on `data_in` at the positive edge of `clock`.
* `resetn` is an active-low synchronous reset.
* `pkt_valid` asserted → start of packet; de-asserted → end of packet.
* Incoming packets are stored into one of three FIFOs based on destination address.
* Each FIFO corresponds to one destination LAN (0, 1, 2).
* Destination monitors `vld_out_x` and asserts `read_enb_x` to read via `data_out_x`.
* `busy` indicates router cannot accept new data; source must pause transmission.
* Parity check mechanism compares received parity with internally calculated parity.
* If mismatch occurs, `error` is asserted and sent back to source LAN.
* Router handles only one incoming packet at a time, but up to three packets can be read simultaneously.





---

### **FEATURES TO BE VERIFIED 🔍**

* The router must correctly forward packets to all three output ports based on payload size.
* Each output port should handle small, medium, and large packets without data loss.
* If data corruption occurs, the router must assert the error signal to indicate an invalid packet.
* If output data is not read within 30 clock cycles after `vld_out` becomes high, a soft reset must be triggered automatically.

---------


* **Packet Routing 📦** → Input packet routed to one of three output ports based on destination address.
* **Parity Checking 🚨** → Error detection using parity to ensure correct data transmission.
* **Reset 🔄** → Active-low synchronous reset clears FIFOs and makes valid signals low.
* **Sending Packet 🚀** → Packet transmission follows router input protocol.
* **Reading Packet 📤** → Packet reception follows router output protocol.

-------
# Packet Format -

* **Packet Format 📦** → Packet has 3 parts: Header, Payload, Parity; each 8-bit wide. Payload length ranges from **1 to 63 bytes**.

* **Header 🔎**

  * Contains **DA (2 bits)** + **Length (6 bits)**.
  * DA selects output port; router forwards packet to matching port.
  * Address **3 invalid**.
  * Length indicates payload size (1–63 bytes).
  * **Practical:** First byte sent; router decodes DA and selects FIFO.

* **Payload 💾**

  * Actual data bytes of packet.
  * Transmitted sequentially after header.
  * **Practical:** Router stores payload in selected FIFO until complete packet received.

* **Parity 🚨**

  * Security/error check field.
  * Calculated as bitwise parity of header + payload bytes.
  * **Practical:** Router recalculates parity; mismatch → error signal asserted.


-----
# ROUTER INPUT PROTOCOL

* All input signals are active HIGH except active LOW reset and are synchronized to the falling edge of the clock. Router DUT works on rising edge; driving inputs on falling edge ensures proper setup and hold time. Clocking block in SV/UVM can also drive signals on positive edge safely.

* `pkt_valid` is asserted on the same clock edge when the header byte is placed on the input data bus.

* Header contains destination address which decides output channel (`data_out_0`, `data_out_1`, `data_out_2`).

* Payload bytes are driven sequentially on the input bus for each new falling clock edge after the header.

* After last payload byte, `pkt_valid` is deasserted on next falling clock and parity byte is driven, indicating packet completion.

* Testbench should not drive new bytes when `busy` is HIGH; last value must be held.

* When `busy` asserted, router drops incoming data byte.

* `error` signal asserted when packet parity mismatch occurs.

-----


































