# RISC-V Verilog Implementation - 5 Stage Pipeline

## Overview

This project is an implementation of a **RISC-V processor** with a **standard 5-stage pipeline** architecture. The five stages include:

1. **Instruction Fetch (IF)**
2. **Instruction Decode (ID)**
3. **Execution (EX)**
4. **Memory Access (MEM)**
5. **Write Back (WB)**

The project was developed as part of a school assignment to better understand the inner workings of RISC-V architecture and pipeline design principles.

## Features

- **RISC-V 32-bit instruction set**: Supports a subset of the RV32I instruction set.
- **Five-stage pipeline**: Implements all the core stages of a standard CPU pipeline.
- **Hazard detection**: Simple hazard detection and forwarding logic to handle data dependencies.
- **Branch prediction**: Includes a basic branch prediction mechanism.
- **Memory and register file access**: Supports memory access instructions and register file operations.
