GO_BIN_PATH = bin
GO_SRC_PATH = src
C_BUILD_PATH = build

NF = $(GO_NF) $(C_NF)
GO_NF = amf ausf nrf nssf pcf smf udm udr n3iwf
C_NF = upf

NF_GO_FILES = $(shell find $(GO_SRC_PATH)/$(%) -name "*.go" ! -name "*_test.go")

.PHONY: $(NF) clean

all: $(NF)

$(GO_NF): % : $(GO_BIN_PATH)/%

$(GO_BIN_PATH)/%: %.go $(NF_GO_FILES)
	@echo "Start building $(@F)...."
	# $(@F): The file-within-directory part of the file name of the target.
	go build -o $@ $<

vpath %.go $(addprefix $(GO_SRC_PATH)/, $(GO_NF))

$(C_NF): % :
	@echo "Start building $@...."
	cd $(GO_SRC_PATH)/$@ && \
	rm -rf $(C_BUILD_PATH) && \
	mkdir -p $(C_BUILD_PATH) && \
	cd ./$(C_BUILD_PATH) && \
	cmake .. && \
	make -j$(nproc)

clean:
	rm -rf $(addprefix $(GO_BIN_PATH)/, $(GO_NF))
	rm -rf $(addprefix $(GO_SRC_PATH)/, $(addsuffix /$(C_BUILD_PATH), $(C_NF)))

