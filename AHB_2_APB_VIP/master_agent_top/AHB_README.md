```markdown
# AHB2APB_BRIDGE
```

---

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
* **PRDATA** – Read data from APB peripherals

---

## **AHB Interface Signals**

### **1. HCLK (AHB Clock)**

* Input to the bridge from the AHB master.
* Synchronizes all AHB transactions.
* Every rising edge triggers evaluation of inputs and latching of outputs.



### **2. HRESETn (AHB Reset, Active Low)**
```shell
* Resets the bridge and clears internal state machines.
* Active-low: `0` means reset active, `1` means normal operation.
* All signals default to IDLE or zero during reset.
```


### **3. HTRANS (Transaction Type)**

* 2-bit signal defining the type of AHB transfer:

  * **IDLE (00):** No transfer; master is inactive.
  * **BUSY (01):** Bus is busy, next transfer may follow; no data transfer occurs.
  * **NONSEQ (10):** Start of a new burst transfer or standalone transfer. Address is unrelated to previous.
  * **SEQ (11):** Sequential transfer, part of a burst; address is consecutive after previous transfer.


**Usage in bridge:**

```shell
* Bridge samples HTRANS to determine if it should initiate a new APB transaction.
* IDLE/BUSY → No APB transaction.
* NONSEQ → Start a new APB transaction.
* SEQ → Continue APB transaction in a burst.

```

### **4. HSIZE (Transfer Size)**

* 3-bit signal describing data size for transfer:
```shell
  * 000 → Byte (8 bits)
  * 001 → Halfword (16 bits)
  * 010 → Word (32 bits)
  * 011 → Double word (64 bits) (if supported)
```
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

---



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


---
---
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

---
