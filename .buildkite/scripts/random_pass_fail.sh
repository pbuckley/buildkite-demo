#!/usr/bin/env bash

# exit 0 on an even random number, exit 1 otherwise

if [[ $(( $RANDOM  % 2)) -eq 0 ]]; then
    echo "SUCCESS!"
    buildkite-agent annotate --style "success" --context "${BUILDKITE_STEP_ID}" "key: ${BUILDKITE_STEP_KEY} id: ${BUILDKITE_STEP_ID} :shipit:"
    exit 0
fi

echo "FAILURE!"
buildkite-agent annotate --style "error" --context "${BUILDKITE_STEP_ID}" "key: ${BUILDKITE_STEP_KEY} id: ${BUILDKITE_STEP_ID} :bk-status-failed: :whale:"
exit 1
