module test

go 1.14

require (
	bitbucket.org/free5gc-team/CommonConsumerTestData v0.0.0-20210316171326-381e40198a89
	bitbucket.org/free5gc-team/MongoDBLibrary v0.0.0-20210310054103-f65f6e610c4f
	bitbucket.org/free5gc-team/UeauCommon v0.0.0-20201211040450-fc83e159de75
	bitbucket.org/free5gc-team/amf v0.0.0
	bitbucket.org/free5gc-team/aper v0.0.0-20210414074706-491f6ea71741
	bitbucket.org/free5gc-team/ausf v0.0.0
	bitbucket.org/free5gc-team/http2_util v0.0.0-20201212235925-bd3a307d110a
	bitbucket.org/free5gc-team/logger_util v0.0.0-20210414054242-2101cfc15ebb
	bitbucket.org/free5gc-team/milenage v0.0.0-20201211040256-1f9245345719
	bitbucket.org/free5gc-team/n3iwf v0.0.0
	bitbucket.org/free5gc-team/nas v0.0.0-20210414080401-8106268fadd6
	bitbucket.org/free5gc-team/ngap v0.0.0-20210414080844-063a8973125d
	bitbucket.org/free5gc-team/nrf v0.0.0
	bitbucket.org/free5gc-team/nssf v0.0.0
	bitbucket.org/free5gc-team/openapi v0.0.0-20210416060210-2f59856943b2
	bitbucket.org/free5gc-team/pcf v0.0.0
	bitbucket.org/free5gc-team/smf v0.0.0
	bitbucket.org/free5gc-team/udm v0.0.0
	bitbucket.org/free5gc-team/udr v0.0.0
	git.cs.nctu.edu.tw/calee/sctp v1.1.0
	github.com/Djarvur/go-err113 v0.1.0 // indirect
	github.com/aws/aws-sdk-go v1.36.24 // indirect
	github.com/calee0219/fatal v0.0.1
	github.com/gin-gonic/gin v1.6.3
	github.com/go-ping/ping v0.0.0-20200918120429-e8ae07c3cec8
	github.com/golangci/golangci-lint v1.35.2
	github.com/golangci/misspell v0.3.5 // indirect
	github.com/golangci/revgrep v0.0.0-20180812185044-276a5c0a1039 // indirect
	github.com/gostaticanalysis/analysisutil v0.6.1 // indirect
	github.com/jirfag/go-printf-func-name v0.0.0-20200119135958-7558a9eaa5af // indirect
	github.com/klauspost/compress v1.11.6 // indirect
	github.com/magiconair/properties v1.8.4 // indirect
	github.com/matoous/godox v0.0.0-20200801072554-4fb83dc2941e // indirect
	github.com/mohae/deepcopy v0.0.0-20170929034955-c48cc78d4826
	github.com/nbutton23/zxcvbn-go v0.0.0-20201221231540-e56b841a3c88 // indirect
	github.com/pelletier/go-toml v1.8.1 // indirect
	github.com/quasilyte/go-ruleguard v0.2.1 // indirect
	github.com/quasilyte/regex/syntax v0.0.0-20200805063351-8f842688393c // indirect
	github.com/spf13/afero v1.5.1 // indirect
	github.com/spf13/cast v1.3.1 // indirect
	github.com/spf13/jwalterweatherman v1.1.0 // indirect
	github.com/stretchr/objx v0.3.0 // indirect
	github.com/stretchr/testify v1.6.1
	github.com/tdakkota/asciicheck v0.0.0-20200416200610-e657995f937b // indirect
	github.com/timakin/bodyclose v0.0.0-20200424151742-cb6215831a94 // indirect
	github.com/tomarrell/wrapcheck v0.0.0-20201130113247-1683564d9756 // indirect
	github.com/ugorji/go v1.2.3 // indirect
	github.com/urfave/cli v1.22.5
	github.com/vishvananda/netlink v1.1.0
	go.mongodb.org/mongo-driver v1.4.4
	golang.org/x/crypto v0.0.0-20201221181555-eec23a3978ad // indirect
	golang.org/x/net v0.0.0-20210415231046-e915ea6b2b7d
	golang.org/x/sys v0.0.0-20210330210617-4fbd30eecc44
	golang.org/x/tools v0.0.0-20210111221946-d33bae441459 // indirect
	gopkg.in/ini.v1 v1.62.0 // indirect
	gopkg.in/yaml.v2 v2.4.0
	gopkg.in/yaml.v3 v3.0.0-20210107192922-496545a6307b // indirect
	honnef.co/go/tools v0.1.0 // indirect
	mvdan.cc/unparam v0.0.0-20210104141923-aac4ce9116a7 // indirect
)

replace (
	bitbucket.org/free5gc-team/amf => ../NFs/amf
	bitbucket.org/free5gc-team/ausf => ../NFs/ausf
	bitbucket.org/free5gc-team/n3iwf => ../NFs/n3iwf
	bitbucket.org/free5gc-team/nrf => ../NFs/nrf
	bitbucket.org/free5gc-team/nssf => ../NFs/nssf
	bitbucket.org/free5gc-team/pcf => ../NFs/pcf
	bitbucket.org/free5gc-team/smf => ../NFs/smf
	bitbucket.org/free5gc-team/udm => ../NFs/udm
	bitbucket.org/free5gc-team/udr => ../NFs/udr
)
