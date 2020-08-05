package test

import (
	"encoding/hex"
	"free5gc/lib/UeauCommon"
	"free5gc/lib/milenage"
	"free5gc/lib/nas/security"
	"free5gc/lib/openapi/models"
	"regexp"
)

type RanUeContext struct {
	Supi               string
	RanUeNgapId        int64
	AmfUeNgapId        int64
	ULCount            security.Count
	DLCount            security.Count
	CipheringAlg       uint8
	IntegrityAlg       uint8
	KnasEnc            [16]uint8
	KnasInt            [16]uint8
	Kamf               []uint8
	AuthenticationSubs models.AuthenticationSubscription
}

func NewRanUeContext(supi string, ranUeNgapId int64, cipheringAlg, integrityAlg uint8) *RanUeContext {
	ue := RanUeContext{}
	ue.RanUeNgapId = ranUeNgapId
	ue.Supi = supi
	ue.CipheringAlg = cipheringAlg
	ue.IntegrityAlg = integrityAlg
	return &ue
}

func (ue *RanUeContext) DeriveRESstarAndSetKey(authSubs models.AuthenticationSubscription, rand []byte, snNmae string) []byte {

	sqn, _ := hex.DecodeString(authSubs.SequenceNumber)

	amf, _ := hex.DecodeString(authSubs.AuthenticationManagementField)

	// Run milenage
	macA, macS := make([]byte, 8), make([]byte, 8)
	ck, ik := make([]byte, 16), make([]byte, 16)
	res := make([]byte, 8)
	ak, akStar := make([]byte, 6), make([]byte, 6)

	opc := make([]byte, 16)
	k, _ := hex.DecodeString(authSubs.PermanentKey.PermanentKeyValue)

	if authSubs.Opc.OpcValue == "" {
		opStr := authSubs.Milenage.Op.OpValue
		op, err := hex.DecodeString(opStr)
		if err != nil {

		}

		milenage.GenerateOPC(k, op, opc)
	} else {
		opc, _ = hex.DecodeString(authSubs.Opc.OpcValue)
	}

	// Generate MAC_A, MAC_S
	milenage.F1_Test(opc, k, rand, sqn, amf, macA, macS)

	// Generate RES, CK, IK, AK, AKstar
	milenage.F2345_Test(opc, k, rand, res, ck, ik, ak, akStar)

	// derive RES*
	key := append(ck, ik...)
	FC := UeauCommon.FC_FOR_RES_STAR_XRES_STAR_DERIVATION
	P0 := []byte(snNmae)
	P1 := rand
	P2 := res

	ue.DerivateKamf(key, snNmae, sqn, ak)
	ue.DerivateAlgKey()
	kdfVal_for_resStar := UeauCommon.GetKDFValue(key, FC, P0, UeauCommon.KDFLen(P0), P1, UeauCommon.KDFLen(P1), P2, UeauCommon.KDFLen(P2))
	return kdfVal_for_resStar[len(kdfVal_for_resStar)/2:]

}

func (ue *RanUeContext) DerivateKamf(key []byte, snName string, SQN, AK []byte) {

	FC := UeauCommon.FC_FOR_KAUSF_DERIVATION
	P0 := []byte(snName)
	SQNxorAK := make([]byte, 6)
	for i := 0; i < len(SQN); i++ {
		SQNxorAK[i] = SQN[i] ^ AK[i]
	}
	P1 := SQNxorAK
	Kausf := UeauCommon.GetKDFValue(key, FC, P0, UeauCommon.KDFLen(P0), P1, UeauCommon.KDFLen(P1))
	P0 = []byte(snName)
	Kseaf := UeauCommon.GetKDFValue(Kausf, UeauCommon.FC_FOR_KSEAF_DERIVATION, P0, UeauCommon.KDFLen(P0))

	supiRegexp, _ := regexp.Compile("(?:imsi|supi)-([0-9]{5,15})")
	groups := supiRegexp.FindStringSubmatch(ue.Supi)

	P0 = []byte(groups[1])
	L0 := UeauCommon.KDFLen(P0)
	P1 = []byte{0x00, 0x00}
	L1 := UeauCommon.KDFLen(P1)

	ue.Kamf = UeauCommon.GetKDFValue(Kseaf, UeauCommon.FC_FOR_KAMF_DERIVATION, P0, L0, P1, L1)
}

// Algorithm key Derivation function defined in TS 33.501 Annex A.9
func (ue *RanUeContext) DerivateAlgKey() {
	// Security Key
	P0 := []byte{security.NNASEncAlg}
	L0 := UeauCommon.KDFLen(P0)
	P1 := []byte{ue.CipheringAlg}
	L1 := UeauCommon.KDFLen(P1)

	kenc := UeauCommon.GetKDFValue(ue.Kamf, UeauCommon.FC_FOR_ALGORITHM_KEY_DERIVATION, P0, L0, P1, L1)
	copy(ue.KnasEnc[:], kenc[16:32])

	// Integrity Key
	P0 = []byte{security.NNASIntAlg}
	L0 = UeauCommon.KDFLen(P0)
	P1 = []byte{ue.IntegrityAlg}
	L1 = UeauCommon.KDFLen(P1)

	kint := UeauCommon.GetKDFValue(ue.Kamf, UeauCommon.FC_FOR_ALGORITHM_KEY_DERIVATION, P0, L0, P1, L1)
	copy(ue.KnasInt[:], kint[16:32])
}
