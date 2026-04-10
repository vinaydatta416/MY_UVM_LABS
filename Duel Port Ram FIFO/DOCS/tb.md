## 🔥 What Actually Happens in This Test Library (Practically, Step-by-Step)

You only need to understand **one test flow**. All other tests behave the same — only sequence changes.

We’ll use `ram_single_addr_test` as example.

---

# 🌳 Execution Flow (Runtime Order)

```
UVM starts
   ↓
ram_single_addr_test created
   ↓
build_phase()
   ↓
config objects created
   ↓
env (ram_tb) created
   ↓
run_phase()
   ↓
virtual sequence started
   ↓
stimulus → drivers → DUT
```

---

# 🧠 1️⃣ What Happens in `ram_base_test`

This class does **all infrastructure setup**.

## ✔ Step 1 — Create Environment Config

```systemverilog
m_tb_cfg = ram_env_config::type_id::create("m_tb_cfg");
```

👉 This object controls:

* number of DUTs
* has read agent
* has write agent
* scoreboard enable

Think of this as **environment blueprint**.

---

## ✔ Step 2 — Allocate Agent Config Arrays

```systemverilog
m_tb_cfg.m_wr_agent_cfg = new[no_of_duts];
m_tb_cfg.m_rd_agent_cfg = new[no_of_duts];
```

Since:

```
no_of_duts = 4
```

You now have:

```
Write Agents: [0] [1] [2] [3]
Read Agents : [0] [1] [2] [3]
```

👉 Each one corresponds to one RAM interface.

---

## ✔ Step 3 — `config_ram()` Does Real Wiring

Inside loop:

```systemverilog
m_wr_cfg[i] = ram_wr_agent_config::type_id::create(...)
```

Then:

```systemverilog
uvm_config_db#get(..., $sformatf("vif_%0d",i), ...)
```

👉 This connects **virtual interface** to each agent.

If missing → simulation stops.

---

### Practical Meaning

| i | Interface Connected |
| - | ------------------- |
| 0 | vif_0               |
| 1 | vif_1               |
| 2 | vif_2               |
| 3 | vif_3               |

Each agent controls **one RAM instance**.

---

## ✔ Step 4 — Pass Config to Environment

```systemverilog
uvm_config_db#set(this,"*","ram_env_config",m_tb_cfg);
```

👉 Now `ram_tb` can retrieve full configuration.

---

## ✔ Step 5 — Create Environment

```systemverilog
ram_envh = ram_tb::type_id::create("ram_envh", this);
```

Environment now builds:

```
wr_agent[4]
rd_agent[4]
virtual_sequencer
scoreboard
```

Everything wired using config object.

---

# 🧠 2️⃣ What Happens in Derived Test (`ram_single_addr_test`)

This class does **only stimulus selection**.

Nothing else.

---

## ✔ run_phase()

```systemverilog
phase.raise_objection(this);
```

Prevents simulation from ending.

---

### Create Virtual Sequence

```systemverilog
ram_seqh = ram_single_vseq::type_id::create("ram_seqh");
```

This sequence contains logic like:

```
write to one address
read same address
compare
```

---

### Start Sequence on Virtual Sequencer

```systemverilog
ram_seqh.start(ram_envh.v_sequencer);
```

Now actual execution happens:

```
virtual sequence
   ↓
select wr_sequencer[i]
select rd_sequencer[i]
   ↓
drivers
   ↓
interface
   ↓
DUT
```

---

## ✔ drop_objection()

```systemverilog
phase.drop_objection(this);
```

Simulation ends when no objections remain.

---

# 🧩 Communication Flow (Very Important)

```
Test
  ↓
Virtual Sequence
  ↓
Virtual Sequencer
  ↓
Write/Read Sequencers
  ↓
Drivers
  ↓
Interface
  ↓
DUT
  ↓
Monitors
  ↓
Scoreboard
```

---

# 📌 What This Library Is Doing Architecturally

| Layer        | Responsibility             |
| ------------ | -------------------------- |
| Base Test    | Builds env + config        |
| Derived Test | Chooses stimulus           |
| Env          | Builds agents + scoreboard |
| Virtual Seq  | Controls multiple agents   |
| Agent        | Drives one interface       |
| Driver       | Pin-level control          |
| Monitor      | Captures DUT activity      |
| Scoreboard   | Data checking              |

---

# 🧠 Why Use Base + Derived Structure?

Instead of copying code 4 times:

* Base test builds environment once
* Each derived test changes only sequence

Clean reuse.

---

# ⚠️ Important Practical Observations

### 1️⃣ Config DB Must Match Interface Names

If top TB does not:

```systemverilog
uvm_config_db#set(null,"*","vif_0",ram_if_inst0);
```

You get fatal error.

---

### 2️⃣ no_of_duts = 4 Means

Environment expects 4 interfaces.

If DUT has only 1 → mismatch crash.

---

### 3️⃣ Virtual Sequencer Required

Because:

You have multiple write/read agents.

Without virtual sequencer:
You cannot coordinate them.

---

# 🔥 What Actually Happens During One Transaction

Example:

```
ram_single_vseq generates:
   write addr=100
   read addr=100
```

Flow:

```
Write seq → wr_agent[0] → driver → DUT
Monitor captures write
Scoreboard stores expected

Read seq → rd_agent[0] → driver → DUT
Monitor captures read
Scoreboard compares
```

---

# 🚀 Key Takeaways

### ✔ Base test = Infrastructure builder

### ✔ Derived test = Stimulus selector

### ✔ Config DB = Wiring mechanism

### ✔ Virtual sequence = Multi-agent control

### ✔ Agents mapped per DUT interface

---

If you want next:

* What virtual sequencer should contain
* How vseq selects which agent
* How scoreboard handles 4 DUTs
* Common interview traps from this structure

Tell.
