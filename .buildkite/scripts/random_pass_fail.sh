#!/usr/bin/env bash

# so the current problem is that STEP_ID is the same for all my steps, even though it shouldn't be

export my_rand_seed=$RANDOM

export CONTEXTIBOO="ctx-${BUILDKITE_STEP_ID}-${my_rand_seed}"

echo "Context: ${CONTEXTIBOO}"
echo "STEP_KEY: ${BUILDKITE_STEP_KEY}"
echo "STEP_ID: ${BUILDKITE_STEP_ID}"
echo "NUM SHARDS IN BUILD.ENV: ${1}"

# exit 0 on an even random number, exit 1 otherwise

if [[ $(( ${my_rand_seed}  % 2)) -eq 0 ]]; then
    echo "SUCCESS!"
    buildkite-agent annotate --style "success" --context "${CONTEXTIBOO}" "key: ${BUILDKITE_STEP_KEY} id: ${BUILDKITE_STEP_ID} :shipit:"
    exit 0
fi

echo "FAILURE!"
buildkite-agent annotate --style "error" --context "${CONTEXTIBOO}" "key: ${BUILDKITE_STEP_KEY} id: ${BUILDKITE_STEP_ID} :bk-status-failed: :whale:"
exit 1

