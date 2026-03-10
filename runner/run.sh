#!/usr/bin/env bash
set -euo pipefail

# ethskills eval runner
# Usage: ./run.sh [--skill gas] [--model venice/claude-opus-4-6] [--judge openai/gpt-5.2] [--no-baseline]
#
# Requires: curl, jq, yq (https://github.com/mikefarah/yq)
# Environment: OPENAI_API_KEY or VENICE_API_KEY

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EVALS_DIR="$SCRIPT_DIR/../evals"
RESULTS_DIR="$SCRIPT_DIR/../results"
JUDGE_PROMPT="$SCRIPT_DIR/judge.md"

# Defaults
SKILL_FILTER=""
MODEL="venice/claude-opus-4-6"
JUDGE_MODEL="openai/gpt-5.2"
RUN_BASELINE=true
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --skill) SKILL_FILTER="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --judge) JUDGE_MODEL="$2"; shift 2 ;;
    --no-baseline) RUN_BASELINE=false; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# Resolve API endpoint and key based on model prefix
resolve_api() {
  local model="$1"
  local provider="${model%%/*}"
  case "$provider" in
    openai)
      echo "https://api.openai.com/v1/chat/completions"
      ;;
    venice)
      echo "https://api.venice.ai/api/v1/chat/completions"
      ;;
    anthropic)
      echo "https://api.anthropic.com/v1/messages"
      ;;
    *)
      # Default to OpenAI-compatible
      echo "https://api.openai.com/v1/chat/completions"
      ;;
  esac
}

resolve_key() {
  local model="$1"
  local provider="${model%%/*}"
  case "$provider" in
    openai)  echo "${OPENAI_API_KEY:-}" ;;
    venice)  echo "${VENICE_API_KEY:-}" ;;
    anthropic) echo "${ANTHROPIC_API_KEY:-}" ;;
    *)       echo "${OPENAI_API_KEY:-}" ;;
  esac
}

resolve_model_name() {
  local model="$1"
  echo "${model#*/}"
}

# Send a chat completion request (OpenAI-compatible format)
chat_completion() {
  local api_url="$1"
  local api_key="$2"
  local model_name="$3"
  local system_msg="$4"
  local user_msg="$5"

  # Determine correct token limit param based on provider
  local token_param="max_tokens"
  case "$api_url" in
    *openai.com*) token_param="max_completion_tokens" ;;
  esac

  local payload
  payload=$(jq -n \
    --arg model "$model_name" \
    --arg system "$system_msg" \
    --arg user "$user_msg" \
    --arg tp "$token_param" \
    '{
      model: $model,
      messages: [
        {role: "system", content: $system},
        {role: "user", content: $user}
      ],
      temperature: 0.0,
      ($tp): 2000
    }')

  curl -s "$api_url" \
    -H "Authorization: Bearer $api_key" \
    -H "Content-Type: application/json" \
    -d "$payload" | jq -r '.choices[0].message.content // .content[0].text // "ERROR: No response"'
}

echo "╔══════════════════════════════════════╗"
echo "║     ethskills eval runner            ║"
echo "╠══════════════════════════════════════╣"
echo "║ Model:    $MODEL"
echo "║ Judge:    $JUDGE_MODEL"
echo "║ Baseline: $RUN_BASELINE"
echo "║ Time:     $TIMESTAMP"
echo "╚══════════════════════════════════════╝"
echo ""

MODEL_API=$(resolve_api "$MODEL")
MODEL_KEY=$(resolve_key "$MODEL")
MODEL_NAME=$(resolve_model_name "$MODEL")
JUDGE_API=$(resolve_api "$JUDGE_MODEL")
JUDGE_KEY=$(resolve_key "$JUDGE_MODEL")
JUDGE_NAME=$(resolve_model_name "$JUDGE_MODEL")
JUDGE_SYSTEM=$(cat "$JUDGE_PROMPT")

if [[ -z "$MODEL_KEY" ]]; then
  echo "ERROR: No API key found for model $MODEL"
  echo "Set OPENAI_API_KEY, VENICE_API_KEY, or ANTHROPIC_API_KEY"
  exit 1
fi

if [[ -z "$JUDGE_KEY" ]]; then
  echo "ERROR: No API key found for judge model $JUDGE_MODEL"
  exit 1
fi

# Results file
RESULTS_FILE="$RESULTS_DIR/${TIMESTAMP}_${MODEL_NAME//\//_}.json"
echo "[]" > "$RESULTS_FILE"

total=0
pass=0
partial=0
fail=0
errors=0

for eval_file in "$EVALS_DIR"/*.yaml; do
  skill=$(yq '.skill' "$eval_file")

  # Filter if specified
  if [[ -n "$SKILL_FILTER" && "$skill" != "$SKILL_FILTER" ]]; then
    continue
  fi

  skill_url=$(yq '.skill_url' "$eval_file")
  skill_desc=$(yq '.description' "$eval_file")
  num_evals=$(yq '.evals | length' "$eval_file")

  echo "━━━ $skill ($num_evals evals) ━━━"

  # Fetch the skill content
  echo "  Fetching $skill_url..."
  skill_content=$(curl -sL "$skill_url" 2>/dev/null || echo "FETCH_FAILED")

  if [[ "$skill_content" == "FETCH_FAILED" ]]; then
    echo "  ⚠️  Failed to fetch skill. Skipping."
    continue
  fi

  for i in $(seq 0 $((num_evals - 1))); do
    eval_id=$(yq ".evals[$i].id" "$eval_file")
    prompt=$(yq ".evals[$i].prompt" "$eval_file")
    expected_facts=$(yq -o=json ".evals[$i].expected_facts" "$eval_file")
    fail_if=$(yq -o=json ".evals[$i].fail_if" "$eval_file")

    total=$((total + 1))
    echo -n "  [$eval_id] "

    # --- WITH SKILL ---
    system_with_skill="You are a helpful AI assistant. Use the following reference material to answer the question.\n\n--- REFERENCE ---\n$skill_content\n--- END REFERENCE ---"
    response_with=$(chat_completion "$MODEL_API" "$MODEL_KEY" "$MODEL_NAME" "$system_with_skill" "$prompt")

    # --- WITHOUT SKILL (baseline) ---
    response_without=""
    if [[ "$RUN_BASELINE" == true ]]; then
      response_without=$(chat_completion "$MODEL_API" "$MODEL_KEY" "$MODEL_NAME" "You are a helpful AI assistant." "$prompt")
    fi

    # --- JUDGE ---
    judge_input="## Prompt\n$prompt\n\n## Response (WITH skill loaded)\n$response_with\n\n## Expected Facts\n$expected_facts\n\n## Fail Conditions\n$fail_if"

    judge_result=$(chat_completion "$JUDGE_API" "$JUDGE_KEY" "$JUDGE_NAME" "$JUDGE_SYSTEM" "$judge_input")

    # Parse verdict — extract JSON from response (strip markdown fences, find JSON object)
    judge_json=$(echo "$judge_result" | grep -v '^```' | perl -0777 -ne 'print $1 if /(\{.*?"verdict".*?\})/s')
    if [[ -z "$judge_json" ]]; then
      judge_json="$judge_result"
    fi
    verdict=$(echo "$judge_json" | jq -r '.verdict // "ERROR"' 2>/dev/null || echo "ERROR")

    case "$verdict" in
      PASS)    pass=$((pass + 1)); echo "✅ PASS" ;;
      PARTIAL) partial=$((partial + 1)); echo "⚠️  PARTIAL" ;;
      FAIL)    fail=$((fail + 1)); echo "❌ FAIL" ;;
      *)       errors=$((errors + 1)); echo "💥 ERROR (judge parse failed)" ;;
    esac

    # Also judge baseline if we ran it
    baseline_verdict=""
    if [[ "$RUN_BASELINE" == true && -n "$response_without" ]]; then
      baseline_input="## Prompt\n$prompt\n\n## Response (WITHOUT skill — bare model)\n$response_without\n\n## Expected Facts\n$expected_facts\n\n## Fail Conditions\n$fail_if"
      baseline_judge=$(chat_completion "$JUDGE_API" "$JUDGE_KEY" "$JUDGE_NAME" "$JUDGE_SYSTEM" "$baseline_input")
      baseline_json=$(echo "$baseline_judge" | grep -v '^```' | perl -0777 -ne 'print $1 if /(\{.*?"verdict".*?\})/s')
      if [[ -z "$baseline_json" ]]; then baseline_json="$baseline_judge"; fi
      baseline_verdict=$(echo "$baseline_json" | jq -r '.verdict // "ERROR"' 2>/dev/null || echo "ERROR")
      echo "         baseline: $baseline_verdict"
    fi

    # Append to results
    result_entry=$(jq -n \
      --arg skill "$skill" \
      --arg id "$eval_id" \
      --arg prompt "$prompt" \
      --arg verdict "$verdict" \
      --arg baseline "$baseline_verdict" \
      --arg response_with "$response_with" \
      --arg response_without "$response_without" \
      --arg judge "$judge_result" \
      '{
        skill: $skill,
        eval_id: $id,
        prompt: $prompt,
        verdict: $verdict,
        baseline_verdict: $baseline,
        response_with_skill: $response_with,
        response_without_skill: $response_without,
        judge_output: $judge
      }')

    jq ". += [$result_entry]" "$RESULTS_FILE" > "$RESULTS_FILE.tmp" && mv "$RESULTS_FILE.tmp" "$RESULTS_FILE"
  done
  echo ""
done

# Summary
echo "╔══════════════════════════════════════╗"
echo "║           RESULTS SUMMARY            ║"
echo "╠══════════════════════════════════════╣"
echo "║ Total:   $total"
echo "║ ✅ Pass:  $pass"
echo "║ ⚠️  Part:  $partial"
echo "║ ❌ Fail:  $fail"
echo "║ 💥 Error: $errors"
echo "║"
echo "║ Pass rate: $(( (pass * 100) / (total > 0 ? total : 1) ))%"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Results saved to: $RESULTS_FILE"
