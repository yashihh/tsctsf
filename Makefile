NF_LIST = amf ausf nrf nssf pcf smf udm udr n3iwf

AMF = amf
AUSF = ausf
NRF = nrf
NSSF = nssf
PCF = pcf
SMF = smf
UDM = udm
UDR = udr
N3IWF = n3iwf
UPF = upf

all: $(NF_LIST) $(UPF)

bin/$(AMF): src/$(AMF)/$(AMF).go
	@echo "Start build $(AMF)...."
	go build -o bin/$(AMF) -x src/$(AMF)/$(AMF).go

bin/$(AUSF): src/$(AUSF)/$(AUSF).go
	@echo "Start build $(AUSF)...."
	go build -o bin/$(AUSF) -x src/$(AUSF)/$(AUSF).go

bin/$(NRF): src/$(NRF)/$(NRF).go
	@echo "Start build $(NRF)...."
	go build -o bin/$(NRF) -x src/$(NRF)/$(NRF).go

bin/$(NSSF): src/$(NSSF)/$(NSSF).go
	@echo "Start build $(NSSF)...."
	go build -o bin/$(NSSF) -x src/$(NSSF)/$(NSSF).go

bin/$(PCF): src/$(PCF)/$(PCF).go
	@echo "Start build $(PCF)...."
	go build -o bin/$(PCF) -x src/$(PCF)/$(PCF).go

bin/$(SMF): src/$(SMF)/$(SMF).go
	@echo "Start build $(SMF)...."
	go build -o bin/$(SMF) -x src/$(SMF)/$(SMF).go

bin/$(UDM): src/$(UDM)/$(UDM).go
	@echo "Start build $(UDM)...."
	go build -o bin/$(UDM) -x src/$(UDM)/$(UDM).go

bin/$(UDR):src/$(UDR)/$(UDR).go
	@echo "Start build $(UDR)...."
	go build -o bin/$(UDR) -x src/$(UDR)/$(UDR).go

bin/$(N3IWF): src/$(N3IWF)/$(N3IWF).go
	@echo "Start build $(N3IWF)...."
	go build -o bin/$(N3IWF) -x src/$(N3IWF)/$(N3IWF).go


.PHONY: amf ausf nrf nssf pcf smf udm udr n3iwf upf

amf: bin/$(AMF)

ausf: bin/$(AUSF)

nrf: bin/$(NRF)

nssf: bin/$(NSSF)

pcf: bin/$(PCF)

smf: bin/$(SMF)

udm: bin/$(UDM)

udr: bin/$(UDR)

n3iwf: bin/$(N3IWF)

upf:
	@echo "Start build $(UPF)...."
	cd src/$(UPF) && \
	rm -rf build && \
	mkdir -p build && \
	cd ./build && \
	cmake .. && \
	make -j$(nproc)

