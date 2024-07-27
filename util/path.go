package util

import (
	"net/url"

	"bitbucket.org/free5gc-team/openapi/Npcf_PolicyAuthorization"
	"bitbucket.org/free5gc-team/openapi/Ntsnaf_BridgeInfoManagement"
)

func GetNpcfPolicyAuthorizationClient() *Npcf_PolicyAuthorization.APIClient {
	configuration := Npcf_PolicyAuthorization.NewConfiguration()
	configuration.SetBasePath("http://127.0.0.7:8000")
	client := Npcf_PolicyAuthorization.NewAPIClient(configuration)
	return client
}

// TODO: url??
func GetNtsnafBridgeInforManagementClient() *Ntsnaf_BridgeInfoManagement.APIClient {
	configuration := Ntsnaf_BridgeInfoManagement.NewConfiguration()
	configuration.SetBasePath("http://127.0.0.55:8000")
	client := Ntsnaf_BridgeInfoManagement.NewAPIClient(configuration)
	return client
}

func Split_appSessionId(Loc *url.URL) string {
	var temp string
	var slash int
	temp = Loc.String()
	for i := 0; i <= len(temp); i++ {
		if temp[i] == '/' {
			slash++
		}
		if slash == 6 {
			slash = i + 1
			break
		}
	}
	return temp[slash:]
}
