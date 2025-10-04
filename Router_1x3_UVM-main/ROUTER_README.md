```markdown
# Router top - Overview

```
---
```
The Router 1x3 design follows packet based protocol and it receives the network packet from
a source LAN using data_in on a byte by byte basis on active posedge of the clock. resetn is
an active low synchronous reset.

The start of a new packet is indicated by asserting pkt_valid and end of the current packet is
indicated by de-asserting pkt_valid. The design stores the incoming packet inside a FIFO as
per the address of the packet. The design has got 3 FIFO’s for respective destination LANs.
During packet read operation, the destination LANs monitors vld_out_x ( x can be 0, 1, or 2),
and then asserts read_enb_x ( x can be 0, 1, or 2). The packet is read by the destination
LAN’s using the channels data_out_x ( x can be 0, 1, or 2).

Sometimes, router can enter into busy state which is indicated by the signal busy. The busy
signal is sent back to the source LAN so that the source has to wait to send the next byte of
the packet.

To confirm the correctness of the packet, received by the router, we have implemented an
error detection mechanism i.e parity check. If there is a mismatch in the parity byte sent by
the source LAN and the internal parity calculated by the router, then the error signal is
asserted. This error signal is sent back to the source LAN so that by monitoring the same, the
source LAN can resend the packet.

This design can receive only 1 packet at a time, but 3 packets can be read simultaneously.

```
---

# 📌 Router 1x3 Project – DV Interview Q\&A

---

### **Q1. What is the functionality of a 1x3 router design?**

* **Answer:**

  * Takes a single input packet stream.
  * Routes the packet to one of the three output ports based on the header (usually 2-bit destination address).
  * Ensures packet integrity and follows flow control (valid/ready handshake or FIFO).

---

### **Q2. What are the main blocks of a 1x3 router?**

* **Answer:**

  1. **Input Register/Buffer** – stores incoming packet.
  2. **Header Decoder** – extracts destination address.
  3. **Control FSM** – controls routing and handshaking.
  4. **Output FIFOs (3 FIFOs)** – separate buffers for each output.
  5. **Mux/Demux** – directs packet to correct FIFO.

---

### **Q3. How does the FSM work in router 1x3?**

* **Answer:**

  * **IDLE:** Wait for valid packet.
  * **HEADER:** Decode destination address.
  * **ROUTING:** Write packet into corresponding FIFO.
  * **WAIT/ERROR:** Handle invalid address or full FIFO.

---

### **Q4. How do you verify the router design?**

* **Answer:**

  * Write **SystemVerilog testbench** with driver, monitor, scoreboard.
  * **Driver:** Generates packets with different headers.
  * **Monitor:** Captures output packets from each FIFO.
  * **Scoreboard:** Compares expected vs actual packet.
  * Add **assertions** for protocol checks (e.g., no data lost, FIFO not overflowed).
  * Add **functional coverage**:

    * All 3 outputs hit.
    * All packet sizes tested.
    * Error cases (invalid address).

---

### **Q5. What kind of packets are used in router 1x3?**

* **Answer:**

  * Typical packet has:

    * **Header (2 bits)** → destination.
    * **Length field (6 bits)** → packet size.
    * **Payload (N bytes)** → data.
    * **Parity byte** → error detection.

---

### **Q6. What corner cases will you test?**

* **Answer:**

  * Minimum packet (only header + parity).
  * Maximum length packet.
  * Invalid address in header.
  * Back-to-back packets.
  * FIFO full → packet should wait (flow control).
  * Parity error detection.

---

### **Q7. What kind of assertions can you write for this router?**

* **Answer:**

  * Packet with invalid header → should not go to any FIFO.
  * Parity error → error flag should be high.
  * FIFO should not overflow.
  * If input valid = 1, then at least one output valid must be high.
  * Output data must match input packet (data integrity).

---

### **Q8. What coverage points will you write?**

* **Answer:**

  * **Coverpoint 1:** Destination address (0,1,2,invalid).
  * **Coverpoint 2:** Packet size bins (small, medium, large).
  * **Coverpoint 3:** Error scenarios (FIFO full, parity error).
  * **Cross coverage:** Address × Packet size.

---

### **Q9. If functional coverage is 100% but code coverage is 85%, what does it mean?**

* **Answer:**

  * All functional scenarios are tested (good).
  * But some RTL branches are not exercised (maybe error paths not hit).
  * Need to add more directed/random tests to hit those missing branches.

---

### **Q10. How will you connect scoreboard in UVM testbench for router 1x3?**

* **Answer:**

  * **Write monitor** → sends expected packet (based on input).
  * **Read monitor** → sends actual packet (from output FIFO).
  * **Scoreboard** compares expected vs actual for correctness.

---

### **Q11. If two packets go to the same FIFO back-to-back, how will you check ordering?**

* **Answer:**

  * Use **queue-based model** in scoreboard.
  * Push expected packets in order.
  * Pop actual packets and compare.
  * Assertion: First packet out must match first packet in (FIFO ordering preserved).

---

### **Q12. How do you handle invalid address in router design?**

* **Answer:**

  * RTL may drop packet and set error signal.
  * Testbench must check that packet is not routed to any FIFO.

---

### **Q13. What is the difference between directed and random tests in router verification?**

* **Answer:**

  * **Directed tests:** Specific scenarios (invalid address, max length packet).
  * **Random tests:** Stimulus randomized with constraints → ensures wider coverage and catches corner bugs.

---

### **Q14. What is the main bug you may find in router 1x3 project?**

* **Answer:**

  * Wrong FIFO selection (routing bug).
  * FIFO overflow/underflow.
  * Dropping valid packets.
  * Incorrect parity check.
  * Packet ordering issue.

---

### **Q15. If you have only 2 weeks to verify router 1x3, how will you plan?**

* **Answer:**

  * Week 1: Build testbench (driver, monitor, scoreboard, coverage).
  * Week 2: Run random + directed tests, close coverage, debug failures.

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

# 📌 Quick Bullets (for oral explanation)

* **Routing:** Single input → routed to one of 3 outputs based on header.
* **Parity:** Detects packet corruption, raises error if mismatch.
* **Reset:** Clears FIFOs, resets FSM, `vld_out` = 0.
* **Sending:** Controlled by `pkt_valid`, `data_in`, `busy`.
* **Reading:** Controlled by `read_enb`, `data_out`, `vld_out`.



---

### **Q1. How do you model a packet transaction in UVM for router 1x3?**

**Answer:**

* Create a `packet` class (`extends uvm_sequence_item`).
* Fields: `dest_addr`, `length`, `payload[]`, `parity`.
* Add methods: `copy`, `compare`, `print`, `pack/unpack`.
* Constraint example: `dest_addr inside {0,1,2}; length <= 64;`.

---

### **Q2. How many agents are required in UVM testbench for router 1x3?**

**Answer:**

* **1 input agent** (driver, sequencer, monitor).
* **3 output agents** (each has monitor, optionally driver for read\_enb).
* Total = 4 agents.

---

### **Q3. How will the scoreboard work for router 1x3?**

**Answer:**

* Input monitor sends **expected packets** to scoreboard.
* Output monitors send **actual packets** to scoreboard.
* Scoreboard compares expected vs actual packet per destination port.
* Uses queues per port to check ordering.

---

### **Q4. How do you connect 3 output monitors to a single scoreboard?**

**Answer:**

* Use **TLM analysis ports** in each monitor.
* Scoreboard has **analysis exports** for each output.
* Connect in `connect_phase()`.
* Example: `monitor0.ap.connect(sb.exp_in0);`.

---

### **Q5. How do you generate corner case scenarios using UVM sequences?**

**Answer:**

* Constrain header = invalid value → check error signal.
* Constrain packet length = max size → stress FIFO.
* Randomize back-to-back packets → check busy.
* Constrain multiple packets to same destination → check FIFO ordering.

---

### **Q6. What functional coverage do you implement in router 1x3?**

**Answer:**

* Cover **dest\_addr {0,1,2,invalid}**.
* Cover **packet length bins (small/medium/large)**.
* Cover **error conditions** (FIFO full, parity mismatch).
* Cross coverage: dest\_addr × packet length.

---

### **Q7. How do you handle error injection in router 1x3 UVM testbench?**

**Answer:**

* Add a **parity error sequence** → flip parity bit randomly.
* Add a **header error sequence** → randomize dest\_addr outside {0,1,2}.
* Add directed sequence for **FIFO full condition** (send packets faster than read).

---

### **Q8. How do you check packet ordering in router 1x3?**

**Answer:**

* In scoreboard, maintain **expected queues** per destination port.
* Push packets in order.
* Compare actual vs expected while popping → ensures FIFO ordering.

---

### **Q9. How will you ensure coverage closure in router 1x3 project?**

**Answer:**

* Run mix of **directed + random tests**.
* Add error injection tests.
* Use coverage reports (`$get_coverage()` or tool report).
* Add missing scenarios as new sequences.

---

### **Q10. If functional coverage is 100% but code coverage is 85%, what will you do?**

**Answer:**

* Check which RTL branches are not exercised (e.g., rare error paths).
* Write **directed tests** for those missing conditions.
* Ensure both **functional + code coverage closure**.

---

### **Q11. How will you make router 1x3 UVM testbench reusable for router 1xN?**

**Answer:**

* Parameterize number of outputs in `config_db`.
* Dynamically create `N` agents and scoreboard queues.
* Coverage cross updated with dynamic bins.

---

### **Q12. What are common bugs you may find in router 1x3 during verification?**

**Answer:**

* Wrong FIFO selection (routing bug).
* Packet dropped when busy handling not correct.
* FIFO overflow / underflow.
* Invalid parity not flagged.
* Output valid asserted without data.

---

### **Q13. How do you check router `busy` signal in UVM testbench?**

**Answer:**

* Assertion: If busy=1, then no new packet should be accepted.
* Monitor + scoreboard: If pkt\_valid && busy → packet should not enter FIFO.

---

### **Q14. How will you structure regression tests for router 1x3?**

**Answer:**

* **Basic tests:** Single packet to each port.
* **Stress tests:** Back-to-back packets, long packets.
* **Error tests:** Parity error, invalid header, FIFO full.
* **Random tests:** Constrained-random packets, multiple sequences.

---

### **Q15. How do you debug a scoreboard mismatch in router UVM?**

**Answer:**

* Use `convert2string` to print packet fields.
* Compare expected vs actual field-by-field.
* Check monitors for packet truncation or corruption.
* Add waveform dump for RTL + UVM transaction alignment.

---

## 🔹 Driver Logic (1x3 Router)

* **Input:** Takes `sequence_item` (transaction) from the sequencer.
* **Operation:**

  * Breaks down the transaction into pin-level signals (`pkt_valid`, `data_in`, `resetn`, etc.).
  * Sends **header → payload → parity** in order.
  * Controls handshake (`busy`, `pkt_valid`).
  * Makes sure packet format is correct.
* **Example Logic (pseudo):**

  ```systemverilog
  // Driver main flow
  get_next_item(req);          // from sequencer
  send header to DUT.data_in;
  for each payload byte -> drive on DUT.data_in;
  send parity byte last;
  item_done();                 // to sequencer
  ```

**In Interview:**
👉 “The driver converts high-level transaction into cycle-accurate signal-level stimulus for the DUT. For router, it drives header, payload, and parity with proper handshaking.”

---

## 🔹 Monitor Logic (1x3 Router)

* **Input Side Monitor:**

  * Passive component (no driving).
  * Samples DUT input interface signals.
  * Reconstructs transaction (header, payload, parity).
  * Sends it to analysis port (to scoreboard, coverage).

* **Output Side Monitor(s):**

  * 3 monitors (one per output port).
  * Captures valid data and reconstructed packets per port.
  * Each monitor sends observed packet → scoreboard.

* **Example Logic (pseudo):**

  ```systemverilog
  // Input Monitor
  if(pkt_valid) collect header;
  while(payload_valid) collect data;
  collect parity;
  ap.write(transaction);  // send to scoreboard/coverage
  ```

**In Interview:**
👉 “The monitor passively observes DUT activity, rebuilds the packet, and forwards it through analysis ports to scoreboard and coverage.”

---

## 🔹 Scoreboard Logic (1x3 Router)

* **Expected Model:**

  * Reads **input transaction** from input monitor.
  * Predicts **which output port** the packet should go (based on 2-bit header).

* **Compare:**

  * Matches expected packet with actual packet captured by output monitor of that port.
  * Checks packet integrity (header, payload, parity).
  * Reports PASS/FAIL.

* **Example Logic (pseudo):**

  ```systemverilog
  // Scoreboard
  function void write_in(input_trans t);
     expected_port = t.header[1:0];   // decide output port
     exp_fifo[expected_port].push(t);
  endfunction

  function void write_out(actual_trans t, port_id);
     expected = exp_fifo[port_id].pop();
     if(expected != t)
        `uvm_error("SCB", "Mismatch detected")
  endfunction
  ```

---

✅ **Quick Interview Answer Template:**

* **Driver:** Drives packet (header, payload, parity) to DUT with handshake.
* **Monitor:** Observes DUT I/O, rebuilds transaction, sends via analysis port.
* **Scoreboard:** Predicts expected output port and packet, compares with actual, reports mismatches.

---

