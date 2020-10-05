module test

go 1.14

require (
	bitbucket.org/free5gc-team/CommonConsumerTestData v0.0.0-20200925083925-d0880a9fc38c
	bitbucket.org/free5gc-team/MongoDBLibrary v0.0.0-20200915034734-df7bd383fceb
	bitbucket.org/free5gc-team/UeauCommon v0.0.0-20200915045754-fc6808262820
	bitbucket.org/free5gc-team/amf v0.0.0-20200925125456-aecb65504068
	bitbucket.org/free5gc-team/aper v0.0.0-20200915033117-0dcacc1cf3c7
	bitbucket.org/free5gc-team/ausf v0.0.0-20200925091525-f7e15f8b37c0
	bitbucket.org/free5gc-team/http2_util v0.0.0-20200915033753-44c1ee32f9a4
	bitbucket.org/free5gc-team/milenage v0.0.0-20200915034446-e87f555990e5
	bitbucket.org/free5gc-team/n3iwf v0.0.0-20200925114718-7907d9fd6d82
	bitbucket.org/free5gc-team/nas v0.0.0-20200916194209-0698dd234d50
	bitbucket.org/free5gc-team/ngap v0.0.0-20200925072202-7227dc6531bc
	bitbucket.org/free5gc-team/nrf v0.0.0-20200925091603-b57652724aec
	bitbucket.org/free5gc-team/nssf v0.0.0-20200925092222-8e2fd96f1025
	bitbucket.org/free5gc-team/openapi v0.0.0-20200915035203-9fc3f0e748b4
	bitbucket.org/free5gc-team/path_util v0.0.0-20200925075253-6a41479bd567
	bitbucket.org/free5gc-team/pcf v0.0.0-20200925093616-783d5e211861
	bitbucket.org/free5gc-team/smf v0.0.0-20200925093620-d2fa6c49ce1b
	bitbucket.org/free5gc-team/udm v0.0.0-20200925093627-3bac2cb07a6f
	bitbucket.org/free5gc-team/udr v0.0.0-20200925142301-6344b4c321b7
	github.com/calee0219/fatal v0.0.1
	github.com/gin-gonic/gin v1.6.3
	github.com/go-ping/ping v0.0.0-20200918120429-e8ae07c3cec8
	github.com/ishidawataru/sctp v0.0.0-20191218070446-00ab2ac2db07
	github.com/mohae/deepcopy v0.0.0-20170929034955-c48cc78d4826
	github.com/stretchr/testify v1.6.1
	github.com/urfave/cli v1.22.4
	github.com/vishvananda/netlink v1.1.0
	go.mongodb.org/mongo-driver v1.4.1
	golang.org/x/net v0.0.0-20200927032502-5d4f70055728
	golang.org/x/sys v0.0.0-20200926100807-9d91bd62050c
	gopkg.in/yaml.v2 v2.3.0
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
