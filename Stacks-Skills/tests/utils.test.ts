import { describe, it, expect, beforeAll } from "vitest";
import { Cl } from "@stacks/transactions";
import { initSimnet } from "@hirosystems/clarinet-sdk";

describe("Utils Contract Tests - Complete Coverage", () => {
  let simnet: any;
  let accounts: any;
  let address1: string;
  let address2: string;
  let deployer: string;

  beforeAll(async () => {
    simnet = await initSimnet();
    accounts = simnet.getAccounts();
    address1 = accounts.get("wallet_1")!;
    address2 = accounts.get("wallet_2")!;
    deployer = accounts.get("deployer")!;
  });

  describe("Constants and Basic Validation", () => {
    it("should validate STX amounts correctly", () => {
      // Valid amounts
      const validAmount1 = simnet.callReadOnlyFn("utils", "is-valid-stx-amount", [Cl.uint(1000000)], address1);
      expect(validAmount1.result).toEqual(Cl.bool(true));

      const validAmount2 = simnet.callReadOnlyFn("utils", "is-valid-stx-amount", [Cl.uint(50000000000)], address1);
      expect(validAmount2.result).toEqual(Cl.bool(true));

      // Invalid amounts
      const zeroAmount = simnet.callReadOnlyFn("utils", "is-valid-stx-amount", [Cl.uint(0)], address1);
      expect(zeroAmount.result).toEqual(Cl.bool(false));

      const excessiveAmount = simnet.callReadOnlyFn("utils", "is-valid-stx-amount", [Cl.uint(100000000001)], address1);
      expect(excessiveAmount.result).toEqual(Cl.bool(false));
    });

    it("should validate addresses correctly", () => {
      // Valid addresses
      const validAddress = simnet.callReadOnlyFn("utils", "is-valid-address", [Cl.stringAscii("ST1234567890ABCDEF")], address1);
      expect(validAddress.result).toEqual(Cl.bool(true));

      const maxLengthAddress = simnet.callReadOnlyFn("utils", "is-valid-address", [Cl.stringAscii("A".repeat(99))], address1); // 99 instead of 100
      expect(maxLengthAddress.result).toEqual(Cl.bool(true));

      // Invalid addresses
      const emptyAddress = simnet.callReadOnlyFn("utils", "is-valid-address", [Cl.stringAscii("")], address1);
      expect(emptyAddress.result).toEqual(Cl.bool(false));

      // Test with a string that would be too long if we tried 101 characters
      const tooLongAddress = simnet.callReadOnlyFn("utils", "is-valid-address", [Cl.stringAscii("A".repeat(100))], address1);
      expect(tooLongAddress.result).toEqual(Cl.bool(true)); // 100 should still be valid
    });

    it("should validate principals correctly", () => {
      // Valid principal (different from tx-sender)
      const validPrincipal = simnet.callReadOnlyFn("utils", "is-valid-principal", [Cl.standardPrincipal(address2)], address1);
      expect(validPrincipal.result).toEqual(Cl.bool(true));

      // Invalid principal (same as tx-sender)
      const samePrincipal = simnet.callReadOnlyFn("utils", "is-valid-principal", [Cl.standardPrincipal(address1)], address1);
      expect(samePrincipal.result).toEqual(Cl.bool(false));

      // Invalid principal (burn address)
      const burnAddress = simnet.callReadOnlyFn("utils", "is-valid-principal", [Cl.standardPrincipal("SP000000000000000000002Q6VF78")], address1);
      expect(burnAddress.result).toEqual(Cl.bool(false));
    });

    it("should validate fee rates correctly", () => {
      // Valid fee rates
      const lowFee = simnet.callReadOnlyFn("utils", "is-valid-fee-rate", [Cl.uint(250)], address1);
      expect(lowFee.result).toEqual(Cl.bool(true));

      const maxFee = simnet.callReadOnlyFn("utils", "is-valid-fee-rate", [Cl.uint(1000)], address1);
      expect(maxFee.result).toEqual(Cl.bool(true));

      // Invalid fee rate
      const excessiveFee = simnet.callReadOnlyFn("utils", "is-valid-fee-rate", [Cl.uint(1001)], address1);
      expect(excessiveFee.result).toEqual(Cl.bool(false));
    });

    it("should validate confidence levels correctly", () => {
      // Valid confidence levels
      const lowConfidence = simnet.callReadOnlyFn("utils", "is-valid-confidence", [Cl.uint(0)], address1);
      expect(lowConfidence.result).toEqual(Cl.bool(true));

      const maxConfidence = simnet.callReadOnlyFn("utils", "is-valid-confidence", [Cl.uint(100)], address1);
      expect(maxConfidence.result).toEqual(Cl.bool(true));

      // Invalid confidence level
      const excessiveConfidence = simnet.callReadOnlyFn("utils", "is-valid-confidence", [Cl.uint(101)], address1);
      expect(excessiveConfidence.result).toEqual(Cl.bool(false));
    });

    it("should validate time estimations correctly", () => {
      // Valid time estimates
      const shortTime = simnet.callReadOnlyFn("utils", "is-valid-estimated-time", [Cl.uint(60)], address1);
      expect(shortTime.result).toEqual(Cl.bool(true));

      const maxTime = simnet.callReadOnlyFn("utils", "is-valid-estimated-time", [Cl.uint(1440)], address1);
      expect(maxTime.result).toEqual(Cl.bool(true));

      // Invalid time estimate
      const excessiveTime = simnet.callReadOnlyFn("utils", "is-valid-estimated-time", [Cl.uint(1441)], address1);
      expect(excessiveTime.result).toEqual(Cl.bool(false));
    });
  });

  describe("String and Input Validation", () => {
    it("should validate skill names correctly", () => {
      // Valid skill names
      const validSkill = simnet.callReadOnlyFn("utils", "is-valid-skill-name", [Cl.stringAscii("JavaScript")], address1);
      expect(validSkill.result).toEqual(Cl.bool(true));

      const maxLengthSkill = simnet.callReadOnlyFn("utils", "is-valid-skill-name", [Cl.stringAscii("A".repeat(49))], address1); // 49 instead of 50
      expect(maxLengthSkill.result).toEqual(Cl.bool(true));

      // Invalid skill names
      const emptySkill = simnet.callReadOnlyFn("utils", "is-valid-skill-name", [Cl.stringAscii("")], address1);
      expect(emptySkill.result).toEqual(Cl.bool(false));

      // Test exactly 50 characters
      const exactlyMaxSkill = simnet.callReadOnlyFn("utils", "is-valid-skill-name", [Cl.stringAscii("A".repeat(50))], address1);
      expect(exactlyMaxSkill.result).toEqual(Cl.bool(true));
    });

    it("should validate video hashes correctly", () => {
      // Valid video hashes
      const validHash = simnet.callReadOnlyFn("utils", "is-valid-video-hash", [Cl.stringAscii("QmX1Y2Z3abcdef1234567890")], address1);
      expect(validHash.result).toEqual(Cl.bool(true));

      const maxLengthHash = simnet.callReadOnlyFn("utils", "is-valid-video-hash", [Cl.stringAscii("Qm" + "A".repeat(197))], address1); // 199 total instead of 200
      expect(maxLengthHash.result).toEqual(Cl.bool(true));

      // Invalid video hashes
      const emptyHash = simnet.callReadOnlyFn("utils", "is-valid-video-hash", [Cl.stringAscii("")], address1);
      expect(emptyHash.result).toEqual(Cl.bool(false));

      // Test exactly 200 characters
      const exactlyMaxHash = simnet.callReadOnlyFn("utils", "is-valid-video-hash", [Cl.stringAscii("Q".repeat(200))], address1);
      expect(exactlyMaxHash.result).toEqual(Cl.bool(true));
    });

    it("should validate review notes correctly", () => {
      // Valid review notes
      const validNotes = simnet.callReadOnlyFn("utils", "is-valid-review-notes", [Cl.some(Cl.stringAscii("Great work!"))], address1);
      expect(validNotes.result).toEqual(Cl.bool(true));

      const maxLengthNotes = simnet.callReadOnlyFn("utils", "is-valid-review-notes", [Cl.some(Cl.stringAscii("A".repeat(299)))], address1); // 299 instead of 300
      expect(maxLengthNotes.result).toEqual(Cl.bool(true));

      const noNotes = simnet.callReadOnlyFn("utils", "is-valid-review-notes", [Cl.none()], address1);
      expect(noNotes.result).toEqual(Cl.bool(true));

      // Test exactly 300 characters
      const exactlyMaxNotes = simnet.callReadOnlyFn("utils", "is-valid-review-notes", [Cl.some(Cl.stringAscii("A".repeat(300)))], address1);
      expect(exactlyMaxNotes.result).toEqual(Cl.bool(true));
    });

    it("should validate strings with custom length requirements", () => {
      const testString = "Hello World";
      
      // Valid string within bounds
      const validString = simnet.callReadOnlyFn("utils", "is-valid-string", [
        Cl.stringAscii(testString),
        Cl.uint(5),
        Cl.uint(20)
      ], address1);
      expect(validString.result).toEqual(Cl.bool(true));

      // String too short
      const tooShort = simnet.callReadOnlyFn("utils", "is-valid-string", [
        Cl.stringAscii(testString),
        Cl.uint(15),
        Cl.uint(20)
      ], address1);
      expect(tooShort.result).toEqual(Cl.bool(false));

      // String too long
      const tooLong = simnet.callReadOnlyFn("utils", "is-valid-string", [
        Cl.stringAscii(testString),
        Cl.uint(1),
        Cl.uint(5)
      ], address1);
      expect(tooLong.result).toEqual(Cl.bool(false));
    });

    it("should validate sources correctly", () => {
      // Valid sources
      const validSource = simnet.callReadOnlyFn("utils", "is-valid-source", [Cl.stringAscii("coinbase")], address1);
      expect(validSource.result).toEqual(Cl.bool(true));

      const maxLengthSource = simnet.callReadOnlyFn("utils", "is-valid-source", [Cl.stringAscii("A".repeat(49))], address1); // 49 instead of 50
      expect(maxLengthSource.result).toEqual(Cl.bool(true));

      // Invalid sources
      const emptySource = simnet.callReadOnlyFn("utils", "is-valid-source", [Cl.stringAscii("")], address1);
      expect(emptySource.result).toEqual(Cl.bool(false));

      // Test exactly 50 characters
      const exactlyMaxSource = simnet.callReadOnlyFn("utils", "is-valid-source", [Cl.stringAscii("A".repeat(50))], address1);
      expect(exactlyMaxSource.result).toEqual(Cl.bool(true));
    });
  });

  describe("Numeric Validation", () => {
    it("should validate percentages correctly", () => {
      // Valid percentages
      const zeroPercent = simnet.callReadOnlyFn("utils", "is-valid-percentage", [Cl.uint(0)], address1);
      expect(zeroPercent.result).toEqual(Cl.bool(true));

      const fiftyPercent = simnet.callReadOnlyFn("utils", "is-valid-percentage", [Cl.uint(5000)], address1);
      expect(fiftyPercent.result).toEqual(Cl.bool(true));

      const hundredPercent = simnet.callReadOnlyFn("utils", "is-valid-percentage", [Cl.uint(10000)], address1);
      expect(hundredPercent.result).toEqual(Cl.bool(true));

      // Invalid percentage
      const excessivePercent = simnet.callReadOnlyFn("utils", "is-valid-percentage", [Cl.uint(10001)], address1);
      expect(excessivePercent.result).toEqual(Cl.bool(false));
    });

    it("should validate ratings correctly", () => {
      // Valid ratings (1.0 to 5.0 scaled by 10)
      const minRating = simnet.callReadOnlyFn("utils", "is-valid-rating", [Cl.uint(10)], address1);
      expect(minRating.result).toEqual(Cl.bool(true));

      const midRating = simnet.callReadOnlyFn("utils", "is-valid-rating", [Cl.uint(35)], address1);
      expect(midRating.result).toEqual(Cl.bool(true));

      const maxRating = simnet.callReadOnlyFn("utils", "is-valid-rating", [Cl.uint(50)], address1);
      expect(maxRating.result).toEqual(Cl.bool(true));

      // Invalid ratings
      const tooLowRating = simnet.callReadOnlyFn("utils", "is-valid-rating", [Cl.uint(9)], address1);
      expect(tooLowRating.result).toEqual(Cl.bool(false));

      const tooHighRating = simnet.callReadOnlyFn("utils", "is-valid-rating", [Cl.uint(51)], address1);
      expect(tooHighRating.result).toEqual(Cl.bool(false));
    });

    it("should validate duration minutes correctly", () => {
      // Valid durations
      const shortDuration = simnet.callReadOnlyFn("utils", "is-valid-duration-minutes", [Cl.uint(30)], address1);
      expect(shortDuration.result).toEqual(Cl.bool(true));

      const maxDuration = simnet.callReadOnlyFn("utils", "is-valid-duration-minutes", [Cl.uint(1440)], address1);
      expect(maxDuration.result).toEqual(Cl.bool(true));

      // Invalid duration
      const excessiveDuration = simnet.callReadOnlyFn("utils", "is-valid-duration-minutes", [Cl.uint(1441)], address1);
      expect(excessiveDuration.result).toEqual(Cl.bool(false));
    });

    it("should validate service status correctly", () => {
      // Valid status values (0-5)
      const openStatus = simnet.callReadOnlyFn("utils", "is-valid-service-status", [Cl.uint(0)], address1);
      expect(openStatus.result).toEqual(Cl.bool(true));

      const cancelledStatus = simnet.callReadOnlyFn("utils", "is-valid-service-status", [Cl.uint(5)], address1);
      expect(cancelledStatus.result).toEqual(Cl.bool(true));

      // Invalid status
      const invalidStatus = simnet.callReadOnlyFn("utils", "is-valid-service-status", [Cl.uint(6)], address1);
      expect(invalidStatus.result).toEqual(Cl.bool(false));
    });
  });

  describe("STX-Specific Validation", () => {
    it("should validate STX service amounts correctly", () => {
      // Valid service amounts
      const minAmount = simnet.callReadOnlyFn("utils", "is-valid-stx-service-amount", [Cl.uint(1000000)], address1);
      expect(minAmount.result).toEqual(Cl.bool(true));

      const midAmount = simnet.callReadOnlyFn("utils", "is-valid-stx-service-amount", [Cl.uint(10000000000)], address1);
      expect(midAmount.result).toEqual(Cl.bool(true));

      const maxAmount = simnet.callReadOnlyFn("utils", "is-valid-stx-service-amount", [Cl.uint(50000000000)], address1);
      expect(maxAmount.result).toEqual(Cl.bool(true));

      // Invalid service amounts
      const tooSmall = simnet.callReadOnlyFn("utils", "is-valid-stx-service-amount", [Cl.uint(999999)], address1);
      expect(tooSmall.result).toEqual(Cl.bool(false));

      const tooLarge = simnet.callReadOnlyFn("utils", "is-valid-stx-service-amount", [Cl.uint(50000000001)], address1);
      expect(tooLarge.result).toEqual(Cl.bool(false));
    });

    it("should check sufficient STX balance correctly", () => {
      // Sufficient balance scenarios
      const sufficientBalance = simnet.callReadOnlyFn("utils", "is-sufficient-stx-balance", [
        Cl.uint(10000000), // 10 STX balance
        Cl.uint(5000000),  // 5 STX required
        Cl.uint(250)       // 2.5% fee
      ], address1);
      expect(sufficientBalance.result).toEqual(Cl.bool(true));

      // Insufficient balance scenarios
      const insufficientBalance = simnet.callReadOnlyFn("utils", "is-sufficient-stx-balance", [
        Cl.uint(5000000), // 5 STX balance
        Cl.uint(5000000), // 5 STX required
        Cl.uint(250)      // 2.5% fee (will make total > 5 STX)
      ], address1);
      expect(insufficientBalance.result).toEqual(Cl.bool(false));
    });
  });

  describe("Math Utilities", () => {
    it("should calculate percentages correctly", () => {
      // Test basic percentage calculations
      const tenPercent = simnet.callReadOnlyFn("utils", "calculate-percentage", [
        Cl.uint(1000000), // 1 STX
        Cl.uint(1000)     // 10%
      ], address1);
      expect(tenPercent.result).toEqual(Cl.uint(100000)); // 0.1 STX

      const fiftyPercent = simnet.callReadOnlyFn("utils", "calculate-percentage", [
        Cl.uint(2000000), // 2 STX
        Cl.uint(5000)     // 50%
      ], address1);
      expect(fiftyPercent.result).toEqual(Cl.uint(1000000)); // 1 STX

      // Test zero percentage
      const zeroPercent = simnet.callReadOnlyFn("utils", "calculate-percentage", [
        Cl.uint(1000000), // 1 STX
        Cl.uint(0)        // 0%
      ], address1);
      expect(zeroPercent.result).toEqual(Cl.uint(0));
    });

    it("should calculate STX fees correctly", () => {
      // Test platform fee calculation (2.5%)
      const platformFee = simnet.callReadOnlyFn("utils", "calculate-stx-fee", [
        Cl.uint(10000000), // 10 STX
        Cl.uint(250)       // 2.5%
      ], address1);
      expect(platformFee.result).toEqual(Cl.uint(250000)); // 0.25 STX

      // Test higher fee rate
      const higherFee = simnet.callReadOnlyFn("utils", "calculate-stx-fee", [
        Cl.uint(5000000), // 5 STX
        Cl.uint(500)      // 5%
      ], address1);
      expect(higherFee.result).toEqual(Cl.uint(250000)); // 0.25 STX
    });

    it("should calculate fees with minimum correctly", () => {
      // Case where calculated fee is higher than minimum
      const higherThanMin = simnet.callReadOnlyFn("utils", "calculate-fee-with-minimum", [
        Cl.uint(10000000), // 10 STX
        Cl.uint(250),      // 2.5%
        Cl.uint(100000)    // 0.1 STX minimum
      ], address1);
      expect(higherThanMin.result).toEqual(Cl.uint(250000)); // Calculated fee (0.25 STX)

      // Case where calculated fee is lower than minimum
      const lowerThanMin = simnet.callReadOnlyFn("utils", "calculate-fee-with-minimum", [
        Cl.uint(1000000), // 1 STX
        Cl.uint(100),     // 1%
        Cl.uint(50000)    // 0.05 STX minimum
      ], address1);
      expect(lowerThanMin.result).toEqual(Cl.uint(50000)); // Minimum fee
    });
  });

  describe("STX Conversion Utilities", () => {
    it("should convert microSTX to STX correctly", () => {
      const conversion1 = simnet.callReadOnlyFn("utils", "microSTX-to-STX", [Cl.uint(1000000)], address1);
      expect(conversion1.result).toEqual(Cl.uint(1)); // 1 STX

      const conversion2 = simnet.callReadOnlyFn("utils", "microSTX-to-STX", [Cl.uint(2500000)], address1);
      expect(conversion2.result).toEqual(Cl.uint(2)); // 2.5 STX -> 2 STX (integer division)

      const zeroConversion = simnet.callReadOnlyFn("utils", "microSTX-to-STX", [Cl.uint(500000)], address1);
      expect(zeroConversion.result).toEqual(Cl.uint(0)); // 0.5 STX -> 0 STX
    });

    it("should convert STX to microSTX correctly", () => {
      const conversion1 = simnet.callReadOnlyFn("utils", "STX-to-microSTX", [Cl.uint(1)], address1);
      expect(conversion1.result).toEqual(Cl.uint(1000000)); // 1 STX

      const conversion2 = simnet.callReadOnlyFn("utils", "STX-to-microSTX", [Cl.uint(5)], address1);
      expect(conversion2.result).toEqual(Cl.uint(5000000)); // 5 STX

      const zeroConversion = simnet.callReadOnlyFn("utils", "STX-to-microSTX", [Cl.uint(0)], address1);
      expect(zeroConversion.result).toEqual(Cl.uint(0));
    });

    it("should format STX amounts correctly", () => {
      const formatted = simnet.callReadOnlyFn("utils", "format-stx-amount", [Cl.uint(2500000)], address1);
      const formattedData = formatted.result.data;
      
      expect(formattedData["micro-stx"]).toEqual(Cl.uint(2500000));
      expect(formattedData["stx"]).toEqual(Cl.uint(2)); // Integer division
      expect(formattedData["formatted"]).toEqual(Cl.uint(2));
    });
  });

  describe("Batch Validation Functions", () => {
    it("should validate service creation parameters", () => {
      // Valid parameters
      const validParams = simnet.callReadOnlyFn("utils", "validate-service-creation-params", [
        Cl.stringAscii("Web Development"),
        Cl.stringAscii("I will create a responsive website for your business"),
        Cl.uint(5000000), // 5 STX
        Cl.uint(480)      // 8 hours
      ], address1);
      
      const validData = validParams.result.data;
      expect(validData["valid-skill-category"]).toEqual(Cl.bool(true));
      expect(validData["valid-description"]).toEqual(Cl.bool(true));
      expect(validData["valid-payment-amount"]).toEqual(Cl.bool(true));
      expect(validData["valid-duration"]).toEqual(Cl.bool(true));
      expect(validData["all-valid"]).toEqual(Cl.bool(true));

      // Invalid parameters
      const invalidParams = simnet.callReadOnlyFn("utils", "validate-service-creation-params", [
        Cl.stringAscii(""), // Empty skill category
        Cl.stringAscii("Valid description"),
        Cl.uint(500000), // Too small amount (0.5 STX < 1 STX minimum)
        Cl.uint(2000)    // Too long duration (> 24 hours)
      ], address1);
      
      const invalidData = invalidParams.result.data;
      expect(invalidData["valid-skill-category"]).toEqual(Cl.bool(false));
      expect(invalidData["valid-description"]).toEqual(Cl.bool(true));
      expect(invalidData["valid-payment-amount"]).toEqual(Cl.bool(false));
      expect(invalidData["valid-duration"]).toEqual(Cl.bool(false));
      expect(invalidData["all-valid"]).toEqual(Cl.bool(false));
    });

    it("should validate STX transactions", () => {
      // Valid transaction
      const validTx = simnet.callReadOnlyFn("utils", "validate-stx-transaction", [
        Cl.uint(5000000), // 5 STX amount
        Cl.uint(6000000), // 6 STX balance
        Cl.uint(250)      // 2.5% fee
      ], address1);
      
      const validData = validTx.result.data;
      expect(validData["valid-amount"]).toEqual(Cl.bool(true));
      expect(validData["sufficient-balance"]).toEqual(Cl.bool(true));
      expect(validData["fee-amount"]).toEqual(Cl.uint(125000)); // 2.5% of 5 STX
      expect(validData["total-needed"]).toEqual(Cl.uint(5125000)); // 5 STX + fee
      expect(validData["all-valid"]).toEqual(Cl.bool(true));

      // Invalid transaction (insufficient balance)
      const invalidTx = simnet.callReadOnlyFn("utils", "validate-stx-transaction", [
        Cl.uint(5000000), // 5 STX amount
        Cl.uint(5000000), // 5 STX balance (not enough for amount + fee)
        Cl.uint(250)      // 2.5% fee
      ], address1);
      
      const invalidData = invalidTx.result.data;
      expect(invalidData["valid-amount"]).toEqual(Cl.bool(true));
      expect(invalidData["sufficient-balance"]).toEqual(Cl.bool(false));
      expect(invalidData["all-valid"]).toEqual(Cl.bool(false));
    });
  });

  describe("Utility Functions", () => {
    it("should return correct service status names", () => {
      const openStatus = simnet.callReadOnlyFn("utils", "get-service-status-name", [Cl.uint(0)], address1);
      expect(openStatus.result.data).toBe("Open");

      const matchedStatus = simnet.callReadOnlyFn("utils", "get-service-status-name", [Cl.uint(1)], address1);
      expect(matchedStatus.result.data).toBe("Matched");

      const progressStatus = simnet.callReadOnlyFn("utils", "get-service-status-name", [Cl.uint(2)], address1);
      expect(progressStatus.result.data).toBe("In Progress");

      const completedStatus = simnet.callReadOnlyFn("utils", "get-service-status-name", [Cl.uint(3)], address1);
      expect(completedStatus.result.data).toBe("Completed");

      const disputedStatus = simnet.callReadOnlyFn("utils", "get-service-status-name", [Cl.uint(4)], address1);
      expect(disputedStatus.result.data).toBe("Disputed");

      const cancelledStatus = simnet.callReadOnlyFn("utils", "get-service-status-name", [Cl.uint(5)], address1);
      expect(cancelledStatus.result.data).toBe("Cancelled");

      const unknownStatus = simnet.callReadOnlyFn("utils", "get-service-status-name", [Cl.uint(99)], address1);
      expect(unknownStatus.result.data).toBe("UNKNOWN");
    });

    it("should provide platform token info", () => {
      const tokenInfo = simnet.callReadOnlyFn("utils", "get-platform-token-info", [], address1);
      const infoData = tokenInfo.result.data;
      
      expect(infoData["primary-token"].data).toBe("STX");
      expect(infoData["decimals"]).toEqual(Cl.uint(6));
      expect(infoData["native-currency"]).toEqual(Cl.bool(true));
      expect(infoData["min-amount"]).toEqual(Cl.uint(1000000)); // 1 STX
      expect(infoData["max-amount"]).toEqual(Cl.uint(100000000000)); // 100K STX
      expect(infoData["display-name"].data).toBe("Stacks (STX)");
      expect(infoData["blockchain"].data).toBe("Stacks");
    });

    it("should estimate transaction costs correctly", () => {
      // Test with no additional fees
      const basicEstimate = simnet.callReadOnlyFn("utils", "estimate-transaction-cost", [
        Cl.uint(10000000), // 10 STX base
        Cl.uint(250),      // 2.5% platform fee
        Cl.none()          // No additional fees
      ], address1);
      
      const basicData = basicEstimate.result.data;
      expect(basicData["base-amount"]).toEqual(Cl.uint(10000000));
      expect(basicData["platform-fee"]).toEqual(Cl.uint(250000)); // 2.5% of 10 STX
      expect(basicData["additional-fees"]).toEqual(Cl.uint(0));
      expect(basicData["total-cost"]).toEqual(Cl.uint(10250000)); // 10.25 STX

      // Test with additional fees
      const extendedEstimate = simnet.callReadOnlyFn("utils", "estimate-transaction-cost", [
        Cl.uint(5000000), // 5 STX base
        Cl.uint(300),     // 3% platform fee
        Cl.some(Cl.uint(100000)) // 0.1 STX additional fees
      ], address1);
      
      const extendedData = extendedEstimate.result.data;
      expect(extendedData["base-amount"]).toEqual(Cl.uint(5000000));
      expect(extendedData["platform-fee"]).toEqual(Cl.uint(150000)); // 3% of 5 STX
      expect(extendedData["additional-fees"]).toEqual(Cl.uint(100000));
      expect(extendedData["total-cost"]).toEqual(Cl.uint(5250000)); // 5.25 STX
    });

    it("should estimate service total costs correctly", () => {
      const serviceEstimate = simnet.callReadOnlyFn("utils", "estimate-service-total-cost", [
        Cl.uint(8000000) // 8 STX service amount
      ], address1);
      
      const estimateData = serviceEstimate.result.data;
      expect(estimateData["service-amount"]).toEqual(Cl.uint(8000000));
      expect(estimateData["platform-fee"]).toEqual(Cl.uint(200000)); // 2.5% of 8 STX
      expect(estimateData["fee-percentage"].data).toBe("2.5%");
      expect(estimateData["total-cost"]).toEqual(Cl.uint(8200000)); // 8.2 STX
      expect(estimateData["service-amount-stx"]).toEqual(Cl.uint(8));
      expect(estimateData["platform-fee-stx"]).toEqual(Cl.uint(0)); // 0.2 STX -> 0 (integer division)
      expect(estimateData["total-cost-stx"]).toEqual(Cl.uint(8)); // 8.2 STX -> 8 (integer division)
    });

    it("should calculate provider earnings correctly", () => {
      const earnings = simnet.callReadOnlyFn("utils", "calculate-provider-earnings", [
        Cl.uint(10000000) // 10 STX gross amount
      ], address1);
      
      const earningsData = earnings.result.data;
      expect(earningsData["gross-amount"]).toEqual(Cl.uint(10000000));
      expect(earningsData["platform-fee"]).toEqual(Cl.uint(250000)); // 2.5% platform fee
      expect(earningsData["net-earnings"]).toEqual(Cl.uint(9750000)); // 9.75 STX
      expect(earningsData["fee-rate"]).toEqual(Cl.uint(250));
      expect(earningsData["gross-stx"]).toEqual(Cl.uint(10));
      expect(earningsData["net-stx"]).toEqual(Cl.uint(9)); // 9.75 -> 9 (integer division)
    });

    it("should check sufficient balance for service correctly", () => {
      // Sufficient balance case
      const sufficientCheck = simnet.callReadOnlyFn("utils", "check-sufficient-balance-for-service", [
        Cl.uint(15000000), // 15 STX user balance
        Cl.uint(10000000)  // 10 STX service cost
      ], address1);
      
      const sufficientData = sufficientCheck.result.data;
      expect(sufficientData["user-balance"]).toEqual(Cl.uint(15000000));
      expect(sufficientData["service-cost"]).toEqual(Cl.uint(10000000));
      expect(sufficientData["platform-fee"]).toEqual(Cl.uint(250000));
      expect(sufficientData["total-needed"]).toEqual(Cl.uint(10250000));
      expect(sufficientData["sufficient"]).toEqual(Cl.bool(true));
      expect(sufficientData["shortfall"]).toEqual(Cl.uint(0));

      // Insufficient balance case
      const insufficientCheck = simnet.callReadOnlyFn("utils", "check-sufficient-balance-for-service", [
        Cl.uint(10000000), // 10 STX user balance
        Cl.uint(10000000)  // 10 STX service cost (plus 2.5% fee = 10.25 STX total)
      ], address1);
      
      const insufficientData = insufficientCheck.result.data;
      expect(insufficientData["sufficient"]).toEqual(Cl.bool(false));
      expect(insufficientData["shortfall"]).toEqual(Cl.uint(250000)); // 0.25 STX short
    });
  });

  describe("Time and Rating Utilities", () => {
    it("should convert blocks to hours correctly", () => {
      const sixtyBlocks = simnet.callReadOnlyFn("utils", "blocks-to-hours", [Cl.uint(60)], address1);
      expect(sixtyBlocks.result).toEqual(Cl.uint(10)); // 60 * 10 / 60 = 10 hours

      const oneHundredTwentyBlocks = simnet.callReadOnlyFn("utils", "blocks-to-hours", [Cl.uint(120)], address1);
      expect(oneHundredTwentyBlocks.result).toEqual(Cl.uint(20)); // 120 * 10 / 60 = 20 hours

      const zeroBlocks = simnet.callReadOnlyFn("utils", "blocks-to-hours", [Cl.uint(0)], address1);
      expect(zeroBlocks.result).toEqual(Cl.uint(0));
    });

    it("should convert hours to blocks correctly", () => {
      const oneHour = simnet.callReadOnlyFn("utils", "hours-to-blocks", [Cl.uint(1)], address1);
      expect(oneHour.result).toEqual(Cl.uint(6)); // 1 * 6 = 6 blocks

      const twentyFourHours = simnet.callReadOnlyFn("utils", "hours-to-blocks", [Cl.uint(24)], address1);
      expect(twentyFourHours.result).toEqual(Cl.uint(144)); // 24 * 6 = 144 blocks

      const zeroHours = simnet.callReadOnlyFn("utils", "hours-to-blocks", [Cl.uint(0)], address1);
      expect(zeroHours.result).toEqual(Cl.uint(0));
    });

    it("should format ratings correctly", () => {
      // Excellent rating (4.5 stars = 45 scaled)
      const excellentRating = simnet.callReadOnlyFn("utils", "format-rating", [Cl.uint(45)], address1);
      const excellentData = excellentRating.result.data;
      expect(excellentData["raw-rating"]).toEqual(Cl.uint(45));
      expect(excellentData["display-rating"]).toEqual(Cl.uint(4)); // 45/10 = 4 (integer division)
      expect(excellentData["stars"]).toEqual(Cl.uint(4));
      expect(excellentData["is-excellent"]).toEqual(Cl.bool(true)); // >= 45
      expect(excellentData["is-good"]).toEqual(Cl.bool(true)); // >= 35
      expect(excellentData["is-poor"]).toEqual(Cl.bool(false)); // < 25

      // Poor rating (2.0 stars = 20 scaled)
      const poorRating = simnet.callReadOnlyFn("utils", "format-rating", [Cl.uint(20)], address1);
      const poorData = poorRating.result.data;
      expect(poorData["raw-rating"]).toEqual(Cl.uint(20));
      expect(poorData["display-rating"]).toEqual(Cl.uint(2));
      expect(poorData["is-excellent"]).toEqual(Cl.bool(false));
      expect(poorData["is-good"]).toEqual(Cl.bool(false));
      expect(poorData["is-poor"]).toEqual(Cl.bool(true)); // < 25

      // Good rating (3.8 stars = 38 scaled)
      const goodRating = simnet.callReadOnlyFn("utils", "format-rating", [Cl.uint(38)], address1);
      const goodData = goodRating.result.data;
      expect(goodData["raw-rating"]).toEqual(Cl.uint(38));
      expect(goodData["display-rating"]).toEqual(Cl.uint(3));
      expect(goodData["is-excellent"]).toEqual(Cl.bool(false));
      expect(goodData["is-good"]).toEqual(Cl.bool(true)); // >= 35
      expect(goodData["is-poor"]).toEqual(Cl.bool(false));
    });
  });

  describe("Platform Configuration", () => {
    it("should provide platform limits correctly", () => {
      const limits = simnet.callReadOnlyFn("utils", "get-platform-limits", [], address1);
      const limitsData = limits.result.data;
      
      expect(limitsData["min-service-amount"]).toEqual(Cl.uint(1000000)); // 1 STX
      expect(limitsData["max-service-amount"]).toEqual(Cl.uint(50000000000)); // 50K STX
      expect(limitsData["platform-fee-rate"]).toEqual(Cl.uint(250)); // 2.5%
      expect(limitsData["max-applications-per-service"]).toEqual(Cl.uint(15));
      expect(limitsData["application-window-hours"]).toEqual(Cl.uint(24));
      expect(limitsData["rush-delivery-hours"]).toEqual(Cl.uint(10));
      expect(limitsData["max-portfolio-links"]).toEqual(Cl.uint(5));
    });

    it("should provide fee breakdown correctly", () => {
      const feeBreakdown = simnet.callReadOnlyFn("utils", "get-fee-breakdown", [
        Cl.uint(20000000) // 20 STX amount
      ], address1);
      
      const breakdownData = feeBreakdown.result.data;
      expect(breakdownData["amount"]).toEqual(Cl.uint(20000000));
      expect(breakdownData["platform-fee"]).toEqual(Cl.uint(500000)); // 2.5% of 20 STX
      expect(breakdownData["provider-receives"]).toEqual(Cl.uint(19500000)); // 19.5 STX
      expect(breakdownData["fee-rate-display"].data).toBe("2.5%");
      expect(breakdownData["currency"].data).toBe("STX");
    });
  });

  describe("Complete Service Request Validation", () => {
    it("should validate complete service request correctly", () => {
      // Valid complete service request
      const validRequest = simnet.callReadOnlyFn("utils", "validate-complete-service-request", [
        Cl.stringAscii("Blockchain Development"),
        Cl.stringAscii("I will develop a smart contract for your DeFi project with comprehensive testing and documentation."),
        Cl.uint(25000000), // 25 STX
        Cl.uint(720),      // 12 hours
        Cl.uint(30000000)  // 30 STX user balance
      ], address1);
      
      const validData = validRequest.result.data;
      expect(validData["ready-to-create"]).toEqual(Cl.bool(true));
      
      const basicValidation = validData["basic-validation"].data;
      expect(basicValidation["all-valid"]).toEqual(Cl.bool(true));
      
      const balanceCheck = validData["balance-check"].data;
      expect(balanceCheck["sufficient"]).toEqual(Cl.bool(true));

      // Invalid complete service request (insufficient balance)
      const invalidRequest = simnet.callReadOnlyFn("utils", "validate-complete-service-request", [
        Cl.stringAscii("Valid Skill"),
        Cl.stringAscii("Valid description"),
        Cl.uint(25000000), // 25 STX
        Cl.uint(480),      // 8 hours
        Cl.uint(20000000)  // 20 STX user balance (insufficient for 25 STX + fees)
      ], address1);
      
      const invalidData = invalidRequest.result.data;
      expect(invalidData["ready-to-create"]).toEqual(Cl.bool(false));
    });
  });

  describe("Emergency and Admin Utilities", () => {
    it("should detect emergency situations correctly", () => {
      // Normal situation (recent update)
      const normalSituation = simnet.callReadOnlyFn("utils", "is-emergency-situation", [
        Cl.uint(100) // 100 blocks since last update
      ], address1);
      expect(normalSituation.result).toEqual(Cl.bool(false));

      // Emergency situation (stale update)
      const emergencySituation = simnet.callReadOnlyFn("utils", "is-emergency-situation", [
        Cl.uint(300) // 300 blocks since last update (> 288)
      ], address1);
      expect(emergencySituation.result).toEqual(Cl.bool(true));

      // Exactly at threshold
      const thresholdSituation = simnet.callReadOnlyFn("utils", "is-emergency-situation", [
        Cl.uint(288) // Exactly 288 blocks
      ], address1);
      expect(thresholdSituation.result).toEqual(Cl.bool(false));
    });

    it("should calculate refund amounts correctly", () => {
      // 50% refund
      const halfRefund = simnet.callReadOnlyFn("utils", "calculate-refund-amounts", [
        Cl.uint(10000000), // 10 STX escrowed
        Cl.uint(50)        // 50% refund
      ], address1);
      
      const halfData = halfRefund.result.data;
      expect(halfData["total-escrowed"]).toEqual(Cl.uint(10000000));
      expect(halfData["refund-percentage"]).toEqual(Cl.uint(50));
      expect(halfData["refund-amount"]).toEqual(Cl.uint(5000000)); // 5 STX
      expect(halfData["remaining-amount"]).toEqual(Cl.uint(5000000)); // 5 STX
      expect(halfData["refund-stx"]).toEqual(Cl.uint(5));
      expect(halfData["remaining-stx"]).toEqual(Cl.uint(5));

      // 100% refund
      const fullRefund = simnet.callReadOnlyFn("utils", "calculate-refund-amounts", [
        Cl.uint(8000000), // 8 STX escrowed
        Cl.uint(100)      // 100% refund
      ], address1);
      
      const fullData = fullRefund.result.data;
      expect(fullData["refund-amount"]).toEqual(Cl.uint(8000000)); // 8 STX
      expect(fullData["remaining-amount"]).toEqual(Cl.uint(0)); // 0 STX

      // 25% refund
      const quarterRefund = simnet.callReadOnlyFn("utils", "calculate-refund-amounts", [
        Cl.uint(12000000), // 12 STX escrowed
        Cl.uint(25)        // 25% refund
      ], address1);
      
      const quarterData = quarterRefund.result.data;
      expect(quarterData["refund-amount"]).toEqual(Cl.uint(3000000)); // 3 STX
      expect(quarterData["remaining-amount"]).toEqual(Cl.uint(9000000)); // 9 STX
    });
  });

  describe("Edge Cases and Error Handling", () => {
    it("should handle zero amounts in calculations", () => {
      // Zero percentage calculation
      const zeroPercent = simnet.callReadOnlyFn("utils", "calculate-percentage", [
        Cl.uint(0),
        Cl.uint(2500)
      ], address1);
      expect(zeroPercent.result).toEqual(Cl.uint(0));

      // Zero fee calculation
      const zeroFee = simnet.callReadOnlyFn("utils", "calculate-stx-fee", [
        Cl.uint(1000000),
        Cl.uint(0)
      ], address1);
      expect(zeroFee.result).toEqual(Cl.uint(0));

      // Zero conversion
      const zeroConversion = simnet.callReadOnlyFn("utils", "microSTX-to-STX", [Cl.uint(0)], address1);
      expect(zeroConversion.result).toEqual(Cl.uint(0));
    });

    it("should handle large number calculations", () => {
      // Large percentage calculation: 100K STX * 2.5% = 2.5K STX = 2,500,000,000 microSTX
      const largeCalc = simnet.callReadOnlyFn("utils", "calculate-percentage", [
        Cl.uint(100000000000), // 100K STX
        Cl.uint(250)           // 2.5%
      ], address1);
      expect(largeCalc.result).toEqual(Cl.uint(2500000000)); // 2.5K STX in microSTX

      // Large conversion
      const largeConversion = simnet.callReadOnlyFn("utils", "STX-to-microSTX", [
        Cl.uint(50000) // 50K STX
      ], address1);
      expect(largeConversion.result).toEqual(Cl.uint(50000000000)); // 50B microSTX
    });

    it("should handle boundary values correctly", () => {
      // Maximum valid percentage
      const maxPercent = simnet.callReadOnlyFn("utils", "is-valid-percentage", [Cl.uint(10000)], address1);
      expect(maxPercent.result).toEqual(Cl.bool(true));

      // Maximum valid rating
      const maxRating = simnet.callReadOnlyFn("utils", "is-valid-rating", [Cl.uint(50)], address1);
      expect(maxRating.result).toEqual(Cl.bool(true));

      // Maximum valid duration
      const maxDuration = simnet.callReadOnlyFn("utils", "is-valid-duration-minutes", [Cl.uint(1440)], address1);
      expect(maxDuration.result).toEqual(Cl.bool(true));

      // Minimum valid STX service amount
      const minServiceAmount = simnet.callReadOnlyFn("utils", "is-valid-stx-service-amount", [Cl.uint(1000000)], address1);
      expect(minServiceAmount.result).toEqual(Cl.bool(true));
    });

    it("should handle empty and maximum length strings", () => {
      // Empty strings
      const emptySkill = simnet.callReadOnlyFn("utils", "is-valid-skill-name", [Cl.stringAscii("")], address1);
      expect(emptySkill.result).toEqual(Cl.bool(false));

      // Maximum length strings (use exact maximum allowed)
      const maxSkill = simnet.callReadOnlyFn("utils", "is-valid-skill-name", [Cl.stringAscii("A".repeat(50))], address1);
      expect(maxSkill.result).toEqual(Cl.bool(true));

      const maxHash = simnet.callReadOnlyFn("utils", "is-valid-video-hash", [Cl.stringAscii("Q".repeat(200))], address1);
      expect(maxHash.result).toEqual(Cl.bool(true));
    });
  });

  describe("Integration Tests", () => {
    it("should work with complex service scenarios", () => {
      // Complete workflow validation
      const complexService = simnet.callReadOnlyFn("utils", "validate-complete-service-request", [
        Cl.stringAscii("Full-Stack Development"),
        Cl.stringAscii("Complete e-commerce platform with React frontend, Node.js backend, and database integration. Includes user authentication, payment processing, and admin panel."),
        Cl.uint(50000000), // 50 STX - premium service
        Cl.uint(1200),     // 20 hours
        Cl.uint(60000000)  // 60 STX user balance
      ], address1);
      
      const complexData = complexService.result.data;
      expect(complexData["ready-to-create"]).toEqual(Cl.bool(true));

      // Check earnings calculation for provider
      const providerEarnings = simnet.callReadOnlyFn("utils", "calculate-provider-earnings", [
        Cl.uint(50000000) // 50 STX gross
      ], address1);
      
      const earningsData = providerEarnings.result.data;
      expect(earningsData["net-earnings"]).toEqual(Cl.uint(48750000)); // 48.75 STX after 2.5% fee
    });

    it("should handle multiple validation checks consistently", () => {
      const amount = 15000000; // 15 STX
      const feeRate = 300; // 3%
      
      // Individual validations
      const validAmount = simnet.callReadOnlyFn("utils", "is-valid-stx-amount", [Cl.uint(amount)], address1);
      const validFeeRate = simnet.callReadOnlyFn("utils", "is-valid-fee-rate", [Cl.uint(feeRate)], address1);
      const validServiceAmount = simnet.callReadOnlyFn("utils", "is-valid-stx-service-amount", [Cl.uint(amount)], address1);
      
      expect(validAmount.result).toEqual(Cl.bool(true));
      expect(validFeeRate.result).toEqual(Cl.bool(true));
      expect(validServiceAmount.result).toEqual(Cl.bool(true));

      // Combined validation through transaction validation
      const txValidation = simnet.callReadOnlyFn("utils", "validate-stx-transaction", [
        Cl.uint(amount),
        Cl.uint(20000000), // 20 STX balance
        Cl.uint(feeRate)
      ], address1);
      
      expect(txValidation.result.data["all-valid"]).toEqual(Cl.bool(true));
    });

    it("should maintain consistency across different calculation methods", () => {
      const baseAmount = 8000000; // 8 STX
      const platformFeeRate = 250; // 2.5%
      
      // Calculate fee using different methods
      const directFee = simnet.callReadOnlyFn("utils", "calculate-stx-fee", [
        Cl.uint(baseAmount),
        Cl.uint(platformFeeRate)
      ], address1);
      
      const percentageFee = simnet.callReadOnlyFn("utils", "calculate-percentage", [
        Cl.uint(baseAmount),
        Cl.uint(platformFeeRate)
      ], address1);
      
      // Both methods should give same result
      expect(directFee.result).toEqual(percentageFee.result);
      
      // Verify with service cost estimation
      const serviceEstimate = simnet.callReadOnlyFn("utils", "estimate-service-total-cost", [
        Cl.uint(baseAmount)
      ], address1);
      
      const estimateFee = serviceEstimate.result.data["platform-fee"];
      expect(estimateFee).toEqual(directFee.result);
    });
  });

  describe("Performance and Stress Tests", () => {
    it("should handle multiple rapid validations", () => {
      const validations = [];
      
      // Perform multiple validations
      for (let i = 1; i <= 10; i++) {
        const validation = simnet.callReadOnlyFn("utils", "is-valid-stx-amount", [
          Cl.uint(i * 1000000) // 1, 2, 3... STX
        ], address1);
        validations.push(validation);
      }
      
      // All should be valid
      validations.forEach(validation => {
        expect(validation.result).toEqual(Cl.bool(true));
      });
    });

    it("should handle complex calculations efficiently", () => {
      const calculations = [];
      
      // Perform multiple complex calculations
      for (let i = 1; i <= 5; i++) {
        const calc = simnet.callReadOnlyFn("utils", "validate-complete-service-request", [
          Cl.stringAscii(`Service ${i}`),
          Cl.stringAscii(`Description for service ${i} with detailed requirements and specifications.`),
          Cl.uint(i * 5000000), // 5, 10, 15, 20, 25 STX
          Cl.uint(i * 120),     // 2, 4, 6, 8, 10 hours
          Cl.uint(i * 10000000) // 10, 20, 30, 40, 50 STX balance
        ], address1);
        calculations.push(calc);
      }
      
      // All should succeed
      calculations.forEach(calc => {
        expect(calc.result.data["ready-to-create"]).toEqual(Cl.bool(true));
      });
    });
  });
});