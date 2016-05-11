################################################################
# This file is provided under a dual BSD/GPLv2 license.  When using or 
#   redistributing this file, you may do so under either license.
# 
#   GPL LICENSE SUMMARY
# 
#   Copyright(c) 2007-2013 Intel Corporation. All rights reserved.
# 
#   This program is free software; you can redistribute it and/or modify 
#   it under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
# 
#   This program is distributed in the hope that it will be useful, but 
#   WITHOUT ANY WARRANTY; without even the implied warranty of 
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
#   General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License 
#   along with this program; if not, write to the Free Software 
#   Foundation, Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
#   The full GNU General Public License is included in this distribution 
#   in the file called LICENSE.GPL.
# 
#   Contact Information:
#   Intel Corporation
# 
#   BSD LICENSE 
# 
#   Copyright(c) 2007-2013 Intel Corporation. All rights reserved.
#   All rights reserved.
# 
#   Redistribution and use in source and binary forms, with or without 
#   modification, are permitted provided that the following conditions 
#   are met:
# 
#     * Redistributions of source code must retain the above copyright 
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in 
#       the documentation and/or other materials provided with the 
#       distribution.
#     * Neither the name of Intel Corporation nor the names of its 
#       contributors may be used to endorse or promote products derived 
#       from this software without specific prior written permission.
# 
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
#   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
#   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
#   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
#   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
#   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
#   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
#   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# 
#  version: QAT1.5.L.1.11.0-36
################################################################

export ICP_ROOT?=$(PWD)/..
export ICP_BUILD_OUTPUT=$(ICP_ROOT)/build
export ICP_BUILDSYSTEM_PATH=$(ICP_ROOT)/quickassist/build_system/
export ICP_TOOLS_TARGET="accelcomp"
export ICP_ENV_DIR=$(ICP_ROOT)/quickassist/build_system/build_files/env_files
export ICP_NONBLOCKING_PARTIALS_PERFORM=1
export KERNEL_SOURCE_ROOT=/usr/src/linux-headers-`uname -r`

PATH_TO_FILE=/lib64 /lib /lib64/* /lib/* /usr /usr/*
KERNEL_HEADER_FILE_LIST=$(sort $(shell cat $(ICP_BUILD_OUTPUT)/kernel_header_file_list.txt))
KERNEL_HEADER_FILE_PATH=$(strip $(KERNEL_SOURCE_ROOT))/include/linux 
include $(ICP_ENV_DIR)/environment.mk
# Ensure The ICP_ROOT environmental var is defined.
ifndef ICP_ROOT
$(error ICP_ROOT is undefined. Please set the path \
        "-> setenv ICP_ROOT <path to root of Source Code>")
endif

DATE=$(shell date '+%m_%d_%y')

ifdef WITH_CPA_MUX
ifdef ICP_DC_ONLY
$(error ICP_DC_ONLY build flag is not supported with MUX)
endif
BASENAME=qat_1_5_mux
endif

ifndef WITH_CPA_MUX
BASENAME=icp_qa_al
endif

ifeq ($(ADF_PLATFORM), ACCELDEVVF)
	DRIVER=$(BASENAME)_vf.ko
else
	DRIVER=$(BASENAME).ko
endif

#Paths to Top-Level Makefiles for each team####

OSAL_PATH=$(ICP_ROOT)/quickassist/utilities/osal/
HAL_PATH=$(ICP_ROOT)/quickassist/utilities/downloader/
HAL_LIB_PATH=$(ICP_ROOT)/quickassist/utilities/downloader/
QAT_FW_PATH=$(ICP_ROOT)/quickassist/lookaside/firmware/
LAC_PATH=$(ICP_ROOT)/quickassist/lookaside/access_layer/
CPA_MUX_PATH=$(ICP_ROOT)/../cpa_mux/src
CONFIG_PATH=$(ICP_ROOT)/quickassist/config/
ICP_TOOLS_TARGET?=accelcomp
ADF_PATH = $(ICP_ROOT)/quickassist/adf/
ICP_BUILD_OUTPUT?=build_$(DATE)
ICP_TOP_ENV=$(ICP_BUILDSYSTEM_PATH)/build_files/env_files/
export ICP_ACCEL_INC=YES
LAC_LIB_DIR=$(LAC_PATH)/build/libs
export DRBG_POLL_AND_WAIT=1
#Release Package build steps
ALL_TARGETS =  clean output_dir lac_lib_dir libosal libosal_user hal adf adf_user lac lac_user qat-fw install_scripts
ICP_ARCH_USER?=`uname -m`

ifdef ICP_SRIOV
ALL_TARGETS += libosalvf adfvf lacvf libosal_uservf
endif

.PHONY: all
all: $(ALL_TARGETS)
	@echo 'Build Done';

.PHONY: install
install:
	@install -m 0644 $(ICP_BUILD_OUTPUT)/*.bin /lib/firmware
	@install -m 0644 $(ICP_BUILD_OUTPUT)/*.ko /lib/modules/`uname -r`/kernel/drivers/crypto
	@install -m 0755 $(ICP_BUILD_OUTPUT)/adf_ctl /sbin
	@install -m 0644 $(ICP_BUILD_OUTPUT)/*.a /usr/lib
	@install -m 0755 $(ICP_BUILD_OUTPUT)/*.so /usr/lib
	@ldconfig
	@depmod -a
	@echo "sha256" > /lib/modules-load.d/quickassist.conf
	@echo "sha512" >> /lib/modules-load.d/quickassist.conf
	@echo "icp_qa_al" >> /lib/modules-load.d/quickassist.conf
	@echo 'KERNEL=="icp_adf_ctl" MODE="0600"' > /lib/udev/rules.d/80-c2xxx_qa.rules
	@echo 'KERNEL=="icp_dev[0-9]*" MODE="0600"' >> /lib/udev/rules.d/80-c2xxx_qa.rules
	@echo 'KERNEL=="icp_dev_mem?" MODE="0600"' >> /lib/udev/rules.d/80-c2xxx_qa.rules
	@udevadm control --reload-rules
	@udevadm trigger
	@install -m 0644 $(ICP_BUILD_OUTPUT)/c2xxx_qa_dev0.conf /etc
	@install -m 0644 $(ICP_BUILDSYSTEM_PATH)/build_files/quickassist.service /lib/systemd/system
	@systemctl daemon-reload
	@modprobe icp_qa_al
	@sleep 2
	@systemctl enable quickassist
	@systemctl start quickassist

.PHONY: user
user: lac_lib_dir libosal_user adf_user lac_user

.PHONY: kernel
kernel: lac_lib_dir libosal hal adf lac qat-fw install_scripts

.PHONY: install_scripts
install_scripts:
	@echo ; echo 'Copying Install Scripts';
	@cp $(ICP_BUILDSYSTEM_PATH)/build_files/quickassist.service $(ICP_BUILD_OUTPUT)/;
	@cp $(CONFIG_PATH)/dh89xxcc_qa_dev0.conf $(ICP_BUILD_OUTPUT)/;
	@cp $(CONFIG_PATH)/dh89xxcc_qa_dev1.conf $(ICP_BUILD_OUTPUT)/;
	@cp $(CONFIG_PATH)/dh89xxcc_qa_dev0_single_accel.conf $(ICP_BUILD_OUTPUT)/;
	@cp $(CONFIG_PATH)/c2xxx_qa_dev0.conf $(ICP_BUILD_OUTPUT)/;


.PHONY: libosal
libosal: output_dir lac_lib_dir
	@echo ; echo 'Building lib OSAL';
	@cd $(OSAL_PATH)/src && export ONE_KO_RELEASE_PACKAGE=1 && $(MAKE) ICP_ENV_DIR=$(ICP_TOP_ENV) OS_LEVEL=linux ICP_OS_LEVEL=kernel_space lib_kernel
	@cd $(OSAL_PATH)/src  && mkdir -p build/linux_2.6/kernel_space/
	@cd $(OSAL_PATH)/src  && cp ./linux/kernel_space/build/linux_2.6/kernel_space/libosal.a ./build/linux_2.6/kernel_space/
	@cd $(OSAL_PATH)/src  && cp ./linux/kernel_space/build/linux_2.6/kernel_space/libosal.a $(LAC_LIB_DIR)/


.PHONY: libosal_user
libosal_user: output_dir lac_lib_dir
	@echo ; echo 'Building OSAL for user space';
	@cd $(OSAL_PATH)/src && $(MAKE) ARCH=$(ICP_ARCH_USER) ICP_ENV_DIR=$(ICP_TOP_ENV) OS_LEVEL=linux ICP_OS_LEVEL=user_space lib;\
	echo ; echo 'Copying OSAL library';
	cp $(OSAL_PATH)/src/build/linux_2.6/user_space/libosal.a $(ICP_BUILD_OUTPUT)/;

.PHONY: hal
hal: output_dir libosal
	@echo ; echo 'Building Hal Libs';
	@cd $(HAL_PATH)/Target_CoreLibs/makDefs && $(MAKE) -f coreLibs_kernel.mak ICP_TOOLS_TARGET=$(ICP_TOOLS_TARGET);
	@echo ; echo 'Copying HAL Binary to $(LAC_LIB_DIR)';
	@cp $(HAL_LIB_PATH)/lib_linux_le/$(ICP_TOOLS_TARGET)/icp_ae_loader_kernel.a $(LAC_LIB_DIR)/

.PHONY: adf
adf: output_dir lac_lib_dir libosal hal
	@echo ; echo 'Building ADF';
	@cd $(ADF_PATH) && export ADF_PLATFORM=ACCELDEV && export ICP_ENV_DIR=$(ICP_TOP_ENV) export ONE_KO_RELEASE_PACKAGE=1 && ICP_OS_LEVEL=kernel_space && $(MAKE);
	cp $(ADF_PATH)/build/linux_2.6/libadf.a $(LAC_LIB_DIR)/;

.PHONY: libosalvf
libosalvf: output_dir lac_lib_dir
	@echo ; echo 'Building lib OSAL';
	@cd $(OSAL_PATH)/src && export ICP_WITHOUT_IOMMU=1 && export ONE_KO_RELEASE_PACKAGE=1 && $(MAKE) ICP_ENV_DIR=$(ICP_TOP_ENV) OS_LEVEL=linux ICP_OS_LEVEL=kernel_space lib_kernel
	@cd $(OSAL_PATH)/src  && mkdir -p build/linux_2.6/kernel_space/
	@cd $(OSAL_PATH)/src  && cp ./linux/kernel_space/build/linux_2.6/kernel_space/libosal.a ./build/linux_2.6/kernel_space/
	@cd $(OSAL_PATH)/src  && cp ./linux/kernel_space/build/linux_2.6/kernel_space/libosal.a $(LAC_LIB_DIR)/

.PHONY: libosal_uservf
libosal_uservf: output_dir lac_lib_dir
	@echo ; echo 'Building OSAL for user space';
	@cd $(OSAL_PATH)/src && export ICP_WITHOUT_IOMMU=1 && $(MAKE) ICP_ENV_DIR=$(ICP_TOP_ENV) OS_LEVEL=linux ICP_OS_LEVEL=user_space lib;\
	echo ; echo 'Copying OSAL library';
	cp $(OSAL_PATH)/src/build/linux_2.6/user_space/libosal.a $(ICP_BUILD_OUTPUT)/;

.PHONY: adfvf
adfvf: output_dir lac_lib_dir libosalvf
	@echo ; echo 'Building ADFVF';
	@cd $(ADF_PATH) && export ADF_PLATFORM=ACCELDEVVF && export ICP_ENV_DIR=$(ICP_TOP_ENV) export ONE_KO_RELEASE_PACKAGE=1 && ICP_OS_LEVEL=kernel_space && $(MAKE);
	cp $(ADF_PATH)/build/linux_2.6/libadf.a $(LAC_LIB_DIR)/;

.PHONY: adf_user
adf_user: output_dir lac_lib_dir libosal_user
	@echo ; echo 'Building user ADF';
	@cd $(ADF_PATH) && export ADF_PLATFORM=ACCELDEV && export ICP_ENV_DIR=$(ICP_TOP_ENV) && export ONE_KO_RELEASE_PACKAGE=1 && ICP_OS_LEVEL=user_space && $(MAKE) ARCH=$(ICP_ARCH_USER) adf_user;
	cp $(ADF_PATH)/build/linux_2.6/libadf_proxy.a $(ICP_BUILD_OUTPUT)/;
	cp $(ADF_PATH)/build/linux_2.6/adf_ctl $(ICP_BUILD_OUTPUT)/;

.PHONY: lac
lac: output_dir libosal hal adf
	@echo ; echo 'Building LAC';
ifdef WITH_CPA_MUX
	@cp $(CPA_MUX_PATH)/Module.symvers $(LAC_PATH)/src/
endif

	@cd $(LAC_PATH) && export ICP_ENV_DIR=$(ICP_TOP_ENV) && export ONE_KO_RELEASE_PACKAGE=1 && cd src && $(MAKE) ICP_OS_LEVEL=kernel_space OS_LEVEL=linux;
	@cp $(LAC_PATH)/src/build/linux_2.6/kernel_space/$(DRIVER) $(ICP_BUILD_OUTPUT)/;

.PHONY: lacvf
lacvf: output_dir libosalvf adfvf
	@echo ; echo 'Building LACVF';
ifdef WITH_CPA_MUX
	@cp $(CPA_MUX_PATH)/Module.symvers $(LAC_PATH)/src/
endif
	@cd $(LAC_PATH) && export ADF_PLATFORM=ACCELDEVVF && export ICP_ENV_DIR=$(ICP_TOP_ENV) && export ONE_KO_RELEASE_PACKAGE=1 && cd src && $(MAKE) ICP_OS_LEVEL=kernel_space OS_LEVEL=linux;
	@cp $(LAC_PATH)/src/build/linux_2.6/kernel_space/$(BASENAME)_vf.ko $(ICP_BUILD_OUTPUT)/;

.PHONY: lac_user
lac_user: output_dir libosal_user adf_user
	@echo ; echo 'Building LAC in user space';
	@cd $(LAC_PATH) && export ICP_ENV_DIR=$(ICP_TOP_ENV) && export ONE_KO_RELEASE_PACKAGE=1 && cd src && $(MAKE) ARCH=$(ICP_ARCH_USER) lib_static ICP_OS_LEVEL=user_space;
	cp $(LAC_PATH)/src/build/linux_2.6/user_space/lib$(BASENAME).a $(ICP_BUILD_OUTPUT)/;
	@cd $(LAC_PATH) && export ICP_ENV_DIR=$(ICP_TOP_ENV) && export ONE_KO_RELEASE_PACKAGE=1 && cd src && $(MAKE) ARCH=$(ICP_ARCH_USER) lib_shared ICP_OS_LEVEL=user_space;
	cp $(LAC_PATH)/src/build/linux_2.6/user_space/lib$(BASENAME)_s.so $(ICP_BUILD_OUTPUT)/;

.PHONY: qat-fw
qat-fw: output_dir
	@cp -f $(QAT_FW_PATH)/icp_qat_ae.mof $(ICP_BUILD_OUTPUT)/mof_firmware.bin;
	@echo ; echo 'Copying QAT-FW Binary';
	@echo ; echo 'Copying MMP Binary';
	@cp -f $(QAT_FW_PATH)/icp_qat_pke.mof $(ICP_BUILD_OUTPUT)/mmp_firmware.bin;
	@echo ; echo 'Copying C2XXX QAT-FW Binary';
	@cp -f $(QAT_FW_PATH)/icp_qat_nae.mof $(ICP_BUILD_OUTPUT)/mof_firmware_c2xxx.bin;
	@echo ; echo 'Copying C2XXX MMP Binary';
	@cp -f $(QAT_FW_PATH)/icp_qat_pke.mof $(ICP_BUILD_OUTPUT)/mmp_firmware_c2xxx.bin;

.PHONY: clean
.NOTPARALLEL: clean
clean:
	@echo ; echo 'Cleaning OSAL';
	@cd $(OSAL_PATH)/src && $(MAKE) ICP_ENV_DIR=$(ICP_TOP_ENV) ICP_OS_LEVEL=kernel_space OS_LEVEL=linux osal_clean;
	@cd $(OSAL_PATH)/src && $(MAKE) ICP_ENV_DIR=$(ICP_TOP_ENV) ICP_OS_LEVEL=user_space OS_LEVEL=linux osal_clean;
	@echo ; echo 'Cleaning LAC';
	@cd $(LAC_PATH) && export ICP_ENV_DIR=$(ICP_TOP_ENV) && cd src && $(MAKE) lac_clean ICP_OS_LEVEL=kernel_space;
	@cd $(LAC_PATH) && export ICP_ENV_DIR=$(ICP_TOP_ENV) && cd src && $(MAKE) lac_clean ICP_OS_LEVEL=user_space;
	@echo ; echo 'Cleaning Hal Libs';
	@cd $(HAL_PATH)/Target_CoreLibs/makDefs/ && $(MAKE) SYS=LINUX -f coreLibs_kernel.mak  clean;
	@echo ; echo 'Cleaning ADF';
	@cd $(ADF_PATH) && export ADF_PLATFORM=ACCELDEV && export ICP_ENV_DIR=$(ICP_TOP_ENV) && export ADF_DIR=$(ADF_PATH) && export OSAL_DIR=$(OSAL_PATH) && export HAL_LIB_DIR=$(HAL_LIB_PATH) && $(MAKE) clean
	@echo ; echo 'Cleaning Binaries in Output Dir';
	@rm -rf $(ICP_BUILD_OUTPUT);
	@rm -rf $(LAC_LIB_DIR);
	@cd $(ICP_ROOT);
	@find -type f -name "*.cmd" | xargs rm -f
	@find -type f -name "*.o" | xargs rm -f
	@echo 'Cleaning done';

.PHONY: output_dir
output_dir: clean
	test -d $(ICP_BUILD_OUTPUT) || mkdir -p $(ICP_BUILD_OUTPUT);

.PHONY: lac_lib_dir
lac_lib_dir: clean
	test -d $(LAC_LIB_DIR) || mkdir -p $(LAC_LIB_DIR);

.PHONY: osal_depend
osal_depend:
	@cd $(OSAL_PATH)/src; grep "include <linux*" `find . -iname "*.c"` | cut -d '<' -f2 | cut -d '/' -f2 | cut -d '>' -f1 | sort | uniq > ${ICP_BUILD_OUTPUT}/temp_list.txt;  

.PHONY: adf_depend
adf_depend:
	@cd $(ADF_PATH); grep "include <linux*" `find . -iname "*.c"` | cut -d '<' -f2 | cut -d '/' -f2 | cut -d '>' -f1 | sort | uniq  >> ${ICP_BUILD_OUTPUT}/temp_list.txt;

.PHONY: lac_depend
lac_depend:
	@cd $(LAC_PATH)/src; grep "include <linux*" `find . -iname "*.c"` | cut -d '<' -f2 | cut -d '/' -f2 | cut -d '>' -f1 | sort | uniq >> ${ICP_BUILD_OUTPUT}/temp_list.txt;
	@sort ${ICP_BUILD_OUTPUT}/temp_list.txt | uniq > ${ICP_BUILD_OUTPUT}/kernel_header_file_list.txt;rm ${ICP_BUILD_OUTPUT}/temp_list.txt;

.PHONY: depend
depend: output_dir osal_depend adf_depend lac_depend
	@echo -e "Building kernel source header file dependency list; Refer ${ICP_BUILD_OUTPUT}/kernel_header_file_list.txt for header files which are used to build other kernel space objects and binaries\n"; 
	@for file in  $(KERNEL_HEADER_FILE_LIST); do \
		if( ! test -e "$(strip $(KERNEL_HEADER_FILE_PATH))/$$file"); then \
			echo "Kernel header file-> $$file is not found"; \
		fi; \
	done;
	@echo -e "\tQuerying system package files:"

ifeq ("$(wildcard $(PATH_TO_FILE)/libgcc_s.so.1)","")
        @echo "gcc package is not present"
else
	@echo "gcc package is present"
endif
ifeq ("$(wildcard $(PATH_TO_FILE)/libc.so.6)","")
        @echo "glibc package is not present"
else
	@echo "glibc package is present"
endif
ifeq ("$(wildcard $(PATH_TO_FILE)/libcrypto.so*)","")
        @echo "openssl package is not present"
else
	@echo "openssl package is present"
endif
ifeq ("$(wildcard $(PATH_TO_FILE)/libz.so.1)","")
        @echo "zlib package is not present"
else
	@echo "zlib package is present"
endif
