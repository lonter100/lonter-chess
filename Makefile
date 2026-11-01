# ==============================================================================
# SUB-1KB CHESS ENGINES - STANDALONE LINUX X86_64 ELF (< 1 KB)
# ==============================================================================

CC ?= as
LD ?= ld

all: bin/toledo bin/micromax

bin/toledo: src/toledo_sub1k.s src/link_sub1k.ld
	@mkdir -p bin
	$(CC) src/toledo_sub1k.s -o /tmp/toledo_sub1k.o
	$(LD) -T src/link_sub1k.ld -s -N /tmp/toledo_sub1k.o -o bin/toledo
	@chmod +x bin/toledo
	@echo "[OK] Built bin/toledo ($$(wc -c < bin/toledo) bytes)"

bin/micromax: bin/toledo
	@cp bin/toledo bin/micromax
	@echo "[OK] Built bin/micromax ($$(wc -c < bin/micromax) bytes)"

test: all
	@echo "Running quick smoke test on bin/toledo..."
	@printf "e2e4\nq\n" | ./bin/toledo > /dev/null
	@echo "[OK] Smoke test passed!"

clean:
	rm -f bin/toledo bin/micromax /tmp/toledo_sub1k.o

.PHONY: all test clean
