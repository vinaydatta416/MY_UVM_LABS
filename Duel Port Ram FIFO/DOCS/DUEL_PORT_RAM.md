# DUEL PORT RAM.SV

----------

| **Signal**   | **Type**          | **Direction** | **Small Description**      |
| ------------ | ----------------- | ------------- | -------------------------- |
| `clk`        | Clock             | Input         | Memory clock signal ⏱️     |
| `mem_en`     | Control           | Input         | Enables memory write block |
| `op_en`      | Control           | Input         | Enables read operation     |
| `data_in`    | Data Bus (64-bit) | Input         | Data written into RAM      |
| `rd_address` | Address (10-bit)  | Input         | Address for read access    |
| `wr_address` | Address (10-bit)  | Input         | Address for write access   |
| `read`       | Control           | Input         | Read request signal        |
| `write`      | Control           | Input         | Write request signal       |
| `data_out`   | Data Bus (64-bit) | Output        | Data read from RAM 📤      |

-------

* `clk` → Positive-edge clock controlling read/write operations ⏱️
* `mem_en` → Enables write logic block
* `op_en` → Enables read logic block
* `data_in[63:0]` → 64-bit input data to be written
* `wr_address[9:0]` → 10-bit write address (1K depth)
* `rd_address[9:0]` → 10-bit read address (1K depth)
* `write` → When HIGH, writes `data_in` to `memory[wr_address]`
* `read` → When HIGH, reads `memory[rd_address]`
* `data_out[63:0]` → 64-bit registered read output; high-Z when `op_en=0` ⚡

----






* **Write Cycle (Practical Flow)** 💾

  * Apply `wr_address`
  * Apply valid `data_in`
  * Set `mem_en=1`
  * Set `write=1`
  * On **posedge `clk`** → Data stored in `memory[wr_address]`

* **Read Cycle (Practical Flow)** 📤

  * Apply `rd_address`
  * Set `op_en=1`
  * Set `read=1`
  * On **posedge `clk`** → Data from `memory[rd_address]` appears on `data_out`

* **Key Practical Notes** ⚙️

  * Both operations are **synchronous** (triggered only at clock edge).
  * Read data available **after one clock edge latency**.
  * Different addresses → Read & Write can happen in same clock cycle.
  * If `op_en=0` → `data_out` goes High-Z (bus idle state).



* `mem_en=1 & write=1 @ clk↑` → `data_in` stored at `memory[wr_address]` 💾
* `op_en=1 & read=1 @ clk↑` → `memory[rd_address]` loaded to `data_out` 📤
* Write and read independent → Separate enable controls ⚡
* `data_out=Z` when `op_en=0` → Output disabled (bus sharing case)
* Dual-port behavior → Different read/write addresses usable simultaneously 🔄

------

# DECODER
-----
# 1
* `mem_in1`, `mem_in0` → 2-bit input (MSB address bits for 4K selection)

* Implements **2-to-4 decoder** 🔀

* Used to select **one of four 1K RAM blocks**

* Operation:

  * `00` → `mem_out0 = 1` (select RAM0)
  * `01` → `mem_out1 = 1` (select RAM1)
  * `10` → `mem_out2 = 1` (select RAM2)
  * `11` → `mem_out3 = 1` (select RAM3)

* Only **one output HIGH at a time** (one-hot encoding) ⚡

* Used as **chip-select logic** for building 4K RAM from 1K RAM blocks.

# 2

* Decoder uses **top 2 address bits** → selects which 1K RAM block ⚡

* Lower 10 address bits → actual location inside selected RAM 💾

* Example:

  * Addr `0000–1023` → RAM0 selected (`mem_out0=1`)
  * Addr `1024–2047` → RAM1 selected
  * Addr `2048–3071` → RAM2 selected
  * Addr `3072–4095` → RAM3 selected

* Practical flow 🔄

  * CPU gives 12-bit address
  * Top 2 bits → decoder select RAM
  * Remaining bits → internal RAM address

* Result → Multiple small RAMs behave like single 4K RAM.


-------

# RAM 4096 

-----

* Each `dual_mem` = **1K RAM block** 💾
* Required total = **4K RAM → 4 × 1K blocks**
* Decoder selects **one block using top 2 address bits** ⚡
* Parallel instantiation → behaves like **single larger memory**
* Needed for **capacity expansion**, not speed increase 🔄

---

* 4K RAM built using **four 1K RAM blocks (`dual_mem`)** 💾

* Total address = **12 bits** → Top 2 bits select RAM block, remaining bits internal address.

* **Write logic ⚡**

  * `wr_address[11:10]` → Write decoder (`mem_dec`) selects RAM.
  * Selected `mem_wrX=1` enables write in that RAM.
  * Lower bits `wr_address[9:0]` → Actual location.

* **Read logic 📤**

  * `rd_address[11:10]` → Read decoder selects RAM.
  * Selected `mem_rdX=1` enables read.
  * Lower bits `rd_address[9:0]` → Memory index.

* **Tri-state output bus 🔄**

  * Only selected RAM drives `data_out`.
  * Others remain High-Z → avoids bus conflict.

* **Practical flow ⚙️**

  * Give 12-bit address → Decoder picks RAM block.
  * Remaining bits access location inside that RAM.
  * Acts externally like single 4096-word memory.

-----

# RAM_IF.SV

-----

* **`ram_if` → Interface for RAM signals** ⚡ simplifies TB–DUT connection.

* **Basic signals 💾**

  * `data_in` → Write data bus (64-bit).
  * `rd_address`, `wr_address` → 12-bit read/write addresses.
  * `read`, `write` → Control signals.
  * `data_out` → Read data from DUT.
  * `clk` derived from interface `clock`.

* **DUV modport 🔧**

  * Defines DUT direction clearly (inputs/outputs).

* **Driver clocking blocks ⏱️**

  * `wdr_cb` → Drives write signals @posedge clock.
  * `rdr_cb` → Drives read signals + samples output.

* **Monitor clocking blocks 👀**

  * `wmon_cb` → Observes write signals @negedge.
  * `rmon_cb` → Observes read/data_out signals.

* **Purpose 🚀**

  * Avoid race conditions.
  * Structured verification connection.
  * Clean separation of driver, monitor, DUT signals.


--------

* **`wdr_cb` (Write Driver CB) ⏱️**

  * Drives `data_in`, `wr_address`, `write`.
  * Triggered @posedge clock.
  * Used by write driver.

* **`rdr_cb` (Read Driver CB) 📤**

  * Drives `rd_address`, `read`.
  * Samples `data_out`.
  * Also @posedge clock.

* **`wmon_cb` (Write Monitor CB) 👀**

  * Observes write signals only.
  * Triggered @negedge clock.
  * Avoids race with driver.

* **`rmon_cb` (Read Monitor CB) 🔎**

  * Observes read + `data_out`.
  * @negedge clock sampling.

* **Modports purpose ⚡**

  * `DUV_MP` → DUT signal direction control.
  * `WDR_MP`, `RDR_MP` → Driver access via CB.
  * `WMON_MP`, `RMON_MP` → Monitor access via CB.
  * Ensures structured TB–DUT communication.

---------

* **`dual_mem` 💾**

  * 1K × 64 dual-port RAM block.
  * Separate read/write enable (`mem_en`, `op_en`).
  * Synchronous read/write using clock.

* **`mem_dec` 🔀**

  * 2→4 decoder.
  * Uses top address bits.
  * Selects one RAM block (chip select).

* **`ram_4096` ⚡**

  * Combines four 1K RAMs → total 4K memory.
  * Top 2 address bits → block select.
  * Lower bits → internal address.
  * Tri-state output bus shared.

* **`ram_if` 🧩**

  * Interface bundling RAM signals.
  * Clocking blocks for driver/monitor timing.
  * Modports define DUT, driver, monitor access.

* **Overall RTL Flow 🚀**

  * Address → decoder selects RAM.
  * Data written/read via selected block.
  * Interface simplifies verification connection.

------






















