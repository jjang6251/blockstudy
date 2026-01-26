package fastcampus

import (
	"testing"

	"github.com/ethereum/go-ethereum/crypto"
	"github.com/stretchr/testify/require"
)

func TestPrivateKey(t *testing.T) {
	privateKey, err := crypto.GenerateKey()
	require.NoError(t, err)

	// Parameters of the secp256k1 curve which is used in Ethereum
	curveParams := privateKey.Params()
	t.Logf("P: %x\n", curveParams.P)
	t.Logf("N: %x\n", curveParams.N)
	t.Logf("B: %x\n", curveParams.B)
	t.Logf("Gx: %x\n", curveParams.Gx)
	t.Logf("Gy: %x\n", curveParams.Gy)
	t.Logf("BitSize: %v\n", curveParams.BitSize)
	t.Logf("Name: %v\n", curveParams.Name)

	// The private key is just a random number
	t.Logf("D: %x\n", privateKey.D)

	// The public key is a point on the curve calculated by (Gx, Gy) * D
	t.Logf("X: %x\n", privateKey.PublicKey.X)
	t.Logf("Y: %x\n", privateKey.PublicKey.Y)

	// Uncomprseed public key = 04 + X + Y
	t.Logf("Uncompressed Public Key: %x\n", crypto.FromECDSAPub(&privateKey.PublicKey))

	// Compressed public key = 02 or 03 + X
	t.Logf("Compressed Public Key: %x\n", crypto.CompressPubkey(&privateKey.PublicKey))

	// Sign a message
	message := []byte("Hello, world!")
	messageHash := crypto.Keccak256Hash(message)
	signature, err := crypto.Sign(messageHash[:], privateKey)
	require.NoError(t, err)
	t.Logf("Signature: %x\n", signature)

	// Verify the signature
	crypto.VerifySignature(crypto.FromECDSAPub(&privateKey.PublicKey), messageHash[:], signature)
}
