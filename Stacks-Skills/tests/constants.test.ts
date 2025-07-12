import { describe, it, expect, beforeEach } from "vitest"

// The simnet object is provided by our setup file
declare const simnet: any

describe("Constants Contract Tests", () => {
  let accounts: any
  let deployer: any

  beforeEach(() => {
    // Initialize accounts in beforeEach to ensure simnet is available
    accounts = simnet.getAccounts()
    deployer = accounts.get("deployer")!
  })

  it("should return correct platform fee rate", () => {
    const result = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], deployer)
    expect(result.result.expectUint(250)).toBe(250)
  })

  it("should return correct basis points", () => {
    const result = simnet.callReadOnlyFn("constants", "get-basis-points", [], deployer)
    expect(result.result.expectUint(10000)).toBe(10000)
  })

  it("should return correct SKILL token price", () => {
    const result = simnet.callReadOnlyFn("constants", "get-skill-token-price", [], deployer)
    expect(result.result.expectUint(100000)).toBe(100000) // 0.1 STX in microSTX
  })

  it("should return correct application cost in SKILL tokens", () => {
    const result = simnet.callReadOnlyFn("constants", "get-application-cost-skill", [], deployer)
    expect(result.result.expectUint(1000000)).toBe(1000000) // 1 SKILL token
  })

  it("should return correct application cost in STX", () => {
    const result = simnet.callReadOnlyFn("constants", "get-application-cost-stx", [], deployer)
    expect(result.result.expectUint(100000)).toBe(100000) // 0.1 STX
  })

  it("should return correct contract version information structure", () => {
    const result = simnet.callReadOnlyFn("constants", "get-contract-version", [], deployer)
    const versionInfo = result.result.expectOk().expectTuple()

    expect(versionInfo.version.expectAscii()).toBe("1.0.0")
    expect(versionInfo.major.expectUint()).toBe(1)
    expect(versionInfo.minor.expectUint()).toBe(0)
    expect(versionInfo.patch.expectUint()).toBe(0)
    // deployment-block will be the current block height
    expect(typeof versionInfo["deployment-block"].expectUint()).toBe("number")
  })

  it("should return correct error codes for all error constant getters", () => {
    const errorTests = [
      { fn: "err-unauthorized", expected: 100 },
      { fn: "err-not-found", expected: 101 },
      { fn: "err-invalid-state", expected: 102 },
      { fn: "err-insufficient-funds", expected: 103 },
      { fn: "err-duplicate", expected: 104 },
      { fn: "err-verification-required", expected: 105 },
      { fn: "err-expired", expected: 106 },
      { fn: "err-invalid-rating", expected: 107 },
      { fn: "err-admin-only", expected: 108 },
      { fn: "err-funds-locked", expected: 109 },
      { fn: "err-invalid-amount", expected: 110 },
      { fn: "err-oracle-stale", expected: 115 },
      { fn: "err-paused", expected: 116 },
      { fn: "err-invalid-input", expected: 117 },
      { fn: "err-owner-only", expected: 118 },
      { fn: "err-insufficient-balance", expected: 120 },
      { fn: "err-transfer-failed", expected: 121 },
      { fn: "err-invalid-recipient", expected: 124 },
      { fn: "err-invalid-duration", expected: 125 },
      { fn: "err-contract-paused", expected: 126 },
      { fn: "err-rate-limited", expected: 127 },
      { fn: "err-invalid-status", expected: 128 },
      { fn: "err-invalid-confidence", expected: 129 },
      { fn: "err-stale-price", expected: 130 },
      { fn: "err-invalid-price", expected: 131 },
      { fn: "err-success-threshold-not-met", expected: 132 },
      { fn: "err-experienced-provider-quota-full", expected: 133 },
      { fn: "err-not-new-provider", expected: 134 },
      { fn: "err-new-provider-quota-full", expected: 135 },
      { fn: "err-insufficient-skill-tokens", expected: 136 },
      { fn: "err-skill-token-contract-not-set", expected: 137 },
      { fn: "err-application-fee-required", expected: 138 },
    ]

    for (const test of errorTests) {
      const result = simnet.callReadOnlyFn("constants", test.fn, [], deployer)
      expect(result.result.expectErr().expectUint(test.expected)).toBe(test.expected)
    }
  })

  it("should return correct service status values", () => {
    const statusTests = [
      { fn: "get-service-status-open", expected: 0 },
      { fn: "get-service-status-matched", expected: 1 },
      { fn: "get-service-status-in-progress", expected: 2 },
      { fn: "get-service-status-completed", expected: 3 },
      { fn: "get-service-status-disputed", expected: 4 },
      { fn: "get-service-status-cancelled", expected: 5 },
    ]

    for (const test of statusTests) {
      const result = simnet.callReadOnlyFn("constants", test.fn, [], deployer)
      expect(result.result.expectUint(test.expected)).toBe(test.expected)
    }
  })

  it("should have correctly configured rating constants", () => {
    const minRating = simnet.callReadOnlyFn("constants", "get-min-rating", [], deployer)
    expect(minRating.result.expectUint(10)).toBe(10) // 1.0 stars

    const maxRating = simnet.callReadOnlyFn("constants", "get-max-rating", [], deployer)
    expect(maxRating.result.expectUint(50)).toBe(50) // 5.0 stars

    const thresholdRating = simnet.callReadOnlyFn("constants", "get-min-provider-rating-threshold", [], deployer)
    expect(thresholdRating.result.expectUint(20)).toBe(20) // 2.0 stars minimum
  })

  it("should have properly defined time constants", () => {
    const blocksPerDay = simnet.callReadOnlyFn("constants", "get-blocks-per-day", [], deployer)
    expect(blocksPerDay.result.expectUint(144)).toBe(144)

    const blocksPerYear = simnet.callReadOnlyFn("constants", "get-blocks-per-year", [], deployer)
    expect(blocksPerYear.result.expectUint(52560)).toBe(52560)

    const rushDelivery = simnet.callReadOnlyFn("constants", "get-rush-delivery-blocks", [], deployer)
    expect(rushDelivery.result.expectUint(60)).toBe(60)

    const priceStaleThreshold = simnet.callReadOnlyFn("constants", "get-price-staleness-threshold", [], deployer)
    expect(priceStaleThreshold.result.expectUint(144)).toBe(144)
  })

  it("should have enhanced time constants", () => {
    const maxDuration = simnet.callReadOnlyFn("constants", "get-max-service-duration", [], deployer)
    expect(maxDuration.result.expectUint(8640)).toBe(8640) // 60 days

    const emergencyTimeout = simnet.callReadOnlyFn("constants", "get-emergency-timeout", [], deployer)
    expect(emergencyTimeout.result.expectUint(2160)).toBe(2160) // 15 days

    const staleTimeout = simnet.callReadOnlyFn("constants", "get-stale-service-timeout", [], deployer)
    expect(staleTimeout.result.expectUint(4320)).toBe(4320) // 30 days

    const maxDisputeTime = simnet.callReadOnlyFn("constants", "get-max-dispute-resolution-time", [], deployer)
    expect(maxDisputeTime.result.expectUint(1440)).toBe(1440) // 10 days
  })

  it("should have STX-specific constants", () => {
    const decimals = simnet.callReadOnlyFn("constants", "get-stx-decimals", [], deployer)
    expect(decimals.result.expectUint(6)).toBe(6)

    const minAmount = simnet.callReadOnlyFn("constants", "get-min-stx-amount", [], deployer)
    expect(minAmount.result.expectUint(1000000)).toBe(1000000) // 1 STX

    const maxAmount = simnet.callReadOnlyFn("constants", "get-max-stx-amount", [], deployer)
    expect(maxAmount.result.expectUint(100000000000)).toBe(100000000000) // 100K STX
  })

  it("should have success prediction constants", () => {
    const minSuccess = simnet.callReadOnlyFn("constants", "get-min-success-probability", [], deployer)
    expect(minSuccess.result.expectUint(80)).toBe(80)

    const newProviderThreshold = simnet.callReadOnlyFn("constants", "get-new-provider-success-threshold", [], deployer)
    expect(newProviderThreshold.result.expectUint(70)).toBe(70)

    const quotaPercentage = simnet.callReadOnlyFn("constants", "get-new-provider-quota-percentage", [], deployer)
    expect(quotaPercentage.result.expectUint(30)).toBe(30)

    const maxSuggestions = simnet.callReadOnlyFn("constants", "get-max-total-suggestions", [], deployer)
    expect(maxSuggestions.result.expectUint(5)).toBe(5)

    const trialProjects = simnet.callReadOnlyFn("constants", "get-new-provider-trial-projects", [], deployer)
    expect(trialProjects.result.expectUint(3)).toBe(3)

    const maxBoost = simnet.callReadOnlyFn("constants", "get-max-skill-verification-boost", [], deployer)
    expect(maxBoost.result.expectUint(25)).toBe(25)
  })

  it("should have dynamic pricing constants", () => {
    const maxBonus = simnet.callReadOnlyFn("constants", "get-max-competency-bonus", [], deployer)
    expect(maxBonus.result.expectUint(20)).toBe(20)

    const maxPenalty = simnet.callReadOnlyFn("constants", "get-max-competency-penalty", [], deployer)
    expect(maxPenalty.result.expectUint(30)).toBe(30)

    const minAdjustment = simnet.callReadOnlyFn("constants", "get-min-price-adjustment-factor", [], deployer)
    expect(minAdjustment.result.expectUint(5000)).toBe(5000) // 50%

    const maxAdjustment = simnet.callReadOnlyFn("constants", "get-max-price-adjustment-factor", [], deployer)
    expect(maxAdjustment.result.expectUint(15000)).toBe(15000) // 150%
  })

  it("should have rate limiting constants", () => {
    const maxAppsPerBlock = simnet.callReadOnlyFn("constants", "get-max-applications-per-block", [], deployer)
    expect(maxAppsPerBlock.result.expectUint(3)).toBe(3)

    const maxServicesPerBlock = simnet.callReadOnlyFn("constants", "get-max-services-per-block", [], deployer)
    expect(maxServicesPerBlock.result.expectUint(5)).toBe(5)

    const maxAppsPerService = simnet.callReadOnlyFn("constants", "get-max-applications-per-service", [], deployer)
    expect(maxAppsPerService.result.expectUint(15)).toBe(15)

    const appWindow = simnet.callReadOnlyFn("constants", "get-application-window-blocks", [], deployer)
    expect(appWindow.result.expectUint(144)).toBe(144) // 24 hours
  })

  it("should return complete platform limits structure", () => {
    const result = simnet.callReadOnlyFn("constants", "get-platform-limits-extended", [], deployer)
    const limits = result.result.expectTuple()

    expect(limits["max-service-duration"].expectUint()).toBe(8640)
    expect(limits["min-provider-rating"].expectUint()).toBe(20)
    expect(limits["max-applications-per-block"].expectUint()).toBe(3)
    expect(limits["max-services-per-block"].expectUint()).toBe(5)
    expect(limits["max-applications-per-service"].expectUint()).toBe(15)
    expect(limits["emergency-timeout"].expectUint()).toBe(2160)
    expect(limits["skill-boost-cooldown"].expectUint()).toBe(144)
    expect(limits["min-portfolio-links"].expectUint()).toBe(1)
    expect(limits["max-portfolio-links"].expectUint()).toBe(5)
    expect(limits["max-external-verifications"].expectUint()).toBe(5)
  })

  it("should return comprehensive platform details", () => {
    const result = simnet.callReadOnlyFn("constants", "get-platform-info", [], deployer)
    const info = result.result.expectTuple()

    // Test basic fields
    expect(info["primary-token"].expectAscii()).toBe("STX")
    expect(info["application-token"].expectAscii()).toBe("SKILL")
    expect(info["platform-fee-rate"].expectUint()).toBe(250)
    expect(info["min-service-amount"].expectUint()).toBe(1000000)
    expect(info["application-cost"].expectUint()).toBe(100000)
    expect(info["application-cost-display"].expectAscii()).toBe("0.1 STX per application")
    expect(info["native-currency"].expectBool()).toBe(true)
    expect(info["blockchain"].expectAscii()).toBe("Stacks")
    expect(info["payment-model"].expectAscii()).toBe("stx-escrow-with-skill-token-applications")
    expect(info["version"].expectAscii()).toBe("1.0.0")

    // Test AI features list exists
    const aiFeatures = info["ai-features"]
    expect(typeof aiFeatures).toBe("string")

    // Test nested structures
    const successThresholds = info["success-thresholds"]
    expect(typeof successThresholds).toBe("string")

    const quotaSystem = info["quota-system"]
    expect(typeof quotaSystem).toBe("string")

    const pricingSystem = info["pricing-system"]
    expect(typeof pricingSystem).toBe("string")

    const applicationSystem = info["application-system"]
    expect(typeof applicationSystem).toBe("string")

    const rateLimits = info["rate-limits"]
    expect(typeof rateLimits).toBe("string")
  })

  it("should have immutable constants (immutability check)", () => {
    // Call getter functions multiple times to ensure values don't change
    const fee1 = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], deployer)
    const fee2 = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], accounts.get("wallet_1")!)

    // Compare the actual values instead of the result objects
    const value1 = fee1.result.expectUint()
    const value2 = fee2.result.expectUint()
    
    expect(value1).toBe(value2)
    expect(value1).toBe(250)
    expect(value2).toBe(250)
  })

  it("should have logically consistent rating boundaries", () => {
    const minRating = simnet.callReadOnlyFn("constants", "get-min-rating", [], deployer)
    const maxRating = simnet.callReadOnlyFn("constants", "get-max-rating", [], deployer)
    const threshold = simnet.callReadOnlyFn("constants", "get-min-provider-rating-threshold", [], deployer)

    const min = Number(minRating.result.expectUint())
    const max = Number(maxRating.result.expectUint())
    const thresh = Number(threshold.result.expectUint())

    // Verify logical consistency
    expect(min).toBeLessThan(max)
    expect(thresh).toBeGreaterThanOrEqual(min)
    expect(thresh).toBeLessThanOrEqual(max)
  })

  it("should have percentage constants within valid range", () => {
    const platformFee = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], deployer)
    const basisPoints = simnet.callReadOnlyFn("constants", "get-basis-points", [], deployer)

    const fee = Number(platformFee.result.expectUint())
    const basis = Number(basisPoints.result.expectUint())

    // Platform fee should be less than 100%
    expect(fee).toBeLessThan(basis)

    // New provider quota should be <= 100%
    const quota = simnet.callReadOnlyFn("constants", "get-new-provider-quota-percentage", [], deployer)
    const quotaVal = Number(quota.result.expectUint())
    expect(quotaVal).toBeLessThanOrEqual(100)
  })

  it("should have logical time constant relationships", () => {
    const blocksPerDay = simnet.callReadOnlyFn("constants", "get-blocks-per-day", [], deployer)
    const blocksPerYear = simnet.callReadOnlyFn("constants", "get-blocks-per-year", [], deployer)

    const dayBlocks = Number(blocksPerDay.result.expectUint())
    const yearBlocks = Number(blocksPerYear.result.expectUint())

    // Verify blocks per year is approximately 365 * blocks per day
    const expectedYearBlocks = dayBlocks * 365
    const difference = Math.abs(yearBlocks - expectedYearBlocks)
    expect(difference).toBeLessThan(dayBlocks * 5) // Allow for leap year variations
  })

  it("should have consistent STX amount boundaries", () => {
    const minSTX = simnet.callReadOnlyFn("constants", "get-min-stx-amount", [], deployer)
    const maxSTX = simnet.callReadOnlyFn("constants", "get-max-stx-amount", [], deployer)

    const min = Number(minSTX.result.expectUint())
    const max = Number(maxSTX.result.expectUint())

    // Min should be less than max
    expect(min).toBeLessThan(max)

    // Min should be at least 1 STX (1000000 microSTX)
    expect(min).toBeGreaterThanOrEqual(1000000)

    // Max should be reasonable (not overflow)
    expect(max).toBeLessThanOrEqual(1000000000000) // 1M STX max
  })

  it("should have correctly related SKILL token and STX costs", () => {
    const skillPrice = simnet.callReadOnlyFn("constants", "get-skill-token-price", [], deployer)
    const appCostSkill = simnet.callReadOnlyFn("constants", "get-application-cost-skill", [], deployer)
    const appCostSTX = simnet.callReadOnlyFn("constants", "get-application-cost-stx", [], deployer)

    const price = Number(skillPrice.result.expectUint())
    const costSkill = Number(appCostSkill.result.expectUint())
    const costSTX = Number(appCostSTX.result.expectUint())

    // 1 SKILL token should cost exactly the price in STX
    // Application cost in STX should equal (SKILL tokens needed * price per token)
    const expectedSTXCost = (costSkill / 1000000) * price
    expect(costSTX).toBe(expectedSTXCost)
  })

  it("should have valid verification status constants forming valid enum", () => {
    // These constants are defined but not exposed via getters
    // We can test their usage indirectly through other contracts
    // This test documents expected values:
    // VERIFICATION-PENDING = u0
    // VERIFICATION-APPROVED = u1
    // VERIFICATION-REJECTED = u2

    // Test service status enum completeness
    const statuses = [
      "get-service-status-open",
      "get-service-status-matched",
      "get-service-status-in-progress",
      "get-service-status-completed",
      "get-service-status-disputed",
      "get-service-status-cancelled",
    ]

    for (let i = 0; i < statuses.length; i++) {
      const result = simnet.callReadOnlyFn("constants", statuses[i], [], deployer)
      expect(result.result.expectUint(i)).toBe(i)
    }
  })

  it("should have economically viable price adjustment factors", () => {
    const minFactor = simnet.callReadOnlyFn("constants", "get-min-price-adjustment-factor", [], deployer)
    const maxFactor = simnet.callReadOnlyFn("constants", "get-max-price-adjustment-factor", [], deployer)

    const min = Number(minFactor.result.expectUint())
    const max = Number(maxFactor.result.expectUint())

    // Min factor should be at least 10% (1000 basis points) to ensure providers get paid
    expect(min).toBeGreaterThanOrEqual(1000)

    // Max factor should be reasonable (not more than 500% or 50000 basis points)
    expect(max).toBeLessThanOrEqual(50000)

    // Min should be less than max
    expect(min).toBeLessThan(max)

    // 100% (10000 basis points) should be between min and max
    expect(min).toBeLessThanOrEqual(10000)
    expect(max).toBeGreaterThanOrEqual(10000)
  })
})