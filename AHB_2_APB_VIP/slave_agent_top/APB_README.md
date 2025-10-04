```markdown
# AHB2APB_BRIDGE  

## APB Slave Avent top 

## 📂 Project Structure  
```

---

### **APB Interface Signals (Connected via `apb_if`)**

* **PSELx** – Peripheral select
* **PWRITE** – Write enable for APB
* **PENABLE** – Transfer enable
* **PADDR** – Address bus for APB
* **PWDATA** – Write data to APB peripheral
* **PRDATA** – Read data from APB peripheral

---

## **APB Interface Signals**

### **1. PSELx (Peripheral Select)**

* One-hot signal selecting which APB peripheral is active.
* Bridge asserts PSELx when a transaction targeting that peripheral occurs.

---

### **2. PWRITE**

* 1-bit write enable to APB peripheral.
* Derived from HWRITE of AHB transaction.

---

### **3. PENABLE**

* Indicates **start of APB transfer** (setup + enable phase).
* Asserted **1 cycle after PSELx** according to APB protocol.

---

### **4. PADDR**

* APB address, mapped from HADDR.
* Used to select registers in the peripheral.

---

### **5. PWDATA**

* Write data from bridge to APB peripheral.
* Only valid if PWRITE = 1.

---

### **6. PRDATA**

* Read data from APB peripheral to bridge, then forwarded to HADDR.

---
