export ICP_ROOT ?= $(PWD)
JOBS := $(shell nproc 2>/dev/null || echo 1)


all:
	$(MAKE) -C quickassist all -j$(JOBS)

kmod:
	$(MAKE) -C quickassist lac -j$(JOBS)

clean:
	$(MAKE) -C quickassist clean

install:
	$(MAKE) -C quickassist install

