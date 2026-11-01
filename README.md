# Sub-1KB Chess: Self-Contained Chess Engines for Linux (< 1 KB)

A collection of ultra-compact, fully playable chess engines compiled down to **sub-1KB standalone Linux x86_64 ELF binaries (952 bytes)**.

These binaries are completely self-contained. They require **zero external dependencies, zero shared libraries (`libc.so.6` is not used), zero runtime interpreters, and no additional files**. You can download a single 952-byte file onto a fresh Linux installation and run it immediately.

---

## Highlights

- **Ultra-Small Binary Size**: Exactly **952 bytes** on disk (well below the 1024-byte mark).
- **100% Standalone**: Direct kernel system calls (`SYS_READ`, `SYS_WRITE`, `SYS_EXIT`). Running `ldd` verifies: `not a dynamic executable`.
- **Zero-Branch Piece Lookup (LUT)**: Replaced cascading `if/else` checks with a single O(1) memory lookup table, eliminating CPU branch mispredictions.
- **Zero-Loop SWAR Initialization**: The entire 0x88 board state is initialized using eight 64-bit SIMD/SWAR memory stores.
- **Single-Syscall Atomic Display**: The 8x8 ASCII board and coordinates are constructed in a scratch buffer and flushed to stdout in a single 170-byte `sys_write` call.
- **Standard Algebraic Notation**: Enter standard moves like `e2e4`, `g1f3`, `d2d4`, or press `ENTER` on an empty prompt for engine responses.

---

## Size Comparison

| Variant | Size | Standalone? | External Dependencies |
| :--- | :--- | :--- | :--- |
| **`bin/toledo` (Sub-1KB ELF)** | **952 B** | **Yes (100%)** | **None (Direct Syscalls)** |
| **`bin/micromax` (Sub-1KB ELF)** | **952 B** | **Yes (100%)** | **None (Direct Syscalls)** |
| `toledo_ultra.hnib` (Polyglot) | 186 B | No | Needs launcher / AVM |
| Original C compiled dynamic (`gcc -Os`) | 15 KB | No | Requires `libc.so.6` |
| Original C compiled static (`gcc -static -Os`) | 695 KB | Yes | Huge libc bundle (730x larger) |

---

## Quickstart

### 1. Download and Run Immediately
No installation or root privileges required:
```bash
# Clone the repository
git clone https://github.com/lonter100/sub1k-chess.git
cd sub1k-chess

# Run either engine directly
chmod +x bin/toledo
./bin/toledo
```

### 2. Gameplay Example
```text
8 r n b q k b n r 
7 p p p p p p p p 
6 . . . . . . . . 
5 . . . . . . . . 
4 . . . . . . . . 
3 . . . . . . . . 
2 P P P P P P P P 
1 R N B Q K B N R 
  a b c d e f g h
> e2e4
8 r n b q k b n r 
7 p p p p p p p p 
6 . . . . . . . . 
5 . . . . . . . . 
4 . . . . P . . . 
3 . . . . . . . . 
2 P P P P . P P P 
1 R N B Q K B N R 
  a b c d e f g h
> 
```
- Type your move in 4-character algebraic format (e.g. `e2e4`, `d2d4`).
- Press `ENTER` on an empty line for the engine to compute and make a move.
- Type `q` to quit.

---

## How it Fits Under 1 KB

Standard C toolchains generate binaries starting at 4 KB to 16 KB due to default 4096-byte page alignment padding, section headers, string tables, and dynamic linking headers.

To shrink the entire playable chess engine below 1 KB:

1. **120-Byte Single-Segment RWX ELF Header**:
   Instead of separate readable-executable (`RX`) and readable-writable (`RW`) segments, a single unified `RWX` segment (`PF_R | PF_W | PF_X`) maps code, data, and stack in 120 bytes.
2. **Zero Section Headers**:
   All section headers (`.symtab`, `.strtab`, `.shstrtab`) are discarded (`e_shoff = 0`), leaving only raw machine execution.
3. **In-Memory BSS via NOLOAD**:
   Board state buffers and framebuffers are mapped via `p_memsz > p_filesz` without adding any physical bytes to the file on disk.
4. **Direct Register Syscalls**:
   Input and output use native 2-byte x86_64 `syscall` (`0x0F 0x05`) instructions.

---

## Building from Source

You can build the binaries using standard GNU assembler and linker:
```bash
make clean
make all
make test
```

---

## Credits & References

- **Toledo Nanochess**: Created by Oscar Toledo G. ([nanochess.org](https://nanochess.org/))
- **MicroMax Chess**: Created by H.G. Muller ([home.hccnet.nl/h.g.muller](https://home.hccnet.nl/h.g.muller/))
- **Sub-1KB Architecture & Synthesis**: Developed as part of the H-Lang Sovereign Computing Project.

---

## License

MIT License. Free for educational, research, and hobbyist use.
