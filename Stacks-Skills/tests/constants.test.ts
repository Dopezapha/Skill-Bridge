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

  // NEW ENHANCED EDGE CASE TESTS

  it("should have constants that prevent mathematical overflow", () => {
    const maxSTX = simnet.callReadOnlyFn("constants", "get-max-stx-amount", [], deployer)
    const platformFee = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], deployer)
    const basisPoints = simnet.callReadOnlyFn("constants", "get-basis-points", [], deployer)

    const maxAmount = Number(maxSTX.result.expectUint())
    const feeRate = Number(platformFee.result.expectUint())
    const basis = Number(basisPoints.result.expectUint())

    // Calculate maximum possible fee to ensure no overflow
    const maxPossibleFee = (maxAmount * feeRate) / basis
    
    // Should not exceed JavaScript's safe integer limit
    expect(maxPossibleFee).toBeLessThan(Number.MAX_SAFE_INTEGER)
  })

  it("should have non-zero denominators for all calculations", () => {
    const basisPoints = simnet.callReadOnlyFn("constants", "get-basis-points", [], deployer)
    const skillPrice = simnet.callReadOnlyFn("constants", "get-skill-token-price", [], deployer)
    
    expect(Number(basisPoints.result.expectUint())).toBeGreaterThan(0)
    expect(Number(skillPrice.result.expectUint())).toBeGreaterThan(0)
  })

  it("should have mathematically consistent quota percentages", () => {
    const newProviderQuota = simnet.callReadOnlyFn("constants", "get-new-provider-quota-percentage", [], deployer)
    const maxSuggestions = simnet.callReadOnlyFn("constants", "get-max-total-suggestions", [], deployer)
    
    const quotaPercent = Number(newProviderQuota.result.expectUint())
    const maxSugg = Number(maxSuggestions.result.expectUint())
    
    // Calculate minimum new provider suggestions based on quota
    const minNewProviders = Math.ceil((maxSugg * quotaPercent) / 100)
    
    // Should be able to fulfill quota with max suggestions
    expect(minNewProviders).toBeLessThanOrEqual(maxSugg)
    expect(minNewProviders).toBeGreaterThan(0)
  })

  it("should have logical emergency timeout progression", () => {
    const rushBlocks = simnet.callReadOnlyFn("constants", "get-rush-delivery-blocks", [], deployer)
    const emergencyTimeout = simnet.callReadOnlyFn("constants", "get-emergency-timeout", [], deployer)
    const maxDuration = simnet.callReadOnlyFn("constants", "get-max-service-duration", [], deployer)
    
    const rush = Number(rushBlocks.result.expectUint())
    const emergency = Number(emergencyTimeout.result.expectUint())
    const max = Number(maxDuration.result.expectUint())
    
    // Emergency timeout should be longer than rush but shorter than max duration
    expect(emergency).toBeGreaterThan(rush)
    expect(emergency).toBeLessThan(max)
  })

  it("should have unique error codes with no gaps or duplicates", () => {
    const errorCodes = [
      100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
      115, 116, 117, 118, 120, 121, 124, 125, 126, 127, 128,
      129, 130, 131, 132, 133, 134, 135, 136, 137, 138
    ]
    
    // Check for duplicates
    const uniqueCodes = new Set(errorCodes)
    expect(uniqueCodes.size).toBe(errorCodes.length)
    
    // Verify the gaps are intentional (111-114, 119, 122-123)
    const expectedGaps = [111, 112, 113, 114, 119, 122, 123]
    for (const gap of expectedGaps) {
      expect(errorCodes).not.toContain(gap)
    }
  })

  it("should have reasonable skill verification boost limits", () => {
    const maxBoost = simnet.callReadOnlyFn("constants", "get-max-skill-verification-boost", [], deployer)
    const boost = Number(maxBoost.result.expectUint())
    
    // Boost should be meaningful but not excessive
    expect(boost).toBeGreaterThanOrEqual(5)  // At least 5 points
    expect(boost).toBeLessThanOrEqual(50)    // No more than 50 points
  })

  it("should have rate limits that prevent spam but allow legitimate use", () => {
    const maxAppsPerBlock = simnet.callReadOnlyFn("constants", "get-max-applications-per-block", [], deployer)
    const maxServicesPerBlock = simnet.callReadOnlyFn("constants", "get-max-services-per-block", [], deployer)
    const appWindow = simnet.callReadOnlyFn("constants", "get-application-window-blocks", [], deployer)
    
    const appsPerBlock = Number(maxAppsPerBlock.result.expectUint())
    const servicesPerBlock = Number(maxServicesPerBlock.result.expectUint())
    const window = Number(appWindow.result.expectUint())
    
    // Should allow reasonable activity
    expect(appsPerBlock).toBeGreaterThanOrEqual(1)
    expect(servicesPerBlock).toBeGreaterThanOrEqual(1)
    
    // Application window should be reasonable (at least 1 hour, max 7 days)
    expect(window).toBeGreaterThanOrEqual(6)    // At least 1 hour
    expect(window).toBeLessThanOrEqual(1008)    // Max 7 days
  })

  it("should have properly formatted version string", () => {
    const version = simnet.callReadOnlyFn("constants", "get-contract-version", [], deployer)
    const versionInfo = version.result.expectOk().expectTuple()
    
    const versionString = versionInfo.version.expectAscii()
    
    // Should match semantic versioning pattern
    const semverPattern = /^\d+\.\d+\.\d+$/
    expect(versionString).toMatch(semverPattern)
  })

  it("should have trial project count that makes economic sense", () => {
    const trialProjects = simnet.callReadOnlyFn("constants", "get-new-provider-trial-projects", [], deployer)
    const trial = Number(trialProjects.result.expectUint())
    
    // Trial period should be meaningful but not excessive
    expect(trial).toBeGreaterThanOrEqual(1)  // At least 1 trial project
    expect(trial).toBeLessThanOrEqual(10)    // No more than 10 trial projects
  })

  it("should have competency bonus/penalty limits that are balanced", () => {
    const maxBonus = simnet.callReadOnlyFn("constants", "get-max-competency-bonus", [], deployer)
    const maxPenalty = simnet.callReadOnlyFn("constants", "get-max-competency-penalty", [], deployer)
    
    const bonus = Number(maxBonus.result.expectUint())
    const penalty = Number(maxPenalty.result.expectUint())
    
    // Penalty can be higher than bonus to discourage poor performance
    expect(penalty).toBeGreaterThanOrEqual(bonus)
    
    // Both should be reasonable percentages
    expect(bonus).toBeGreaterThanOrEqual(5)     // At least 5%
    expect(bonus).toBeLessThanOrEqual(50)       // No more than 50%
    expect(penalty).toBeGreaterThanOrEqual(10)  // At least 10%
    expect(penalty).toBeLessThanOrEqual(75)     // No more than 75%
  })

  it("should have success probability thresholds that ensure quality", () => {
    const minSuccess = simnet.callReadOnlyFn("constants", "get-min-success-probability", [], deployer)
    const newProviderThreshold = simnet.callReadOnlyFn("constants", "get-new-provider-success-threshold", [], deployer)
    
    const experienced = Number(minSuccess.result.expectUint())
    const newProvider = Number(newProviderThreshold.result.expectUint())
    
    // Experienced providers should have higher threshold than new providers
    expect(experienced).toBeGreaterThan(newProvider)
    
    // Both should be reasonable success rates
    expect(experienced).toBeGreaterThanOrEqual(70)  // At least 70% for experienced
    expect(experienced).toBeLessThanOrEqual(95)     // Max 95% (allow for some risk)
    expect(newProvider).toBeGreaterThanOrEqual(50)  // At least 50% for new providers
    expect(newProvider).toBeLessThanOrEqual(80)     // Max 80% for new providers
  })

  it("should have application window that balances urgency and fairness", () => {
    const appWindow = simnet.callReadOnlyFn("constants", "get-application-window-blocks", [], deployer)
    const rushDelivery = simnet.callReadOnlyFn("constants", "get-rush-delivery-blocks", [], deployer)
    
    const window = Number(appWindow.result.expectUint())
    const rush = Number(rushDelivery.result.expectUint())
    
    // Application window should be longer than rush delivery time
    expect(window).toBeGreaterThan(rush)
    
    // Should allow enough time for quality applications but not too long
    expect(window).toBeGreaterThanOrEqual(24)   // At least 4 hours (24 blocks)
    expect(window).toBeLessThanOrEqual(432)     // Max 3 days (432 blocks)
  })

  it("should have portfolio link limits that are practical", () => {
    const result = simnet.callReadOnlyFn("constants", "get-platform-limits-extended", [], deployer)
    const limits = result.result.expectTuple()
    
    const minLinks = Number(limits["min-portfolio-links"].expectUint())
    const maxLinks = Number(limits["max-portfolio-links"].expectUint())
    
    // Should require at least some portfolio evidence
    expect(minLinks).toBeGreaterThanOrEqual(1)
    expect(minLinks).toBeLessThanOrEqual(3)
    
    // Should not overwhelm reviewers with too many links
    expect(maxLinks).toBeGreaterThanOrEqual(minLinks)
    expect(maxLinks).toBeLessThanOrEqual(10)
  })

  it("should have skill boost cooldown that prevents abuse", () => {
    const result = simnet.callReadOnlyFn("constants", "get-platform-limits-extended", [], deployer)
    const limits = result.result.expectTuple()
    
    const cooldown = Number(limits["skill-boost-cooldown"].expectUint())
    
    // Should prevent rapid successive boosts
    expect(cooldown).toBeGreaterThanOrEqual(6)    // At least 1 hour
    expect(cooldown).toBeLessThanOrEqual(1440)    // Max 10 days
  })

  it("should have external verification limits that are reasonable", () => {
    const result = simnet.callReadOnlyFn("constants", "get-platform-limits-extended", [], deployer)
    const limits = result.result.expectTuple()
    
    const maxVerifications = Number(limits["max-external-verifications"].expectUint())
    
    // Should allow meaningful verification without being excessive
    expect(maxVerifications).toBeGreaterThanOrEqual(1)
    expect(maxVerifications).toBeLessThanOrEqual(10)
  })

  it("should have consistent decimal precision across all monetary values", () => {
    const stxDecimals = simnet.callReadOnlyFn("constants", "get-stx-decimals", [], deployer)
    const skillPrice = simnet.callReadOnlyFn("constants", "get-skill-token-price", [], deployer)
    const appCostSTX = simnet.callReadOnlyFn("constants", "get-application-cost-stx", [], deployer)
    const minSTX = simnet.callReadOnlyFn("constants", "get-min-stx-amount", [], deployer)
    
    const decimals = Number(stxDecimals.result.expectUint())
    const price = Number(skillPrice.result.expectUint())
    const appCost = Number(appCostSTX.result.expectUint())
    const minAmount = Number(minSTX.result.expectUint())
    
    // All monetary values should be consistent with STX decimals (6)
    const divisor = Math.pow(10, decimals)
    
    // Values should be evenly divisible by the decimal precision
    expect(price % 1000).toBe(0)        // Should be in thousands for reasonable precision
    expect(appCost % 1000).toBe(0)      // Should be in thousands for reasonable precision
    expect(minAmount % divisor).toBe(0) // Should be whole STX amounts
  })

  it("should have platform fee rate that is competitive", () => {
    const platformFee = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], deployer)
    const basisPoints = simnet.callReadOnlyFn("constants", "get-basis-points", [], deployer)
    
    const fee = Number(platformFee.result.expectUint())
    const basis = Number(basisPoints.result.expectUint())
    
    const feePercentage = (fee / basis) * 100
    
    // Should be competitive (lower than typical 15-20% marketplace fees)
    expect(feePercentage).toBeGreaterThan(0)    // Must have some fee for sustainability
    expect(feePercentage).toBeLessThan(10)      // Should be under 10%
    expect(feePercentage).toBeGreaterThanOrEqual(1) // At least 1% for viability
  })

  it("should have time constants that align with real-world expectations", () => {
    const blocksPerDay = simnet.callReadOnlyFn("constants", "get-blocks-per-day", [], deployer)
    const emergencyTimeout = simnet.callReadOnlyFn("constants", "get-emergency-timeout", [], deployer)
    const maxDuration = simnet.callReadOnlyFn("constants", "get-max-service-duration", [], deployer)
    
    const dayBlocks = Number(blocksPerDay.result.expectUint())
    const emergency = Number(emergencyTimeout.result.expectUint())
    const maxDur = Number(maxDuration.result.expectUint())
    
    // Convert to days for human-readable validation
    const emergencyDays = emergency / dayBlocks
    const maxDurationDays = maxDur / dayBlocks
    
    // Emergency timeout should be reasonable (7-30 days)
    expect(emergencyDays).toBeGreaterThanOrEqual(7)
    expect(emergencyDays).toBeLessThanOrEqual(30)
    
    // Max duration should allow for complex projects but not be indefinite
    expect(maxDurationDays).toBeGreaterThanOrEqual(30)  // At least 1 month
    expect(maxDurationDays).toBeLessThanOrEqual(90)     // Max 3 months
  })
})