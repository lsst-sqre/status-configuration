UNAME := $(shell uname -s | tr A-Z a-z)
BIN_DIR=./bin
TF_VERSION=0.7.11
ZIP_FILE=terraform_$(TF_VERSION)_$(UNAME)_amd64.zip

all: $(BIN_DIR) id_rsa id_rsa.pub

$(BIN_DIR):
	mkdir $@
	cd $@; wget -nc https://releases.hashicorp.com/terraform/$(TF_VERSION)/$(ZIP_FILE)
	cd $@; unzip $(ZIP_FILE)

id_rsa id_rsa.pub:
	ssh-keygen -t rsa -b 2048 -C nagios -N "" -f id_rsa

tf := $(wildcard *.tf)

fmt:
	$(foreach src, $(tf), $(BIN_DIR)/terraform fmt $(src);)

clean:
	-rm -rf bin id_rsa id_rsa.pub
