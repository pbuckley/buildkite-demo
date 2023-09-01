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
    buildkite-agent annotate --style "success" --context "${CONTEXTIBOO}" "step_id: ${BUILDKITE_STEP_ID} job_id: ${BUILDKITE_JOB_ID} :shipit:"
    exit 0
fi

echo "FAILURE!"
buildkite-agent annotate --style "error" --context "${CONTEXTIBOO}" ":bk-status-failed: :whale: curl -H "Authorization: Bearer ${BK_REST_API_TOKEN}" -X PUT "https://api.buildkite.com/v2/organizations/${BUILDKITE_ORGANIZATION_SLUG}/pipelines/${BUILDKITE_PIPELINE_SLUG}/builds/${BUILDKITE_BUILD_NUMBER}/jobs/${BUILDKITE_JOB_ID}/retry""
exit 1

