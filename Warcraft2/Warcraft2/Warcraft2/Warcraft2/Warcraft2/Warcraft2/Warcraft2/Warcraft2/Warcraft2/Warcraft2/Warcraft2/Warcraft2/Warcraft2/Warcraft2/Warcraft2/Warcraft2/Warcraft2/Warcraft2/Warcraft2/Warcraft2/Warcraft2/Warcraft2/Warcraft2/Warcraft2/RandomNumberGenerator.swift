class RandomNumberGenerator {
    private var randomSeedHigh: UInt32 = 0x0123_4567
    private var randomSeedLow: UInt32 = 0x89ab_cdef

    init() {
        // do nothing
    }

    func seed(seed: UInt64) {
        seed2(high: UInt32(seed >> 32), low: UInt32(seed))
    }

    func seed2(high: UInt32, low: UInt32) {
        if high != low && low != 0 && high != 0 {
            randomSeedHigh = high
            randomSeedLow = low
        }
    }

    func random() -> UInt32 {
        randomSeedHigh = 36969 * (randomSeedHigh & 65535) + (randomSeedHigh >> 16)
        randomSeedLow = 18000 * (randomSeedLow & 65535) + (randomSeedLow >> 16)
        return (randomSeedHigh << 16) + randomSeedLow
    }
}
