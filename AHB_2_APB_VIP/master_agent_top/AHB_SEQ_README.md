```markdown
# AHB 4 SEQUENCES EXP DETAIELD 
# master_single_xtns
# master_wrap_xtns
# master_incr_1
# master_incr_2

```

---

###master_single_xtns


### Example values (randomized in first transfer)
```systemverilog
* HADDR = 0x1010 (starting address)
* HSIZE = 2 → transfer size = 2**2 = 4 bytes
* HBURST = 3 → **INCR4** burst → HLENGTH = 4 (4 transfers total)
* HWRITE = 1 (write transaction chosen randomly)
```
### Step-by-step operations inside the code

#### **First transfer (NON-SEQUENTIAL)**

* HTRANS = 2’b10 → NON-SEQ
* HADDR = 0x1010
* HSIZE = 2 (4-byte word)
* HBURST = 3 (INCR4)`
* HWRITE = 1
* **Saved for later:** haddr=0x1010, hsize=2, hburst=3, hwrite=1, hlength=4.

#### **Loop for SEQUENTIAL transfers (i = 1 → 3)**

👉 Increment = 2**HSIZE = 4

1. **i = 1**

   * `HADDR = 0x1010 + 0x4 = 0x1014
   * `HTRANS = 2’b11 (SEQ)
   * Other signals same (`HWRITE=1, HBURST=3, HSIZE=2).
   * Save `haddr=0x1014

2. **i = 2**

   * `HADDR = 0x1014 + 0x4 = 0x1018
   * `HTRANS = 2’b11 (SEQ)
   * Signals same.
   * Save `haddr=0x1018.

3. **i = 3**

   * `HADDR = 0x1018 + 0x4 = 0x101C
   * `HTRANS = 2’b11 (SEQ)
   * Signals same.
   * Save `haddr=0x101C.

### **Final Burst Generated**

| Beat | HTRANS | HADDR  | Notes                 |
| ---- | ------ | ------ | --------------------- |
| 0    | 10     | 0x1010 | NON-SEQ (burst start) |
| 1    | 11     | 0x1014 | SEQ                   |
| 2    | 11     | 0x1018 | SEQ                   |
| 3    | 11     | 0x101C | SEQ                   |

✅ So this code creates a **linear incrementing burst (INCR)**:

* First transfer = NON-SEQUENTIAL
* Rest transfers = SEQUENTIAL
* Address increments each beat by `2**HSIZE bytes

---


*master_wrap_xtns

We assume:
````systemverilog
* req.HADDR = 0x1010 = 4112 (decimal)`
* HSIZE = 2 → 2**HSIZE = 4 bytes`
* HLENGTH = 8 (WRAP8 → 8 transfers)`
````
## Step 1: Start address

start_addr = (haddr / (2**hsize * hlength)) * (2**hsize * hlength)

* (2**hsize * hlength) = 4 * 8 = 32 bytes`
* haddr = 0x1010 = 4112`

start_addr = (4112 / 32) * 32
           = 128 * 32
           = 4096

Convert back to hex:
start_addr = 0x1000 (decimal 4096)`

## Step 2: Boundary address

boundary_addr = start_addr + (2**hsize * hlength)
              = 4096 + 32
              = 4128
              
Convert back to hex:
boundary_addr = 0x1020 (decimal 4128)

## Step 3: First update of haddr

haddr = req.HADDR + (2**HSIZE)
      = 4112 + 4
      = 4116
      
Hex: 0x1014

## Step 4: Loop iterations (i = 1 → 7)

### i = 1

* haddr = 0x1014 (4116) (not boundary)
* Transfer = 0x1014 (4116)
* Next haddr = 4116 + 4 = 4120 (0x1018)

### i = 2

* haddr = 0x1018 (4120)
* Transfer = 0x1018 (4120)
* Next haddr = 4120 + 4 = 4124 (0x101C)

### i = 3

* haddr = 0x101C (4124)
* Transfer = 0x101C (4124)
* Next haddr = 4124 + 4 = 4128 (0x1020)


### i = 4

* haddr = 0x1020 (4128) = boundary
* Wrap → haddr = start_addr = 0x1000 (4096)
* Transfer = 0x1000 (4096)
* Next haddr = 4096 + 4 = 4100 (0x1004)

### i = 5

* haddr = 0x1004 (4100)
* Transfer = 0x1004 (4100)
* Next haddr = 4100 + 4 = 4104 (0x1008)


### i = 6

* haddr = 0x1008 (4104)
* Transfer = 0x1008 (4104)
* Next haddr = 4104 + 4 = 4108 (0x100C)

### i = 7

* haddr = 0x100C (4108)
* Transfer = 0x100C (4108)
* Next haddr = 4108 + 4 = 4112 (0x1010)



## ✅ Final Address Sequence (WRAP8)

| Beat        | Hex Addr | Decimal Addr |
| ----------- | -------- | ------------ |
| 0 (NON-SEQ) | 0x1010   | 4112         |
| 1           | 0x1014   | 4116         |
| 2           | 0x1018   | 4120         |
| 3           | 0x101C   | 4124         |
| 4           | 0x1000   | 4096         |
| 5           | 0x1004   | 4100         |
| 6           | 0x1008   | 4104         |
| 7           | 0x100C   | 4108         |

---

### master_incr_1

### Randomized Transfer Result

| Field  | Example Value (Hex) | Example Value (Decimal) | Notes                      |
| ------ | ------------------- | ----------------------- | -------------------------- |
| HTRANS | 2'b10               | 2                       | NON-SEQUENTIAL             |
| HBURST | 0                   | 0                       | SINGLE transfer            |
| HWRITE | 1                   | 1                       | Write (could also be 0)    |
| HADDR  | 0x8000\_03FF        | 2147484671              | Could also be 0x8000\_0000 |
| HSIZE  | 1                   | 2 bytes                 | Transfer size = 2 bytes    |


### Explanation of Transfer Sequence

* Only **one transfer** occurs because HBURST = 0 (SINGLE).
* Address is randomly chosen between the two allowed addresses (0x8000_0000 or 0x8000_03FF).
* Transfer type is NON-SEQUENTIAL.

---

*master_incr_2


* HTRANS = 2’b10 → **NON-SEQUENTIAL** (first transfer)
* HWRITE = 1 → **Write transfer**
* HBURST = 3 → **INCR4** (4-beat incrementing burst)
* HADDR = 0x8C00_0000 = 2348810240 (decimal)
* HSIZE = 2 → transfer size = 2**2 = 4 bytes

So → burst length = 4 transfers, each 4 bytes, address increments by 4.


### Final Address Sequence (INCR4)

| Beat | HTRANS | HADDR (Hex)  | HADDR (Decimal) | Notes               |
| ---- | ------ | ------------ | --------------- | ------------------- |
| 0    | 10     | 0x8C00\_0000 | 2348810240      | NON-SEQ (start)     |
| 1    | 11     | 0x8C00\_0004 | 2348810244      | SEQ                 |
| 2    | 11     | 0x8C00\_0008 | 2348810248      | SEQ                 |
| 3    | 11     | 0x8C00\_000C | 2348810252      | SEQ (last transfer) |

---
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

* **HTRANS**:

  * `2'b10` = **NONSEQ** (first beat of a burst).
  * `2'b11` = **SEQ** (all remaining beats).
* **HBURST** encodes the **length/type** of the burst:

  * `3'b011` = INCR4 (4 beats).
  * `3'b101` = INCR8 (8 beats).
  * `3'b111` = INCR16 (16 beats).
* **HSIZE** = transfer size (log2 of bytes per beat).

  * Example: `HSIZE=2` → 4 bytes per transfer.
* **HADDR** must increment (for INCR) or wrap (for WRAP) depending on HBURST.
  
---
👉 This is the **burst “setup” transfer**.


### 1️⃣ First, recall key signals

* **`haddr`** → Current address.
* **`hsize [2:0]`** → Transfer size (in log2 form).

  * 0 → 1 byte
  * 1 → 2 bytes
  * 2 → 4 bytes
  * 3 → 8 bytes …
  * So actual size = `2**hsize`.
* **`hlength`** → Burst length (e.g., 4, 8, 16 beats).

* HTRANS == 2'b10 → **NONSEQ** = First transfer of burst.
* HWRITE → Randomly decide Read (0) or Write (1).
* HBURST → Must be one of {1,3,5,7}.

  * AHB encoding →

    * 3'b001 = INCR4
    * 3'b011 = INCR8
    * 3'b101 = INCR16
    * 3'b111 = INCR (unspecified length, but usually continuous).
* HSIZE, HADDR , HLENGTH etc. get randomized too (word size, base address, number of transfers).
  
---

## Say HSIZE = 2 (word = 4 bytes), HBURST = INCR4, base HADDR = 0x1000:

| Beat | HTRANS | HADDR  | Notes        |
| ---- | ------ | ------ | ------------ |
| 0    | NONSEQ | 0x1000 | Burst start  |
| 1    | SEQ    | 0x1004 | +4 increment |
| 2    | SEQ    | 0x1008 | +4 increment |
| 3    | SEQ    | 0x100C | +4 increment |

⚡ In short:
**master_incr_xtns generates a legal AHB INCR burst sequence.**

* First item NONSEQ
* Remaining items SEQ
* Address auto-increments by 2**HSIZE
* Control signals remain constant across burst.


## 🔹 `HBURST` field in AHB

* `HBURST[2:0]` encodes the **burst type**.
* Table of legal values (from AMBA 2.0 spec):

| HBURST | Encoding | Meaning                                |
| ------ | -------- | -------------------------------------- |
| 000    | SINGLE   | Single transfer (no burst)             |
| 001    | INCR4    | Incrementing burst of 4                |
| 010    | WRAP4    | Wrapping burst of 4                    |
| 011    | INCR8    | Incrementing burst of 8                |
| 100    | WRAP8    | Wrapping burst of 8                    |
| 101    | INCR16   | Incrementing burst of 16               |
| 110    | WRAP16   | Wrapping burst of 16                   |
| 111    | INCR     | Incrementing burst of undefined length |

---
* `HBURST` is only 3 bits wide → **values go from 0 to 7 only**.
  So 8 doesn’t exist here.
  
* `{1,3,5,7}` = **all incrementing bursts** (INCR4, INCR8, INCR16, INCR).
* `{0,2,4,6}` = SINGLE or WRAP bursts, not allowed in this sequence.
* Why only `{1,3,5,7}` in your code

* ## 🔹 Why not `{0,2,4,6}`

* `000` (0) = SINGLE → **not a burst**, just one transfer.
* `010` (2) = WRAP4 → wrapping burst.
* `100` (4) = WRAP8 → wrapping burst.
* `110` (6) = WRAP16 → wrapping burst.
  

* The sequence is specifically designed to generate **INCR bursts only** (not SINGLE or WRAP).
* INCR encodings are:

  * `001` (1) = INCR4
  * `011` (3) = INCR8
  * `101` (5) = INCR16
  * `111` (7) = INCR (unspecified length)
  ## So `{1,3,5,7}` = all valid **incrementing burst types**.


👉 Those are either **single** or **wrap bursts**, not INCR bursts.
Since the sequence is named **`master_incr_xtns`**, it restricts `HBURST` to INCR only.


---

## 🔹 1. Incrementing Burst (HBURST = INCRx)

* Address **increases sequentially** by the transfer size (`2^HSIZE`).
* Example:

  * `HADDR = 0x00`, HSIZE = 2 (word = 4 bytes).
  * **INCR4 burst**:
    
## 🔹 3. How to Check in RTL / Verification

* **Increment check**:

  ```
  NextAddr = PrevAddr + (2^HSIZE)
  ```
* **Wrap check**:

  ```
  Boundary = BurstLen × (2^HSIZE)
  BaseAddr = (StartAddr / Boundary) × Boundary
  NextAddr = BaseAddr + ((PrevAddr + (2^HSIZE)) % Boundary)
  ```
---

### 🔹 Increment Burst (INCR4, INCR8, INCR16, INCR…)

* Address keeps **increasing continuously**.
* Step = `2^HSIZE` (transfer size).
* Burst length = how many transfers (4, 8, 16, or undefined for INCR).
* Example: INCR4, word transfer (`HSIZE=2 → 4B`):


### 🔹 Wrap Burst (WRAP4, WRAP8, WRAP16)

* Address increases, but **cannot cross boundary**.
* Boundary size = Burst length × Transfer size.
* When address reaches the boundary → wraps to start of boundary.
* Example: WRAP4, word transfer (boundary = 16B):


* **Increment = always keep increasing**.
* **Wrap = increase until boundary → wrap back to 0 of that boundary**.

---

### Example: INCR4 burst

* First beat (randomized NONSEQ):

  * `HTRANS = 2'b10` (NONSEQ)
  * `HBURST = 3'b011` (INCR4 → 4 beats total)
  * `HSIZE = 2` (4 bytes per beat)
  * `HADDR = 0x1000`


#### Beat 2:

* HADDR = 0x1000 + (2\*\*2) = 0x1004
* HTRANS = SEQ
* Others same

Update `haddr = 0x1004`.


#### Beat 3:

* HADDR = 0x1004 + 4 = 0x1008
* HTRANS = SEQ
  Update `haddr = 0x1008`.


#### Beat 4:

* HADDR = 0x1008 + 4 = 0x100C
* HTRANS = SEQ
  Update `haddr = 0x100C`.

### Final timeline for INCR4

| Beat | HTRANS | HBURST | HSIZE | HADDR  |
| ---- | ------ | ------ | ----- | ------ |
| 1    | NONSEQ | INCR4  | 2     | 0x1000 |
| 2    | SEQ    | INCR4  | 2     | 0x1004 |
| 3    | SEQ    | INCR4  | 2     | 0x1008 |
| 4    | SEQ    | INCR4  | 2     | 0x100C |

### If INCR8

Same logic, but `hlength=8`. The loop runs 7 times, so you’d get addresses:

```
0x1000, 0x1004, 0x1008, 0x100C, 0x1010, 0x1014, 0x1018, 0x101C
```

### If INCR16

16 beats → increments 15 times:

```
0x1000, 0x1004, ... up to 0x103C
```

---

### Formula given:

```systemverilog
start_addr   = (haddr / (2**hsize) * (hlength)) * (2**hsize) * (hlength);
boundary_addr = start_addr + (2**hsize) * (hlength);
```


### 2️⃣ Breaking the math
### how to calculate the  bytes , Boundary, Burst Lenghth , 

👉 **Step 1**: `2**hsize`

* Number of bytes per transfer.

👉 **Step 2**: `(2**hsize) * hlength`

* Total burst size in bytes.

👉 **Step 3**: `(haddr / ((2**hsize) * hlength))`

* This divides the address into "burst groups" (integer division).
* Basically: which burst boundary does `haddr` fall into?

👉 **Step 4**: Multiply back by `((2**hsize) * hlength)`

* Gives the **aligned start address** of the current burst group.

👉 **Step 5**: Add `((2**hsize) * hlength)`

* Gives the **boundary address** (end of this burst group).


### 3️⃣ Example

* `haddr   = 0x34` (decimal 52)
* `hsize   = 2` → 2² = 4 bytes per beat
* `hlength = 4` → 4 beats

````systemverilog
**Step A: Beat size** = 2² = **4 bytes**
**Step B: Burst size** = 4 × 4 = **16 bytes**
**Step C: Group** = `52 / 16 = 3` (integer division)
**Step D: Start address** = 3 × 16 = **48 (0x30)**
**Step E: Boundary address** = 48 + 16 = **64 (0x40)**
````

✅ So this burst covers addresses from **0x30 → 0x3F**.
If burst is **WRAP4**, and `haddr = 0x3C` → next address after 0x3F will **wrap back to 0x30**.


---
