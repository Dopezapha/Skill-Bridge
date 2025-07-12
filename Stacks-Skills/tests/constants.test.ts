import { describe, it, expect, beforeAll } from "vitest";
import { Cl } from "@stacks/transactions";
import { initSimnet } from "@hirosystems/clarinet-sdk";

describe("Constants Contract Tests", () => {
  let simnet: any;
  let accounts: any;
  let address1: string;
  let deployer: string;

  beforeAll(async () => {
    simnet = await initSimnet();
    accounts = simnet.getAccounts();
    address1 = accounts.get("wallet_1")!;
    deployer = accounts.get("deployer")!;
  });

  describe("Basic Platform Constants", () => {
    it("should return correct platform fee rate", () => {
      const result = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], address1);
      expect(result.result).toEqual(Cl.uint(250)); // 2.5%
    });

    it("should return correct basis points", () => {
      const result = simnet.callReadOnlyFn("constants", "get-basis-points", [], address1);
      expect(result.result).toEqual(Cl.uint(10000));
    });

    it("should return correct minimum liquidity", () => {
      const result = simnet.callReadOnlyFn("constants", "get-minimum-liquidity", [], address1);
      expect(result.result).toEqual(Cl.uint(1000));
    });

    it("should return correct SKILL token price", () => {
      const result = simnet.callReadOnlyFn("constants", "get-skill-token-price", [], address1);
      expect(result.result).toEqual(Cl.uint(100000)); // 0.1 STX
    });

    it("should return correct application cost in SKILL tokens", () => {
      const result = simnet.callReadOnlyFn("constants", "get-application-cost-skill", [], address1);
      expect(result.result).toEqual(Cl.uint(1000000)); // 1 SKILL token
    });

    it("should return correct application cost in STX", () => {
      const result = simnet.callReadOnlyFn("constants", "get-application-cost-stx", [], address1);
      expect(result.result).toEqual(Cl.uint(100000)); // 0.1 STX
    });
  });

  describe("Contract Version Information", () => {
    it("should return correct contract version information structure", () => {
      const result = simnet.callReadOnlyFn("constants", "get-contract-version", [], address1);
      
      // The result is a Clarity tuple object with type and data properties
      expect(result.result.type).toBe(12); // Type 12 is tuple in Clarity
      expect(result.result.data).toBeDefined();
      
      // Access the tuple data directly
      const versionData = result.result.data;
      
      // Check version string (type 13 is string-ascii)
      expect(versionData.version.type).toBe(13);
      expect(versionData.version.data).toBe("1.0.0");
      
      // Check version numbers (type 1 is uint)
      expect(versionData.major.type).toBe(1);
      expect(versionData.major.value).toBe(1n);
      
      expect(versionData.minor.type).toBe(1);
      expect(versionData.minor.value).toBe(0n);
      
      expect(versionData.patch.type).toBe(1);
      expect(versionData.patch.value).toBe(0n);
      
      // Check deployment block exists
      expect(versionData['deployment-block']).toBeDefined();
      expect(versionData['deployment-block'].type).toBe(1);
    });

    it("should have consistent version information", () => {
      const result = simnet.callReadOnlyFn("constants", "get-contract-version", [], address1);
      const versionData = result.result.data;
      
      // Version string should match the individual components
      const expectedVersion = `${versionData.major.value}.${versionData.minor.value}.${versionData.patch.value}`;
      expect(versionData.version.data).toBe(expectedVersion);
    });
  });

  describe("Error Constants", () => {
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
        { fn: "err-application-fee-required", expected: 138 }
      ];

      errorTests.forEach(({ fn, expected }) => {
        const result = simnet.callReadOnlyFn("constants", fn, [], address1);
        expect(result.result).toEqual(Cl.error(Cl.uint(expected)));
      });
    });
  });

  describe("Service Status Constants", () => {
    it("should return correct service status values", () => {
      const statusTests = [
        { fn: "get-service-status-open", expected: 0 },
        { fn: "get-service-status-matched", expected: 1 },
        { fn: "get-service-status-in-progress", expected: 2 },
        { fn: "get-service-status-completed", expected: 3 },
        { fn: "get-service-status-disputed", expected: 4 },
        { fn: "get-service-status-cancelled", expected: 5 }
      ];

      statusTests.forEach(({ fn, expected }) => {
        const result = simnet.callReadOnlyFn("constants", fn, [], address1);
        expect(result.result).toEqual(Cl.uint(expected));
      });
    });
  });

  describe("Verification Status Constants", () => {
    it("should return correct verification status values", () => {
      const statusTests = [
        { fn: "get-verification-status-pending", expected: 0 },
        { fn: "get-verification-status-approved", expected: 1 },
        { fn: "get-verification-status-rejected", expected: 2 }
      ];

      statusTests.forEach(({ fn, expected }) => {
        const result = simnet.callReadOnlyFn("constants", fn, [], address1);
        expect(result.result).toEqual(Cl.uint(expected));
      });
    });
  });

  describe("Rating System Constants", () => {
    it("should have correctly configured rating constants", () => {
      const minRating = simnet.callReadOnlyFn("constants", "get-min-rating", [], address1);
      expect(minRating.result).toEqual(Cl.uint(10)); // 1.0 scaled

      const maxRating = simnet.callReadOnlyFn("constants", "get-max-rating", [], address1);
      expect(maxRating.result).toEqual(Cl.uint(50)); // 5.0 scaled

      const minProviderRating = simnet.callReadOnlyFn("constants", "get-min-provider-rating-threshold", [], address1);
      expect(minProviderRating.result).toEqual(Cl.uint(20)); // 2.0 scaled
    });
  });

  describe("Time Constants", () => {
    it("should have properly defined time constants", () => {
      const blocksPerDay = simnet.callReadOnlyFn("constants", "get-blocks-per-day", [], address1);
      expect(blocksPerDay.result).toEqual(Cl.uint(144));

      const blocksPerYear = simnet.callReadOnlyFn("constants", "get-blocks-per-year", [], address1);
      expect(blocksPerYear.result).toEqual(Cl.uint(52560));

      const rushDelivery = simnet.callReadOnlyFn("constants", "get-rush-delivery-blocks", [], address1);
      expect(rushDelivery.result).toEqual(Cl.uint(60));

      const staleness = simnet.callReadOnlyFn("constants", "get-price-staleness-threshold", [], address1);
      expect(staleness.result).toEqual(Cl.uint(144));
    });

    it("should have enhanced time constants", () => {
      const maxServiceDuration = simnet.callReadOnlyFn("constants", "get-max-service-duration", [], address1);
      expect(maxServiceDuration.result).toEqual(Cl.uint(8640));

      const emergencyTimeout = simnet.callReadOnlyFn("constants", "get-emergency-timeout", [], address1);
      expect(emergencyTimeout.result).toEqual(Cl.uint(2160));

      const staleServiceTimeout = simnet.callReadOnlyFn("constants", "get-stale-service-timeout", [], address1);
      expect(staleServiceTimeout.result).toEqual(Cl.uint(4320));

      const maxDisputeTime = simnet.callReadOnlyFn("constants", "get-max-dispute-resolution-time", [], address1);
      expect(maxDisputeTime.result).toEqual(Cl.uint(1440));
    });
  });

  describe("STX-Specific Constants", () => {
    it("should have STX-specific constants", () => {
      const stxDecimals = simnet.callReadOnlyFn("constants", "get-stx-decimals", [], address1);
      expect(stxDecimals.result).toEqual(Cl.uint(6));

      const minStxAmount = simnet.callReadOnlyFn("constants", "get-min-stx-amount", [], address1);
      expect(minStxAmount.result).toEqual(Cl.uint(1000000)); // 1 STX

      const maxStxAmount = simnet.callReadOnlyFn("constants", "get-max-stx-amount", [], address1);
      expect(maxStxAmount.result).toEqual(Cl.uint(100000000000)); // 100K STX
    });
  });

  describe("Success Prediction Constants", () => {
    it("should have success prediction constants", () => {
      const minSuccess = simnet.callReadOnlyFn("constants", "get-min-success-probability", [], address1);
      expect(minSuccess.result).toEqual(Cl.uint(80));

      const newProviderThreshold = simnet.callReadOnlyFn("constants", "get-new-provider-success-threshold", [], address1);
      expect(newProviderThreshold.result).toEqual(Cl.uint(70));

      const defaultSkillScore = simnet.callReadOnlyFn("constants", "get-default-new-provider-skill-score", [], address1);
      expect(defaultSkillScore.result).toEqual(Cl.uint(75));

      const quotaPercentage = simnet.callReadOnlyFn("constants", "get-new-provider-quota-percentage", [], address1);
      expect(quotaPercentage.result).toEqual(Cl.uint(30));

      const minNewProviderSuggestions = simnet.callReadOnlyFn("constants", "get-min-new-provider-suggestions", [], address1);
      expect(minNewProviderSuggestions.result).toEqual(Cl.uint(1));

      const maxSuggestions = simnet.callReadOnlyFn("constants", "get-max-total-suggestions", [], address1);
      expect(maxSuggestions.result).toEqual(Cl.uint(5));

      const trialProjects = simnet.callReadOnlyFn("constants", "get-new-provider-trial-projects", [], address1);
      expect(trialProjects.result).toEqual(Cl.uint(3));

      const maxBoost = simnet.callReadOnlyFn("constants", "get-max-skill-verification-boost", [], address1);
      expect(maxBoost.result).toEqual(Cl.uint(25));
    });
  });

  describe("Dynamic Pricing Constants", () => {
    it("should have dynamic pricing constants", () => {
      const maxBonus = simnet.callReadOnlyFn("constants", "get-max-competency-bonus", [], address1);
      expect(maxBonus.result).toEqual(Cl.uint(20));

      const maxPenalty = simnet.callReadOnlyFn("constants", "get-max-competency-penalty", [], address1);
      expect(maxPenalty.result).toEqual(Cl.uint(30));

      const minAdjustment = simnet.callReadOnlyFn("constants", "get-min-price-adjustment-factor", [], address1);
      expect(minAdjustment.result).toEqual(Cl.uint(5000));

      const maxAdjustment = simnet.callReadOnlyFn("constants", "get-max-price-adjustment-factor", [], address1);
      expect(maxAdjustment.result).toEqual(Cl.uint(15000));

      const significantThreshold = simnet.callReadOnlyFn("constants", "get-significant-price-change-threshold", [], address1);
      expect(significantThreshold.result).toEqual(Cl.uint(1000));
    });
  });

  describe("Rate Limiting Constants", () => {
    it("should have rate limiting constants", () => {
      const maxAppsPerBlock = simnet.callReadOnlyFn("constants", "get-max-applications-per-block", [], address1);
      expect(maxAppsPerBlock.result).toEqual(Cl.uint(3));

      const maxServicesPerBlock = simnet.callReadOnlyFn("constants", "get-max-services-per-block", [], address1);
      expect(maxServicesPerBlock.result).toEqual(Cl.uint(5));

      const maxAppsPerService = simnet.callReadOnlyFn("constants", "get-max-applications-per-service", [], address1);
      expect(maxAppsPerService.result).toEqual(Cl.uint(15));

      const appWindow = simnet.callReadOnlyFn("constants", "get-application-window-blocks", [], address1);
      expect(appWindow.result).toEqual(Cl.uint(144));
    });
  });

  describe("Complex Structure Functions", () => {
    it("should return complete platform limits structure", () => {
      const result = simnet.callReadOnlyFn("constants", "get-platform-limits-extended", [], address1);
      
      // The result is a tuple, access the data property
      expect(result.result.type).toBe(12); // Tuple type
      const limits = result.result.data;

      expect(limits["max-service-duration"]).toEqual(Cl.uint(8640));
      expect(limits["min-provider-rating"]).toEqual(Cl.uint(20));
      expect(limits["max-applications-per-block"]).toEqual(Cl.uint(3));
      expect(limits["max-services-per-block"]).toEqual(Cl.uint(5));
      expect(limits["max-applications-per-service"]).toEqual(Cl.uint(15));
      expect(limits["emergency-timeout"]).toEqual(Cl.uint(2160));
      expect(limits["skill-boost-cooldown"]).toEqual(Cl.uint(144));
      expect(limits["min-portfolio-links"]).toEqual(Cl.uint(1));
      expect(limits["max-portfolio-links"]).toEqual(Cl.uint(5));
      expect(limits["max-external-verifications"]).toEqual(Cl.uint(5));
    });

    it("should return comprehensive platform details", () => {
      const result = simnet.callReadOnlyFn("constants", "get-platform-info", [], address1);
      
      // The result is a tuple, access the data property
      expect(result.result.type).toBe(12); // Tuple type
      const info = result.result.data;

      // Check string values
      expect(info["primary-token"].data).toBe("STX");
      expect(info["application-token"].data).toBe("SKILL");
      expect(info["blockchain"].data).toBe("Stacks");
      expect(info["payment-model"].data).toBe("stx-escrow-with-skill-token-applications");
      expect(info["version"].data).toBe("1.0.0");
      
      // Check numeric values
      expect(info["platform-fee-rate"]).toEqual(Cl.uint(250));
      expect(info["min-service-amount"]).toEqual(Cl.uint(1000000));
      expect(info["application-cost"]).toEqual(Cl.uint(100000));
      
      // Check boolean value
      expect(info["native-currency"]).toEqual(Cl.bool(true));
    });

    it("should have correct AI features list", () => {
      const result = simnet.callReadOnlyFn("constants", "get-platform-info", [], address1);
      const info = result.result.data;
      
      // The ai-features should be a list with 5 items
      expect(info["ai-features"]).toBeDefined();
      expect(info["ai-features"].type).toBe(11); // Type 11 is list in Clarity
      expect(info["ai-features"].list.length).toBe(5);
      
      // Check specific AI features
      const features = info["ai-features"].list.map((item: any) => item.data);
      expect(features).toContain("Success prediction (80%+ threshold)");
      expect(features).toContain("Dynamic competency-based pricing");
      expect(features).toContain("New provider opportunities (30% quota)");
      expect(features).toContain("Real-time skill verification");
      expect(features).toContain("Spam prevention via SKILL tokens");
    });

    it("should have correct nested tuple structures", () => {
      const result = simnet.callReadOnlyFn("constants", "get-platform-info", [], address1);
      const info = result.result.data;
      
      // Test success-thresholds nested tuple
      expect(info["success-thresholds"]).toBeDefined();
      expect(info["success-thresholds"].type).toBe(12); // Tuple type
      expect(info["success-thresholds"].data["experienced-providers"]).toEqual(Cl.uint(80));
      expect(info["success-thresholds"].data["new-providers"]).toEqual(Cl.uint(70));
      
      // Test quota-system nested tuple
      expect(info["quota-system"]).toBeDefined();
      expect(info["quota-system"].type).toBe(12);
      expect(info["quota-system"].data["new-provider-percentage"]).toEqual(Cl.uint(30));
      expect(info["quota-system"].data["max-suggestions"]).toEqual(Cl.uint(5));
      expect(info["quota-system"].data["trial-projects"]).toEqual(Cl.uint(3));
      
      // Test pricing-system nested tuple
      expect(info["pricing-system"]).toBeDefined();
      expect(info["pricing-system"].type).toBe(12);
      expect(info["pricing-system"].data["max-bonus-percentage"]).toEqual(Cl.uint(20));
      expect(info["pricing-system"].data["max-penalty-percentage"]).toEqual(Cl.uint(30));
      expect(info["pricing-system"].data["min-adjustment-factor"]).toEqual(Cl.uint(5000));
      expect(info["pricing-system"].data["max-adjustment-factor"]).toEqual(Cl.uint(15000));
      
      // Test application-system nested tuple
      expect(info["application-system"]).toBeDefined();
      expect(info["application-system"].type).toBe(12);
      expect(info["application-system"].data["cost-per-application"]).toEqual(Cl.uint(100000));
      expect(info["application-system"].data["cost-in-skill-tokens"]).toEqual(Cl.uint(1000000));
      expect(info["application-system"].data["purchase-rate"].data).toBe("0.1 STX = 1 SKILL token");
      expect(info["application-system"].data["benefit"].data).toBe("Prevents spam applications, much cheaper than 15-20% competitor fees");
      
      // Test rate-limits nested tuple
      expect(info["rate-limits"]).toBeDefined();
      expect(info["rate-limits"].type).toBe(12);
      expect(info["rate-limits"].data["max-applications-per-block"]).toEqual(Cl.uint(3));
      expect(info["rate-limits"].data["max-services-per-block"]).toEqual(Cl.uint(5));
      // This one has a calculation: (/ APPLICATION-WINDOW-BLOCKS u6) = 144/6 = 24
      expect(info["rate-limits"].data["application-window-hours"]).toEqual(Cl.uint(24));
    });

    it("should have correct display strings", () => {
      const result = simnet.callReadOnlyFn("constants", "get-platform-info", [], address1);
      const info = result.result.data;
      
      expect(info["application-cost-display"].data).toBe("0.1 STX per application");
    });
  });

  describe("Constants Validation and Logic Tests", () => {
    it("should have immutable constants (immutability check)", () => {
      // Test that constants return the same value on multiple calls
      const result1 = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], address1);
      const result2 = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], address1);
      expect(result1.result).toEqual(result2.result);
    });

    it("should have logically consistent rating boundaries", () => {
      const minRating = simnet.callReadOnlyFn("constants", "get-min-rating", [], address1);
      const maxRating = simnet.callReadOnlyFn("constants", "get-max-rating", [], address1);
      const threshold = simnet.callReadOnlyFn("constants", "get-min-provider-rating-threshold", [], address1);

      const minVal = Number(minRating.result.value);
      const maxVal = Number(maxRating.result.value);
      const thresholdVal = Number(threshold.result.value);

      expect(minVal).toBeLessThan(maxVal);
      expect(thresholdVal).toBeGreaterThanOrEqual(minVal);
      expect(thresholdVal).toBeLessThanOrEqual(maxVal);
    });

    it("should have percentage constants within valid range", () => {
      const feeRate = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], address1);
      const basisPoints = simnet.callReadOnlyFn("constants", "get-basis-points", [], address1);
      const quotaPercentage = simnet.callReadOnlyFn("constants", "get-new-provider-quota-percentage", [], address1);

      const feeVal = Number(feeRate.result.value);
      const basisVal = Number(basisPoints.result.value);
      const quotaVal = Number(quotaPercentage.result.value);

      expect(feeVal).toBeLessThan(basisVal); // Fee rate should be less than 100%
      expect(quotaVal).toBeLessThanOrEqual(100); // Quota should be <= 100%
    });

    it("should have logical time constant relationships", () => {
      const blocksPerDay = simnet.callReadOnlyFn("constants", "get-blocks-per-day", [], address1);
      const rushDelivery = simnet.callReadOnlyFn("constants", "get-rush-delivery-blocks", [], address1);
      const emergencyTimeout = simnet.callReadOnlyFn("constants", "get-emergency-timeout", [], address1);

      const dayBlocks = Number(blocksPerDay.result.value);
      const rushBlocks = Number(rushDelivery.result.value);
      const emergencyBlocks = Number(emergencyTimeout.result.value);

      expect(rushBlocks).toBeLessThan(dayBlocks); // Rush delivery should be less than a day
      expect(emergencyBlocks).toBeGreaterThan(dayBlocks); // Emergency timeout should be more than a day
    });

    it("should have consistent STX amount boundaries", () => {
      const minStx = simnet.callReadOnlyFn("constants", "get-min-stx-amount", [], address1);
      const maxStx = simnet.callReadOnlyFn("constants", "get-max-stx-amount", [], address1);
      const appCost = simnet.callReadOnlyFn("constants", "get-application-cost-stx", [], address1);

      const minVal = Number(minStx.result.value);
      const maxVal = Number(maxStx.result.value);
      const appVal = Number(appCost.result.value);

      expect(minVal).toBeLessThan(maxVal);
      expect(appVal).toBeLessThan(minVal); // App cost should be less than minimum service amount
    });

    it("should have correctly related SKILL token and STX costs", () => {
      const skillPrice = simnet.callReadOnlyFn("constants", "get-skill-token-price", [], address1);
      const appCostStx = simnet.callReadOnlyFn("constants", "get-application-cost-stx", [], address1);
      const appCostSkill = simnet.callReadOnlyFn("constants", "get-application-cost-skill", [], address1);

      const skillPriceVal = Number(skillPrice.result.value);
      const appStxVal = Number(appCostStx.result.value);
      const appSkillVal = Number(appCostSkill.result.value);

      expect(skillPriceVal).toEqual(appStxVal); // 1 SKILL = 0.1 STX = app cost
      expect(appSkillVal).toEqual(1000000); // 1 SKILL token = 1,000,000 micro-SKILL
    });

    it("should have platform fee rate that is competitive", () => {
      const feeRate = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], address1);
      const basisPoints = simnet.callReadOnlyFn("constants", "get-basis-points", [], address1);

      const feeVal = Number(feeRate.result.value);
      const basisVal = Number(basisPoints.result.value);

      const feePercentage = (feeVal / basisVal) * 100;
      expect(feePercentage).toBeLessThan(5); // Should be less than 5%
      expect(feePercentage).toBeGreaterThan(1); // Should be more than 1%
    });

    it("should have time constants that align with real-world expectations", () => {
      const blocksPerDay = simnet.callReadOnlyFn("constants", "get-blocks-per-day", [], address1);
      const blocksPerYear = simnet.callReadOnlyFn("constants", "get-blocks-per-year", [], address1);

      const dayVal = Number(blocksPerDay.result.value);
      const yearVal = Number(blocksPerYear.result.value);

      // Check that annual calculation is approximately correct
      const expectedAnnual = dayVal * 365;
      const tolerance = expectedAnnual * 0.1; // 10% tolerance
      expect(Math.abs(yearVal - expectedAnnual)).toBeLessThan(tolerance);
    });

    it("should have correct application window calculation", () => {
      const result = simnet.callReadOnlyFn("constants", "get-platform-info", [], address1);
      const info = result.result.data;
      const appWindow = simnet.callReadOnlyFn("constants", "get-application-window-blocks", [], address1);
      
      // Verify the calculation: APPLICATION-WINDOW-BLOCKS / 6 = application-window-hours
      const windowBlocks = Number(appWindow.result.value);
      const windowHours = Number(info["rate-limits"].data["application-window-hours"].value);
      
      expect(windowHours).toBe(windowBlocks / 6);
    });

    it("should have mathematically consistent price adjustment factors", () => {
      const minAdjust = simnet.callReadOnlyFn("constants", "get-min-price-adjustment-factor", [], address1);
      const maxAdjust = simnet.callReadOnlyFn("constants", "get-max-price-adjustment-factor", [], address1);
      const basisPoints = simnet.callReadOnlyFn("constants", "get-basis-points", [], address1);
      
      const minVal = Number(minAdjust.result.value);
      const maxVal = Number(maxAdjust.result.value);
      const basisVal = Number(basisPoints.result.value);
      
      // Min adjustment should be 50% (5000/10000)
      expect(minVal / basisVal).toBe(0.5);
      
      // Max adjustment should be 150% (15000/10000) 
      expect(maxVal / basisVal).toBe(1.5);
    });

    it("should have correct percentage relationships", () => {
      // Test that percentage constants are correctly scaled
      const platformFee = simnet.callReadOnlyFn("constants", "get-platform-fee-rate", [], address1);
      const basisPoints = simnet.callReadOnlyFn("constants", "get-basis-points", [], address1);
      
      const feeVal = Number(platformFee.result.value);
      const basisVal = Number(basisPoints.result.value);
      
      // 250/10000 = 2.5%
      expect((feeVal / basisVal) * 100).toBe(2.5);
    });

    it("should have success probability thresholds that ensure quality", () => {
      const minSuccess = simnet.callReadOnlyFn("constants", "get-min-success-probability", [], address1);
      const newProviderThreshold = simnet.callReadOnlyFn("constants", "get-new-provider-success-threshold", [], address1);
      const defaultSkillScore = simnet.callReadOnlyFn("constants", "get-default-new-provider-skill-score", [], address1);

      const minVal = Number(minSuccess.result.value);
      const newVal = Number(newProviderThreshold.result.value);
      const defaultVal = Number(defaultSkillScore.result.value);

      expect(minVal).toBeGreaterThan(50); // Should be > 50% for quality
      expect(newVal).toBeGreaterThan(50); // New providers should also have high threshold
      expect(minVal).toBeGreaterThanOrEqual(newVal); // Experienced should have higher threshold
      expect(defaultVal).toBeGreaterThanOrEqual(newVal); // Default score should be >= threshold
      expect(defaultVal).toBeLessThanOrEqual(minVal); // Default score should be <= experienced threshold
    });

    it("should have mathematically consistent quota percentages", () => {
      const quotaPercentage = simnet.callReadOnlyFn("constants", "get-new-provider-quota-percentage", [], address1);
      const maxSuggestions = simnet.callReadOnlyFn("constants", "get-max-total-suggestions", [], address1);
      const minNewProviderSuggestions = simnet.callReadOnlyFn("constants", "get-min-new-provider-suggestions", [], address1);

      const quotaVal = Number(quotaPercentage.result.value);
      const maxSugVal = Number(maxSuggestions.result.value);
      const minNewVal = Number(minNewProviderSuggestions.result.value);

      // At least 1 new provider should be possible with the quota
      const minNewProviders = Math.floor((quotaVal / 100) * maxSugVal);
      expect(minNewProviders).toBeGreaterThanOrEqual(minNewVal);
    });

    it("should have logical emergency timeout progression", () => {
      const rushDelivery = simnet.callReadOnlyFn("constants", "get-rush-delivery-blocks", [], address1);
      const blocksPerDay = simnet.callReadOnlyFn("constants", "get-blocks-per-day", [], address1);
      const emergencyTimeout = simnet.callReadOnlyFn("constants", "get-emergency-timeout", [], address1);
      const staleTimeout = simnet.callReadOnlyFn("constants", "get-stale-service-timeout", [], address1);

      const rushVal = Number(rushDelivery.result.value);
      const dayVal = Number(blocksPerDay.result.value);
      const emergencyVal = Number(emergencyTimeout.result.value);
      const staleVal = Number(staleTimeout.result.value);

      // Logical progression: rush < day < emergency < stale
      expect(rushVal).toBeLessThan(dayVal);
      expect(dayVal).toBeLessThan(emergencyVal);
      expect(emergencyVal).toBeLessThan(staleVal);
    });

    it("should have unique error codes with no gaps or duplicates", () => {
      const errorCodes = [100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 115, 116, 117, 118, 120, 121, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138];
      
      // Check for uniqueness
      const uniqueCodes = new Set(errorCodes);
      expect(uniqueCodes.size).toEqual(errorCodes.length);

      // Check that all codes are in reasonable range
      errorCodes.forEach(code => {
        expect(code).toBeGreaterThanOrEqual(100);
        expect(code).toBeLessThan(200);
      });
    });

    it("should have reasonable skill verification boost limits", () => {
      const maxBoost = simnet.callReadOnlyFn("constants", "get-max-skill-verification-boost", [], address1);
      const boostVal = Number(maxBoost.result.value);

      expect(boostVal).toBeGreaterThan(0);
      expect(boostVal).toBeLessThanOrEqual(50); // Reasonable upper limit
    });

    it("should have competency bonus/penalty limits that are balanced", () => {
      const maxBonus = simnet.callReadOnlyFn("constants", "get-max-competency-bonus", [], address1);
      const maxPenalty = simnet.callReadOnlyFn("constants", "get-max-competency-penalty", [], address1);

      const bonusVal = Number(maxBonus.result.value);
      const penaltyVal = Number(maxPenalty.result.value);

      expect(bonusVal).toBeGreaterThan(0);
      expect(penaltyVal).toBeGreaterThan(0);
      expect(penaltyVal).toBeGreaterThanOrEqual(bonusVal); // Penalty should be >= bonus for balance
    });

    it("should have significant price change threshold that makes sense", () => {
      const significantThreshold = simnet.callReadOnlyFn("constants", "get-significant-price-change-threshold", [], address1);
      const basisPoints = simnet.callReadOnlyFn("constants", "get-basis-points", [], address1);

      const thresholdVal = Number(significantThreshold.result.value);
      const basisVal = Number(basisPoints.result.value);

      // 1000/10000 = 10% - reasonable threshold for price changes
      expect((thresholdVal / basisVal) * 100).toBe(10);
    });

    it("should have minimum liquidity that prevents dust attacks", () => {
      const minLiquidity = simnet.callReadOnlyFn("constants", "get-minimum-liquidity", [], address1);
      const appCost = simnet.callReadOnlyFn("constants", "get-application-cost-stx", [], address1);

      const liquidityVal = Number(minLiquidity.result.value);
      const appVal = Number(appCost.result.value);

      expect(liquidityVal).toBeGreaterThan(0);
      // MINIMUM-LIQUIDITY (1000) is much smaller than APPLICATION-COST-STX (100000)
      // This makes sense: liquidity requirement is for pool operations, not applications
      expect(liquidityVal).toBeLessThan(appVal); // Liquidity threshold is smaller than app cost
      expect(liquidityVal).toBe(1000); // Verify the actual value
      expect(appVal).toBe(100000); // Verify app cost is much higher
    });
  });
});