package boring

import "crypto/cipher"

const Enabled = false

func Unreachable() {}

func NewGCMTLS(cipher.Block) (cipher.AEAD, error) { panic("boringcrypto: not available") }
