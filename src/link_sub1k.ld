PHDRS {
  text PT_LOAD FILEHDR PHDRS FLAGS(7);
}
SECTIONS {
  . = 0x400000 + SIZEOF_HEADERS;
  .text : {
    *(.text)
    *(.data)
  } :text
  .bss (NOLOAD) : {
    *(.bss)
  } :text
}
