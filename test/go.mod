module test

go 1.14

require (
	bitbucket.org/free5gc-team/amf v0.0.0
	bitbucket.org/free5gc-team/aper v0.0.0-20220401145518-cfd1a7865d35
	bitbucket.org/free5gc-team/ausf v0.0.0
	bitbucket.org/free5gc-team/n3iwf v0.0.0
	bitbucket.org/free5gc-team/nas v0.0.0-20220623012519-3b41da8e7310
	bitbucket.org/free5gc-team/ngap v0.0.0-20220623012559-b93c014cf164
	bitbucket.org/free5gc-team/nrf v0.0.0
	bitbucket.org/free5gc-team/nssf v0.0.0
	bitbucket.org/free5gc-team/openapi v0.0.0-20220622044855-5d6e4b933d1f
	bitbucket.org/free5gc-team/pcf v0.0.0
	bitbucket.org/free5gc-team/smf v0.0.0
	bitbucket.org/free5gc-team/udm v0.0.0
	bitbucket.org/free5gc-team/udr v0.0.0
	bitbucket.org/free5gc-team/util v0.0.0-20220501150925-a07647243fa5
	git.cs.nctu.edu.tw/calee/sctp v1.1.0
	github.com/antihax/optional v1.0.0
	github.com/calee0219/fatal v0.0.1
	github.com/davecgh/go-spew v1.1.1
	github.com/gin-gonic/gin v1.7.3
	github.com/go-ping/ping v0.0.0-20210506233800-ff8be3320020
	github.com/google/uuid v1.3.0
	github.com/mohae/deepcopy v0.0.0-20170929034955-c48cc78d4826
	github.com/stretchr/testify v1.7.0
	github.com/urfave/cli v1.22.5
	github.com/vishvananda/netlink v1.1.0
	go.mongodb.org/mongo-driver v1.8.4
	golang.org/x/net v0.0.0-20210813160813-60bc85c4be6d
	golang.org/x/sys v0.0.0-20210823070655-63515b42dcdf
	gopkg.in/yaml.v2 v2.4.0
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
