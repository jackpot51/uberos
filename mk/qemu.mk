QEMU=SDL_VIDEO_X11_DGAMOUSE=0 qemu-system-$(ARCH)
QEMUFLAGS=-d cpu_reset
QEMUFLAGS+=-smp 4 -m 2048
QEMU_EFI=/usr/share/OVMF/OVMF_CODE.fd
ifeq ($(serial),no)
	QEMUFLAGS+=-chardev stdio,id=debug -device isa-debugcon,iobase=0x402,chardev=debug
else
	QEMUFLAGS+=-chardev stdio,id=debug,signal=off,mux=on,"$(if $(qemu_serial_logfile),logfile=$(qemu_serial_logfile))"
	QEMUFLAGS+=-serial chardev:debug -mon chardev=debug
endif
ifeq ($(iommu),yes)
	QEMUFLAGS+=-machine q35,iommu=on
else
	QEMUFLAGS+=-machine q35
endif
ifneq ($(audio),no)
	QEMUFLAGS+=-device ich9-intel-hda -device hda-duplex
endif
ifeq ($(net),no)
	QEMUFLAGS+=-net none
else
	ifneq ($(bridge),)
		QEMUFLAGS+=-netdev bridge,br=$(bridge),id=net0 -device e1000,netdev=net0,id=nic0
	else
	    ifeq ($(net),redir)
			# port 8080 and 8083 - webservers
			# port 64126 - our gdbserver implementation
			QEMUFLAGS+=-netdev user,id=net0,hostfwd=tcp::8080-:8080,hostfwd=tcp::8083-:8083,hostfwd=tcp::64126-:64126 -device e1000,netdev=net0,id=nic0
		else
			QEMUFLAGS+=-netdev user,id=net0 -device e1000,netdev=net0 \
						-object filter-dump,id=f1,netdev=net0,file=$(WORKING_DIR)build/network.pcap
		endif
	endif
endif
ifeq ($(vga),no)
	QEMUFLAGS+=-nographic -vga none
endif
ifneq ($(usb),no)
	QEMUFLAGS+=-device nec-usb-xhci,id=xhci -device usb-tablet,bus=xhci.0
endif
ifeq ($(gdb),yes)
	QEMUFLAGS+=-s
endif

WSL_QEMU_DIR=$(shell reg.exe query 'HKLM\Software\QEMU' /v Install_Dir /t REG_SZ 2> /dev/null | grep '^    Install_Dir' | sed 's/\s*Install_Dir\s*REG_SZ\s*//g')
ifeq ($(WSL_QEMU_DIR),)
	ifeq ($(UNAME),Linux)
		ifneq ($(kvm),no)
			QEMUFLAGS+=-enable-kvm -cpu host
		else
			QEMUFLAGS+=-cpu max
		endif
	endif
	WORKING_DIR=
else
	QEMUFLAGS+=-accel whpx,kernel-irqchip=off -accel tcg -cpu qemu64,+fpu,+sse,+pae,+pse,+pge,+fxsr,+xsave
	QEMU:="$(shell wslpath -u "$(WSL_QEMU_DIR)\\qemu-system-$(ARCH).exe")"
	WORKING_DIR:=\\"$(shell wslpath -w ./)\\"
endif
#,int,pcall
#-device intel-iommu

ifeq ($(UNAME),Linux)
build/extra.bin:
	fallocate --posix --length 1G $@
else
build/extra.bin:
	truncate -s 1g $@
endif

qemu: build/harddrive.bin build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/harddrive.bin,format=raw \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_no_build: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/harddrive.bin,format=raw \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_efi: build/harddrive-efi.bin build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-bios $(QEMU_EFI) \
		-drive file=$(WORKING_DIR)build/harddrive-efi.bin,format=raw \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_efi_no_build: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-bios $(QEMU_EFI) \
		-drive file=$(WORKING_DIR)build/harddrive-efi.bin,format=raw \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_nvme: build/harddrive.bin build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/harddrive.bin,format=raw,if=none,id=drv0 -device nvme,drive=drv0,serial=NVME_SERIAL \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw,if=none,id=drv1 -device nvme,drive=drv1,serial=NVME_EXTRA

qemu_nvme_no_build: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/harddrive.bin,format=raw,if=none,id=drv0 -device nvme,drive=drv0,serial=NVME_SERIAL \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw,if=none,id=drv1 -device nvme,drive=drv1,serial=NVME_EXTRA

qemu_nvme_efi: build/harddrive-efi.bin build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-bios $(QEMU_EFI) \
		-drive file=$(WORKING_DIR)build/harddrive-efi.bin,format=raw,if=none,id=drv0 -device nvme,drive=drv0,serial=NVME_SERIAL \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw,if=none,id=drv1 -device nvme,drive=drv1,serial=NVME_EXTRA

qemu_nvme_efi_no_build: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-bios $(QEMU_EFI) \
		-drive file=$(WORKING_DIR)build/harddrive-efi.bin,format=raw,if=none,id=drv0 -device nvme,drive=drv0,serial=NVME_SERIAL \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw,if=none,id=drv1 -device nvme,drive=drv1,serial=NVME_EXTRA

qemu_nvme_live: build/livedisk.bin build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/livedisk.bin,format=raw,if=none,id=drv0 -device nvme,drive=drv0,serial=NVME_SERIAL \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw,if=none,id=drv1 -device nvme,drive=drv1,serial=NVME_EXTRA

qemu_nvme_live_no_build: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/livedisk.bin,format=raw,if=none,id=drv0 -device nvme,drive=drv0,serial=NVME_SERIAL \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw,if=none,id=drv1 -device nvme,drive=drv1,serial=NVME_EXTRA

qemu_live: build/livedisk.bin build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/livedisk.bin,format=raw \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_live_no_build: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/livedisk.bin,format=raw \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_iso: build/livedisk.iso build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-boot d -cdrom $(WORKING_DIR)build/livedisk.iso \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_iso_no_build: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-boot d -cdrom build/livedisk.iso \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_iso_efi: build/livedisk-efi.iso build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-bios $(QEMU_EFI) \
		-boot d -cdrom $(WORKING_DIR)build/livedisk-efi.iso \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_iso_efi_no_build: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-bios $(QEMU_EFI) \
		-boot d -cdrom $(WORKING_DIR)build/livedisk-efi.iso \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_extra: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw

qemu_nvme_extra: build/extra.bin
	$(QEMU) $(QEMUFLAGS) \
		-drive file=$(WORKING_DIR)build/extra.bin,format=raw,if=none,id=drv1 -device nvme,drive=drv1,serial=NVME_EXTRA
