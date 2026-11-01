.global _start
.intel_syntax noprefix
.text
_start:
    # 1. Inicjalizacja tablicy glifow (Zero-Branch LUT)
    movabs rax, 0x2e6b71626e72702e
    mov [rip + glyph_lut], rax
    movabs rax, 0x2e4b51424e52502e
    mov [rip + glyph_lut + 8], rax

    # 2. Inicjalizacja planszy szachowej (0x88) bez petli (64-bit SWAR)
    movabs rax, 0x0a0b0c0e0d0c0b0a
    mov [rip + b + 0], rax
    movabs rax, 0x0909090909090909
    mov [rip + b + 16], rax
    xor rax, rax
    mov [rip + b + 32], rax
    mov [rip + b + 48], rax
    mov [rip + b + 64], rax
    mov [rip + b + 80], rax
    movabs rax, 0x0101010101010101
    mov [rip + b + 96], rax
    movabs rax, 0x0203040605040302
    mov [rip + b + 112], rax

render_frame:
    lea rdi, [rip + frame]
    mov ebx, 7                  # r_idx = 7..0

row_loop:
    lea rax, [rbx + 49]
    mov [rdi], al
    mov byte ptr [rdi + 1], 32
    add rdi, 2

    # r_idx * 16
    mov ecx, ebx
    shl ecx, 4
    lea rsi, [rip + b]
    add rsi, rcx

    xor edx, edx                # f = 0..7
col_loop:
    movzx eax, byte ptr [rsi + rdx]
    and eax, 15
    lea r8, [rip + glyph_lut]
    mov al, [r8 + rax]
    mov [rdi], al
    mov byte ptr [rdi + 1], 32
    add rdi, 2
    inc edx
    cmp edx, 8
    jl col_loop

    mov byte ptr [rdi], 10      # newline
    inc rdi
    dec ebx
    jns row_loop

    # Stopka "  a b c d e f g h\n" (18 bajtow)
    mov word ptr [rdi], 0x2020
    movabs rax, 0x2064206320622061
    mov [rdi + 2], rax
    movabs rax, 0x0a68206720662065
    mov [rdi + 10], rax
    add rdi, 18

    # 1 atomowy SYS_WRITE (framebuffer, 170 bajtow)
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + frame]
    mov edx, 170
    syscall

input_loop:
    # Wypisz prompt "> "
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + prompt]
    mov edx, 2
    syscall

    # SYS_READ (in_buf, 16 bajtow)
    mov eax, 0
    mov edi, 0
    lea rsi, [rip + in_buf]
    mov edx, 16
    syscall

    test eax, eax
    jle game_exit
    cmp byte ptr [rip + in_buf], 'q'
    je game_exit

    cmp byte ptr [rip + in_buf], 10
    je do_engine_move
    cmp eax, 4
    jl render_frame

    # Ruch gracza (e.g. e2e4)
    movzx eax, byte ptr [rip + in_buf + 1] # from_rank
    sub eax, 49
    shl eax, 4
    movzx ecx, byte ptr [rip + in_buf]     # from_file
    sub ecx, 97
    add eax, ecx                          # from_sq

    movzx edx, byte ptr [rip + in_buf + 3] # to_rank
    sub edx, 49
    shl edx, 4
    movzx ecx, byte ptr [rip + in_buf + 2] # to_file
    sub ecx, 97
    add edx, ecx                          # to_sq

    lea rsi, [rip + b]
    mov cl, [rsi + rax]
    mov [rsi + rdx], cl
    mov byte ptr [rsi + rax], 0
    jmp render_frame

do_engine_move:
    lea rsi, [rip + b]
    cmp byte ptr [rsi + 113], 0
    je try_pawn
    mov al, [rsi + 113]
    mov [rsi + 82], al
    mov byte ptr [rsi + 113], 0
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + mv_knight]
    mov edx, 5
    syscall
    jmp render_frame

try_pawn:
    mov al, [rsi + 99]
    mov [rsi + 67], al
    mov byte ptr [rsi + 99], 0
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + mv_pawn]
    mov edx, 5
    syscall
    jmp render_frame

game_exit:
    mov eax, 60
    xor edi, edi
    syscall

.data
prompt:    .ascii "> "
mv_knight: .ascii "b8c6\n"
mv_pawn:   .ascii "d7d5\n"

.bss
b:         .skip 256
frame:     .skip 256
glyph_lut: .skip 32
in_buf:    .skip 32
