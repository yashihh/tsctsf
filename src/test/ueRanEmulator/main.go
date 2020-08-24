package main

import (
	"fmt"
	"free5gc/lib/CommonConsumerTestData/UDM/TestGenAuthData"
	"free5gc/lib/MongoDBLibrary"
	"free5gc/lib/nas"
	"free5gc/lib/nas/nasMessage"
	"free5gc/lib/nas/nasTestpacket"
	"free5gc/lib/nas/nasType"
	"free5gc/lib/nas/security"
	"free5gc/lib/ngap"
	"free5gc/lib/openapi/models"
	"free5gc/src/test"
	"log"
	"net"
	"os"
	"time"

	"github.com/urfave/cli"
)

const n2AmfIP string = "127.0.0.1"
const n2RanIP string = "127.0.0.1"
const n2AmfPort int = 38412
const n2RanPort int = 9487
const n3RanIP string = "10.200.200.1"
const n3UpfIP string = "10.200.200.102"
const n3RanPort int = 2152
const n3UpfPort int = 2152
const ueIP string = "60.60.0.1"
const cnIP string = "60.60.0.101"
const uePort int = 30000
const cnPort int = 30000
const supi string = "imsi-2089300007487"
const mcc string = "208"
const mnc string = "93"
const ngapID int64 = 1
const teID int = 1
const snssaiSST int32 = 1
const snssaiSD string = "010203"

func ueRanEmulator() error {
	var n int
	var sendMsg []byte
	var recvMsg = make([]byte, 2048)

	// RAN connect to AMF
	conn, err := test.ConntectToAmf(n2AmfIP, n2RanIP, n2AmfPort, n2RanPort)
	if err != nil {
		err = fmt.Errorf("ConntectToAmf: %v", err)
		return err
	}
	defer conn.Close()
	fmt.Printf("[UERANEM] Conntect to AMF successfully\n")

	// RAN connect to UPF
	upfConn, err := test.ConnectToUpf(n3RanIP, n3UpfIP, n3RanPort, n3UpfPort)
	if err != nil {
		err = fmt.Errorf("ConnectToUpf: %v", err)
		return err
	}
	defer upfConn.Close()
	fmt.Printf("[UERANEM] Conntect to UPF successfully\n")

	// send NGSetupRequest Msg
	sendMsg, err = test.GetNGSetupRequest([]byte("\x00\x01\x02"), 24, "free5gc")
	if err != nil {
		err = fmt.Errorf("GetNGSetupRequest: %v", err)
		return err
	}
	_, err = conn.Write(sendMsg)
	if err != nil {
		return err
	}

	// receive NGSetupResponse Msg
	n, err = conn.Read(recvMsg)
	if err != nil {
		return err
	}
	_, err = ngap.Decoder(recvMsg[:n])
	if err != nil {
		return err
	}
	fmt.Printf("[UERANEM] NGSetup successfully\n")

	// New UE
	// ue := test.NewRanUeContext("imsi-2089300007487", 1, security.AlgCiphering128NEA2, security.AlgIntegrity128NIA2)
	ue := test.NewRanUeContext(supi, ngapID, security.AlgCiphering128NEA0, security.AlgIntegrity128NIA2)
	ue.AmfUeNgapId = ngapID
	ue.AuthenticationSubs = test.GetAuthSubscription(TestGenAuthData.MilenageTestSet19.K,
		TestGenAuthData.MilenageTestSet19.OPC,
		TestGenAuthData.MilenageTestSet19.OP)
	// insert UE data to MongoDB

	servingPlmnID := mcc + mnc
	test.InsertAuthSubscriptionToMongoDB(ue.Supi, ue.AuthenticationSubs)
	getData := test.GetAuthSubscriptionFromMongoDB(ue.Supi)
	if getData == nil {
		err = fmt.Errorf("GetAuthSubscriptionFromMongoDB failed")
		return err
	}
	{
		amData := test.GetAccessAndMobilitySubscriptionData()
		test.InsertAccessAndMobilitySubscriptionDataToMongoDB(ue.Supi, amData, servingPlmnID)
		getData := test.GetAccessAndMobilitySubscriptionDataFromMongoDB(ue.Supi, servingPlmnID)
		if getData == nil {
			err = fmt.Errorf("GetAccessAndMobilitySubscriptionDataFromMongoDB failed")
			return err
		}
	}
	{
		smfSelData := test.GetSmfSelectionSubscriptionData()
		test.InsertSmfSelectionSubscriptionDataToMongoDB(ue.Supi, smfSelData, servingPlmnID)
		getData := test.GetSmfSelectionSubscriptionDataFromMongoDB(ue.Supi, servingPlmnID)
		if getData == nil {
			err = fmt.Errorf("GetSmfSelectionSubscriptionDataFromMongoDB failed")
			return err
		}
	}
	{
		smSelData := test.GetSessionManagementSubscriptionData()
		test.InsertSessionManagementSubscriptionDataToMongoDB(ue.Supi, servingPlmnID, smSelData)
		getData := test.GetSessionManagementDataFromMongoDB(ue.Supi, servingPlmnID)
		if getData == nil {
			err = fmt.Errorf("GetSessionManagementDataFromMongoDB failed")
			return err
		}
	}
	{
		amPolicyData := test.GetAmPolicyData()
		test.InsertAmPolicyDataToMongoDB(ue.Supi, amPolicyData)
		getData := test.GetAmPolicyDataFromMongoDB(ue.Supi)
		if getData == nil {
			err = fmt.Errorf("GetAmPolicyDataFromMongoDB failed")
			return err
		}
	}
	{
		smPolicyData := test.GetSmPolicyData()
		test.InsertSmPolicyDataToMongoDB(ue.Supi, smPolicyData)
		getData := test.GetSmPolicyDataFromMongoDB(ue.Supi)
		if getData == nil {
			err = fmt.Errorf("GetSmPolicyDataFromMongoDB failed")
			return err
		}
	}
	fmt.Printf("[UERANEM] Insert data to MongoDB successfully\n")

	// send InitialUeMessage(Registration Request)(imsi-2089300007487)
	mobileIdentity5GS := nasType.MobileIdentity5GS{
		Len:    12, // suci
		Buffer: []uint8{0x01, 0x02, 0xf8, 0x39, 0xf0, 0xff, 0x00, 0x00, 0x00, 0x00, 0x47, 0x78},
	}

	ueSecurityCapability := ue.GetUESecurityCapability()
	registrationRequest := nasTestpacket.GetRegistrationRequest(nasMessage.RegistrationType5GSInitialRegistration,
		mobileIdentity5GS, nil, ueSecurityCapability, nil, nil, nil)
	sendMsg, err = test.GetInitialUEMessage(ue.RanUeNgapId, registrationRequest, "")
	if err != nil {
		return err
	}
	_, err = conn.Write(sendMsg)
	if err != nil {
		return err
	}

	// receive NAS Authentication Request Msg
	n, err = conn.Read(recvMsg)
	if err != nil {
		return err
	}
	ngapMsg, err := ngap.Decoder(recvMsg[:n])
	if err != nil {
		return err
	}

	// Calculate for RES*
	nasPdu := test.GetNasPdu(ngapMsg.InitiatingMessage.Value.DownlinkNASTransport)
	if nasPdu == nil {
		err = fmt.Errorf("GetNasPdu failed")
		return err
	}
	rand := nasPdu.AuthenticationRequest.GetRANDValue()

	var mncPad string
	if len(mnc) == 2 {
		mncPad = "0" + mnc
	} else {
		mncPad = mnc
	}
	snName := "5G:mnc" + mncPad + ".mcc" + mcc + ".3gppnetwork.org"

	resStat := ue.DeriveRESstarAndSetKey(ue.AuthenticationSubs, rand[:], snName)

	// send NAS Authentication Response
	pdu := nasTestpacket.GetAuthenticationResponse(resStat, "")
	sendMsg, err = test.GetUplinkNASTransport(ue.AmfUeNgapId, ue.RanUeNgapId, pdu)
	if err != nil {
		return err
	}
	_, err = conn.Write(sendMsg)
	if err != nil {
		return err
	}

	// receive NAS Security Mode Command Msg
	n, err = conn.Read(recvMsg)
	if err != nil {
		return err
	}
	_, err = ngap.Decoder(recvMsg[:n])
	if err != nil {
		return err
	}

	// send NAS Security Mode Complete Msg
	registrationRequestWith5GMM := nasTestpacket.GetRegistrationRequest(nasMessage.RegistrationType5GSInitialRegistration,
		mobileIdentity5GS, nil, ueSecurityCapability, nil, nil, nil)
	pdu = nasTestpacket.GetSecurityModeComplete(registrationRequestWith5GMM)
	pdu, err = test.EncodeNasPduWithSecurity(ue, pdu, nas.SecurityHeaderTypeIntegrityProtectedAndCipheredWithNew5gNasSecurityContext, true, true)
	if err != nil {
		return err
	}
	sendMsg, err = test.GetUplinkNASTransport(ue.AmfUeNgapId, ue.RanUeNgapId, pdu)
	if err != nil {
		return err
	}
	_, err = conn.Write(sendMsg)
	if err != nil {
		return err
	}

	// receive ngap Initial Context Setup Request Msg
	n, err = conn.Read(recvMsg)
	if err != nil {
		return err
	}
	_, err = ngap.Decoder(recvMsg[:n])
	if err != nil {
		return err
	}

	// send ngap Initial Context Setup Response Msg
	sendMsg, err = test.GetInitialContextSetupResponse(ue.AmfUeNgapId, ue.RanUeNgapId)
	if err != nil {
		return err
	}
	_, err = conn.Write(sendMsg)
	if err != nil {
		return err
	}

	// send NAS Registration Complete Msg
	pdu = nasTestpacket.GetRegistrationComplete(nil)
	pdu, err = test.EncodeNasPduWithSecurity(ue, pdu, nas.SecurityHeaderTypeIntegrityProtectedAndCiphered, true, false)
	if err != nil {
		return err
	}
	sendMsg, err = test.GetUplinkNASTransport(ue.AmfUeNgapId, ue.RanUeNgapId, pdu)
	if err != nil {
		return err
	}
	_, err = conn.Write(sendMsg)
	if err != nil {
		return err
	}
	fmt.Printf("[UERANEM] Initial-Registration completed\n")

	time.Sleep(100 * time.Millisecond)
	// send GetPduSessionEstablishmentRequest Msg

	sNssai := models.Snssai{
		Sst: snssaiSST,
		Sd:  snssaiSD,
	}
	pdu = nasTestpacket.GetUlNasTransport_PduSessionEstablishmentRequest(10, nasMessage.ULNASTransportRequestTypeInitialRequest, "internet", &sNssai)
	pdu, err = test.EncodeNasPduWithSecurity(ue, pdu, nas.SecurityHeaderTypeIntegrityProtectedAndCiphered, true, false)
	if err != nil {
		return err
	}
	sendMsg, err = test.GetUplinkNASTransport(ue.AmfUeNgapId, ue.RanUeNgapId, pdu)
	if err != nil {
		return err
	}
	_, err = conn.Write(sendMsg)
	if err != nil {
		return err
	}

	// receive 12. NGAP-PDU Session Resource Setup Request(DL nas transport((NAS msg-PDU session setup Accept)))
	n, err = conn.Read(recvMsg)
	if err != nil {
		return err
	}
	_, err = ngap.Decoder(recvMsg[:n])
	if err != nil {
		return err
	}

	// send 14. NGAP-PDU Session Resource Setup Response
	sendMsg, err = test.GetPDUSessionResourceSetupResponse(ue.AmfUeNgapId, ue.RanUeNgapId, n3RanIP)
	if err != nil {
		return err
	}
	_, err = conn.Write(sendMsg)
	if err != nil {
		return err
	}
	fmt.Printf("[UERANEM] PDU session establishment completed\n")

	// wait 1s
	time.Sleep(1 * time.Second)

	// infinite loop to send UDP with GTP
	for {
		fmt.Printf("[UERANEM] Send GTP packet to UPF\n")
		if err = sendGTP(upfConn, "helloworld"); err != nil {
			fmt.Printf("[UERANEM] Fail to send GTP packet!\n")
			break
		}
		time.Sleep(1 * time.Second)
	}

	// delete test data
	test.DelAuthSubscriptionToMongoDB(ue.Supi)
	test.DelAccessAndMobilitySubscriptionDataFromMongoDB(ue.Supi, servingPlmnID)
	test.DelSmfSelectionSubscriptionDataFromMongoDB(ue.Supi, servingPlmnID)
	return err
}

func sendGTP(conn *net.UDPConn, msg string) error {
	pkt, err := test.BuildRawUdpIp(ueIP, cnIP, uePort, cnPort, []byte(msg))
	if err != nil {
		return err
	}

	// build GTPv1 header
	gtpHdr, err := test.BuildGTPv1Header(false, 0, false, 0, false, 0, uint16(len(pkt)), uint32(teID))
	if err != nil {
		return err
	}

	tt := append(gtpHdr, pkt...)

	// send to socket
	_, err = conn.Write(tt)
	return err
}

func main() {
	app := cli.NewApp()
	app.Name = "UE RAN Emulator"
	app.Usage = "./ueranem"
	app.Action = action
	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}

func action(c *cli.Context) error {
	// Connect to MongoDB
	MongoDBLibrary.SetMongoDB("free5gc", "mongodb://127.0.0.1:27017")

	err := ueRanEmulator()
	return err
}
