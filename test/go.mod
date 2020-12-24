module test

go 1.14

require (
	bitbucket.org/free5gc-team/CommonConsumerTestData v0.0.0-20201202123716-f12eceaeb099
	bitbucket.org/free5gc-team/MongoDBLibrary v0.0.0-20201213113619-17bf1c692838
	bitbucket.org/free5gc-team/UeauCommon v0.0.0-20201211040450-fc83e159de75
	bitbucket.org/free5gc-team/amf v0.0.0
	bitbucket.org/free5gc-team/aper v0.0.0-20201213000141-4a816f02c4e5
	bitbucket.org/free5gc-team/ausf v0.0.0
	bitbucket.org/free5gc-team/http2_util v0.0.0-20201212235925-bd3a307d110a
	bitbucket.org/free5gc-team/milenage v0.0.0-20201211040256-1f9245345719
	bitbucket.org/free5gc-team/n3iwf v0.0.0
	bitbucket.org/free5gc-team/nas v0.0.0-20201216145657-8bfbf6fcfac7
	bitbucket.org/free5gc-team/ngap v0.0.0-20201213001141-924cc2f2b303
	bitbucket.org/free5gc-team/nrf v0.0.0
	bitbucket.org/free5gc-team/nssf v0.0.0
	bitbucket.org/free5gc-team/openapi v0.0.0-20201213000822-44068345955a
	bitbucket.org/free5gc-team/path_util v0.0.0-20201214054434-5d8f807c9de3
	bitbucket.org/free5gc-team/pcf v0.0.0
	bitbucket.org/free5gc-team/smf v0.0.0
	bitbucket.org/free5gc-team/udm v0.0.0
	bitbucket.org/free5gc-team/udr v0.0.0
	git.cs.nctu.edu.tw/calee/sctp v1.1.0
	github.com/Djarvur/go-err113 v0.1.0 // indirect
	github.com/calee0219/fatal v0.0.1
	github.com/daixiang0/gci v0.2.7 // indirect
	github.com/gin-gonic/gin v1.6.3
	github.com/go-ping/ping v0.0.0-20200918120429-e8ae07c3cec8
	github.com/golangci/golangci-lint v1.33.0
	github.com/golangci/misspell v0.3.5 // indirect
	github.com/golangci/revgrep v0.0.0-20180812185044-276a5c0a1039 // indirect
	github.com/google/go-cmp v0.5.4 // indirect
	github.com/gostaticanalysis/analysisutil v0.6.1 // indirect
	github.com/jirfag/go-printf-func-name v0.0.0-20200119135958-7558a9eaa5af // indirect
	github.com/magiconair/properties v1.8.4 // indirect
	github.com/matoous/godox v0.0.0-20200801072554-4fb83dc2941e // indirect
	github.com/mohae/deepcopy v0.0.0-20170929034955-c48cc78d4826
	github.com/pelletier/go-toml v1.8.1 // indirect
	github.com/polyfloyd/go-errorlint v0.0.0-20201127212506-19bd8db6546f // indirect
	github.com/quasilyte/go-ruleguard v0.2.1 // indirect
	github.com/quasilyte/regex/syntax v0.0.0-20200805063351-8f842688393c // indirect
	github.com/spf13/afero v1.5.1 // indirect
	github.com/spf13/cast v1.3.1 // indirect
	github.com/spf13/jwalterweatherman v1.1.0 // indirect
	github.com/stretchr/objx v0.3.0 // indirect
	github.com/stretchr/testify v1.6.1
	github.com/tdakkota/asciicheck v0.0.0-20200416200610-e657995f937b // indirect
	github.com/tetafro/godot v1.3.2 // indirect
	github.com/timakin/bodyclose v0.0.0-20200424151742-cb6215831a94 // indirect
	github.com/tomarrell/wrapcheck v0.0.0-20201130113247-1683564d9756 // indirect
	github.com/urfave/cli v1.22.5
	github.com/vishvananda/netlink v1.1.0
	go.mongodb.org/mongo-driver v1.4.4
	golang.org/x/mod v0.4.0 // indirect
	golang.org/x/net v0.0.0-20201209123823-ac852fbbde11
	golang.org/x/sys v0.0.0-20201214210602-f9fddec55a1e
	golang.org/x/tools v0.0.0-20201211185031-d93e913c1a58 // indirect
	gopkg.in/ini.v1 v1.62.0 // indirect
	gopkg.in/yaml.v2 v2.4.0
	gopkg.in/yaml.v3 v3.0.0-20200615113413-eeeca48fe776 // indirect
	mvdan.cc/gofumpt v0.0.0-20201129102820-5c11c50e9475 // indirect
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
