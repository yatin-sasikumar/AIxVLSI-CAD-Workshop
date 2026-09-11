# Physical Design

## Overview

Physical design is used to transform the synthesized RTL design into a physical chip layout while performing the required implementation and verification steps.

The workshop uses **LibreLane** to automate the physical design flow and integrate the required backend EDA tools.

The flow takes the design configuration and carries out the backend implementation process, generating layout data, reports, logs, and intermediate results.

---

## Tool

**LibreLane** is used for the physical design flow.

LibreLane runs the backend tools through its Dockerized environment, providing the required tools and dependencies for physical implementation.

The flow uses the **Sky130A** PDK for the physical design process.

---

## Flow

```text
SystemVerilog RTL
       ↓
   Synthesis
       ↓
   Floorplanning
       ↓
    Placement
       ↓
    CTS / Routing
       ↓
   Physical
   Verification
       ↓
   Final Layout