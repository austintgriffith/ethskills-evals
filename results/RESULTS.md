# ethskills-evals Results

## Run: 2026-03-10 — Gas Skill

First eval run testing the `gas` skill against two models.

### Setup
- **Skill tested:** `gas` (10 evals)
- **Skill URL:** https://ethskills.com/gas/SKILL.md
- **Judge model:** GPT-5.2
- **A/B test:** Each prompt run with skill loaded AND without (bare model baseline)

### Results: With Skill Loaded

| Eval ID | What it tests | Opus 4.6 | GPT-5.4 |
|---------|---------------|----------|---------|
| gas-base-fee | Knows base fee is under 1 gwei | ✅ PASS | ✅ PASS |
| gas-eth-transfer-cost | ETH transfer costs under $0.01 | ✅ PASS | ✅ PASS |
| gas-swap-cost-mainnet | Uniswap swap ~$0.03-0.04 | ✅ PASS | ✅ PASS |
| gas-l2-costs | Base L2 swap $0.002-0.003 | ✅ PASS | ✅ PASS |
| gas-ethereum-expensive-myth | Corrects "Ethereum is expensive" | ✅ PASS | ✅ PASS |
| gas-why-dropped | EIP-4844, Pectra, Fusaka | ✅ PASS | ✅ PASS |
| gas-erc20-deploy | ERC-20 deploy ~$0.24 | ✅ PASS | ⚠️ PARTIAL |
| gas-mainnet-vs-l2 | When to use mainnet vs L2 | ✅ PASS | ✅ PASS |
| gas-fee-settings | Correct maxFeePerGas settings | ✅ PASS | ✅ PASS |
| gas-gas-limit-post-fusaka | Gas limit 60M after Fusaka | ✅ PASS | ⚠️ PARTIAL |
| **Pass rate** | | **100%** | **80%** |

### Results: Without Skill (Bare Model Baseline)

| Eval ID | Opus 4.6 | GPT-5.4 |
|---------|----------|---------|
| gas-base-fee | ❌ FAIL | ❌ FAIL |
| gas-eth-transfer-cost | ❌ FAIL | ⚠️ PARTIAL |
| gas-swap-cost-mainnet | ❌ FAIL | ❌ FAIL |
| gas-l2-costs | ⚠️ PARTIAL | ⚠️ PARTIAL |
| gas-ethereum-expensive-myth | ❌ FAIL | ❌ FAIL |
| gas-why-dropped | ⚠️ PARTIAL | ⚠️ PARTIAL |
| gas-erc20-deploy | ❌ FAIL | ❌ FAIL |
| gas-mainnet-vs-l2 | ⚠️ PARTIAL | ⚠️ PARTIAL |
| gas-fee-settings | ❌ FAIL | ❌ FAIL |
| gas-gas-limit-post-fusaka | ❌ FAIL | ❌ FAIL |
| **Pass rate** | **0%** | **0%** |

### Key Findings

**1. The gas skill provides massive uplift.**
Both models go from 0% pass rate to 80-100% pass rate when the skill is loaded. Neither model can pass a single gas eval on its own — their training data is fundamentally stale on Ethereum gas costs.

**2. No model has absorbed this knowledge yet.**
Even GPT-5.4 (the newest model tested) fails every gas eval without the skill. The skill is far from ready for deprecation.

**3. GPT-5.4 baseline is slightly better than Opus 4.6 baseline.**
GPT-5.4 scores 5 PARTIAL vs Opus's 3 PARTIAL without the skill — it has slightly newer training data and hedges more carefully. But "slightly less wrong" still means wrong.

**4. Opus 4.6 uses the skill more effectively than GPT-5.4.**
With the skill loaded, Opus hits 100% while GPT-5.4 gets 80%. GPT-5.4 got PARTIAL on two evals (ERC-20 deploy cost, Fusaka gas limit) where the answers were in the skill doc. This suggests Opus is better at extracting and applying specific facts from reference material.

**5. The biggest uplift areas (all models FAIL without skill):**
- Base fee magnitude (models say 10-30 gwei, reality is 0.1-0.5)
- "Ethereum is expensive" myth (models agree with it)
- Correct fee settings (models recommend 20+ gwei maxFeePerGas)
- Fusaka gas limit increase (models don't know about it)
- ERC-20 deploy cost (models say $200+, reality is $0.24)

### Uplift Summary

| Metric | Opus 4.6 | GPT-5.4 |
|--------|----------|---------|
| With skill | 100% pass | 80% pass |
| Without skill | 0% pass | 0% pass |
| **Uplift** | **+100%** | **+80%** |
