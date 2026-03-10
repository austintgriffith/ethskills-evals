# ethskills-evals Results

## Full Suite Run: 2026-03-10

64 evals across 8 skills. Two models tested with and without skill docs loaded.

### Setup
- **Models tested:** Claude Opus 4.6 (via Venice), GPT-5.4 (OpenAI)
- **Judge model:** GPT-5.2
- **Evals:** 64 total across 8 skills
- **A/B test:** Every prompt run twice — with skill loaded and bare model baseline

---

## Summary

| | Opus 4.6 | GPT-5.4 |
|---|---|---|
| **With skill** | **95%** (61 pass, 1 partial, 2 fail) | **82%** (53 pass, 9 partial, 2 fail) |
| **Without skill** | **33%** (21 pass, 18 partial, 25 fail) | **16%** (10 pass, 22 partial, 32 fail) |
| **Uplift** | **+62%** | **+66%** |

---

## Results by Skill

### Gas (10 evals) — ⭐ Highest-value skill

| Eval | Opus w/ | Opus w/o | GPT-5.4 w/ | GPT-5.4 w/o |
|------|---------|----------|------------|-------------|
| gas-base-fee | ✅ | ❌ | ✅ | ❌ |
| gas-eth-transfer-cost | ✅ | ⚠️ | ✅ | ❌ |
| gas-swap-cost-mainnet | ✅ | ❌ | ✅ | ❌ |
| gas-l2-costs | ✅ | ❌ | ✅ | ⚠️ |
| gas-ethereum-expensive-myth | ✅ | ❌ | ✅ | ❌ |
| gas-why-dropped | ✅ | ⚠️ | ✅ | ⚠️ |
| gas-erc20-deploy | ✅ | ❌ | ⚠️ | ❌ |
| gas-mainnet-vs-l2 | ✅ | ❌ | ✅ | ❌ |
| gas-fee-settings | ✅ | ❌ | ✅ | ❌ |
| gas-gas-limit-post-fusaka | ✅ | ❌ | ⚠️ | ❌ |
| **Pass rate** | **100%** | **0%** | **80%** | **0%** |

Both models score **0% without the skill**. They confidently state gas is 10-30 gwei, transfers cost dollars, and Ethereum is too expensive. All wrong. This skill alone justifies ethskills existing.

### L2s (11 evals) — High value

| Eval | Opus w/ | Opus w/o | GPT-5.4 w/ | GPT-5.4 w/o |
|------|---------|----------|------------|-------------|
| l2s-dominant-dex-base | ✅ | ✅ | ✅ | ⚠️ |
| l2s-dominant-dex-optimism | ✅ | ❌ | ✅ | ⚠️ |
| l2s-dominant-dex-arbitrum | ✅ | ❌ | ✅ | ❌ |
| l2s-polygon-zkevm | ✅ | ❌ | ✅ | ❌ |
| l2s-celo-status | ✅ | ⚠️ | ⚠️ | ❌ |
| l2s-unichain | ✅ | ⚠️ | ✅ | ❌ |
| l2s-cheapest-l2 | ✅ | ⚠️ | ✅ | ⚠️ |
| l2s-base-vs-arbitrum | ✅ | ✅ | ✅ | ✅ |
| l2s-aero-merger | ✅ | ❌ | ✅ | ❌ |
| l2s-ai-agent-chain | ✅ | ⚠️ | ✅ | ❌ |
| l2s-zk-vs-optimistic-finality | ✅ | ⚠️ | ✅ | ✅ |
| **Pass rate** | **100%** | **18%** | **91%** | **9%** |

The Aero merger, Polygon zkEVM shutdown, and Celo migration are invisible to both models without the skill.

### Standards (8 evals) — High value (new standards)

| Eval | Opus w/ | Opus w/o | GPT-5.4 w/ | GPT-5.4 w/o |
|------|---------|----------|------------|-------------|
| std-erc8004-exists | ✅ | ❌ | ✅ | ❌ |
| std-erc8004-addresses | ✅ | ❌ | ✅ | ❌ |
| std-eip7702 | ✅ | ✅ | ✅ | ✅ |
| std-x402 | ✅ | ⚠️ | ✅ | ❌ |
| std-x402-flow | ✅ | ✅ | ✅ | ❌ |
| std-eip3009 | ✅ | ⚠️ | ✅ | ⚠️ |
| std-agent-economy | ✅ | ❌ | ✅ | ⚠️ |
| std-erc4337-entrypoint | ✅ | ✅ | ✅ | ✅ |
| **Pass rate** | **100%** | **38%** | **100%** | **25%** |

ERC-8004 and x402 are completely unknown to both models. EIP-7702 and ERC-4337 are absorbed.

### Why Ethereum (7 evals) — High value

| Eval | Opus w/ | Opus w/o | GPT-5.4 w/ | GPT-5.4 w/o |
|------|---------|----------|------------|-------------|
| why-gas-correction | ✅ | ⚠️ | ✅ | ❌ |
| why-pectra | ✅ | ⚠️ | ✅ | ❌ |
| why-fusaka | ✅ | ❌ | ✅ | ❌ |
| why-glamsterdam | ✅ | ❌ | ✅ | ⚠️ |
| why-onchain-spelling | ✅ | ❌ | ✅ | ❌ |
| why-eth-price | ✅ | ❌ | ✅ | ❌ |
| why-agent-infra | ✅ | ❌ | ✅ | ❌ |
| **Pass rate** | **100%** | **0%** | **100%** | **0%** |

Another 0% baseline for both. Fusaka, Glamsterdam, current ETH price, "onchain" spelling — all unknown.

### Concepts (6 evals) — Medium value

| Eval | Opus w/ | Opus w/o | GPT-5.4 w/ | GPT-5.4 w/o |
|------|---------|----------|------------|-------------|
| concepts-nothing-automatic | ✅ | ⚠️ | ✅ | ⚠️ |
| concepts-state-machine | ✅ | ✅ | ✅ | ✅ |
| concepts-three-questions | ✅ | ⚠️ | ✅ | ❌ |
| concepts-incentive-design | ✅ | ✅ | ✅ | ✅ |
| concepts-crops | ✅ | ❌ | ⚠️ | ❌ |
| concepts-walk-away-test | ✅ | ⚠️ | ✅ | ⚠️ |
| **Pass rate** | **100%** | **33%** | **83%** | **33%** |

Models understand state machines and incentive design already. CROPS and the three questions need the skill.

### Wallets (6 evals) — Medium-high value

| Eval | Opus w/ | Opus w/o | GPT-5.4 w/ | GPT-5.4 w/o |
|------|---------|----------|------------|-------------|
| wallets-eip7702-status | ✅ | ✅ | ✅ | ⚠️ |
| wallets-safe-tvl | ✅ | ⚠️ | ⚠️ | ⚠️ |
| wallets-safe-addresses | ✅ | ✅ | ✅ | ❌ |
| wallets-agent-safe-pattern | ✅ | ❌ | ✅ | ❌ |
| wallets-never-commit-keys | ✅ | ❌ | ⚠️ | ❌ |
| wallets-erc4337-status | ✅ | ❌ | ✅ | ❌ |
| **Pass rate** | **100%** | **33%** | **67%** | **0%** |

Agent-specific wallet patterns (1-of-2 Safe, key management) need the skill. EIP-7702 status is partially absorbed.

### Security (10 evals) — ⚠️ Closest to deprecation

| Eval | Opus w/ | Opus w/o | GPT-5.4 w/ | GPT-5.4 w/o |
|------|---------|----------|------------|-------------|
| sec-usdc-decimals | ❌ | ⚠️ | ❌ | ⚠️ |
| sec-token-decimals-table | ✅ | ✅ | ✅ | ✅ |
| sec-safe-erc20 | ✅ | ✅ | ⚠️ | ⚠️ |
| sec-reentrancy | ✅ | ✅ | ✅ | ⚠️ |
| sec-dex-spot-price-oracle | ✅ | ✅ | ✅ | ⚠️ |
| sec-vault-inflation | ✅ | ✅ | ✅ | ⚠️ |
| sec-solidity-division | ✅ | ✅ | ✅ | ⚠️ |
| sec-fee-on-transfer | ✅ | ✅ | ✅ | ✅ |
| sec-infinite-approval | ✅ | ✅ | ✅ | ⚠️ |
| sec-git-secrets | ❌ | ⚠️ | ❌ | ❌ |
| **Pass rate** | **80%** | **80%** | **80%** | **20%** |

Opus passes 8/10 security evals WITHOUT the skill. These patterns (reentrancy, CEI, vault inflation, SafeERC20) are well-documented enough that Opus learned them from training data. GPT-5.4 still needs the skill though — only 20% baseline.

### Building Blocks (6 evals) — Medium value

| Eval | Opus w/ | Opus w/o | GPT-5.4 w/ | GPT-5.4 w/o |
|------|---------|----------|------------|-------------|
| bb-uniswap-v4 | ✅ | ⚠️ | ✅ | ⚠️ |
| bb-v4-poolmanager-address | ✅ | ✅ | ✅ | ✅ |
| bb-dominant-dex-not-uniswap | ⚠️ | ✅ | ⚠️ | ⚠️ |
| bb-aave-v3-address | ✅ | ✅ | ✅ | ✅ |
| bb-flash-loan-cost | ✅ | ❌ | ⚠️ | ❌ |
| bb-hooks-example | ✅ | ✅ | ✅ | ⚠️ |
| **Pass rate** | **83%** | **67%** | **67%** | **33%** |

Protocol addresses are absorbed. Flash loan cost changes and V4 details need the skill.

---

## Key Findings

### 1. Gas is the highest-value skill — 0% → 100% uplift
Both models score 0% on gas without the skill. They confidently state gas is 10-30 gwei, transfers cost dollars, and recommend avoiding mainnet. The gas skill provides the single largest factual correction in ethskills.

### 2. GPT-5.4 has WORSE Ethereum knowledge than Opus 4.6
Only 10/64 baseline passes (16%) vs Opus's 21/64 (33%). The newest OpenAI model knows less about current Ethereum than Claude. Stale training data isn't improving linearly with model releases.

### 3. Security patterns are nearly absorbed into training data
Opus passes 80% of security evals without the skill. Reentrancy, CEI, SafeERC20, vault inflation, division truncation — these are well-documented enough that models learned them. The security skill is closest to deprecation for Opus, but GPT-5.4 still needs it (20% baseline).

### 4. New standards are invisible without the skill
ERC-8004, x402, Aero merger, Celo L2 migration, Polygon zkEVM shutdown, Fusaka, Glamsterdam — both models FAIL all of these without the skill. No model has 2025-2026 Ethereum developments in training data.

### 5. Both models fail the same 2 evals even WITH the skill
`sec-usdc-decimals` and `sec-git-secrets` fail for both models even with reference material loaded. These evals may need criteria adjustment, or the models genuinely struggle to emphasize these warnings strongly enough for the judge.

### 6. Opus extracts reference material more effectively
95% vs 82% with the same skill docs loaded. Opus pulls out specific facts (addresses, numbers, dates) more reliably. GPT-5.4 gives vaguer answers that score PARTIAL where Opus gets PASS.

---

## Skill Value Ranking

Based on uplift (difference between with-skill and without-skill pass rates):

| Rank | Skill | Opus Uplift | GPT-5.4 Uplift | Status |
|------|-------|-------------|----------------|--------|
| 1 | **gas** | 0% → 100% | 0% → 80% | 🔴 Critical — models are totally wrong |
| 2 | **why** | 0% → 100% | 0% → 100% | 🔴 Critical — upgrades, price, infra unknown |
| 3 | **l2s** | 18% → 100% | 9% → 91% | 🔴 High — landscape changes invisible |
| 4 | **standards** | 38% → 100% | 25% → 100% | 🔴 High — new standards unknown |
| 5 | **wallets** | 33% → 100% | 0% → 67% | 🟡 Medium-high |
| 6 | **concepts** | 33% → 100% | 33% → 83% | 🟡 Medium |
| 7 | **building-blocks** | 67% → 83% | 33% → 67% | 🟡 Medium |
| 8 | **security** | 80% → 80% | 20% → 80% | 🟢 Low for Opus, medium for GPT-5.4 |

---

## What This Means for ethskills Strategy

**Keep investing in:** gas, why, l2s, standards — massive uplift, models are totally lost without them.

**Watch for deprecation:** security basics for Opus (already absorbed). But GPT-5.4 still needs it, so don't remove yet.

**Investigate:** The 2 shared failures (USDC decimals, git secrets). Either the eval criteria are too strict or the skill content needs to be more emphatic on these points.

**Next steps:**
- Run against more models (DeepSeek, Llama, Qwen)
- Add evals for remaining skills (indexing, frontend-ux, frontend-playbook, tools, testing, orchestration, qa)
- Set up monthly runs to track model knowledge absorption over time
- Investigate the PARTIAL scores on building-blocks dominant-dex eval — both models struggle with this even with the skill loaded
