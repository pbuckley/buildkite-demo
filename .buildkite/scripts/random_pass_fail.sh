#!/usr/bin/env bash

# so the current problem is that STEP_ID is the same for all my steps, even though it shouldn't be

export my_rand_seed=$RANDOM

export CONTEXTIBOO="ctx-${BUILDKITE_STEP_ID}-${my_rand_seed}"

echo "Context: ${CONTEXTIBOO}"
echo "STEP_KEY: ${BUILDKITE_STEP_KEY}"
echo "STEP_ID: ${BUILDKITE_STEP_ID}"
echo "JOB_ID: ${BUILDKITE_JOB_ID}"
echo "NUM SHARDS IN BUILD.ENV: ${1}"

# exit 0 on an even random number, exit 1 otherwise

if [[ $(( ${my_rand_seed}  % 2)) -eq 0 ]]; then
    echo "SUCCESS!"
    buildkite-agent annotate --style "success" --context "${CONTEXTIBOO}" "step_id: ${BUILDKITE_STEP_ID} job_id: ${BUILDKITE_JOB_ID} :shipit:"
    exit 0
fi

# what if I just "built" (put) the html I need here to get a retry button? Can I do that? Or just a <a href...> kind of link, can I do that?
# [foo]: /url "https://buildkite.com/demo/foo"
# per https://spec.commonmark.org/dingus/?text=%5Bfoo%5D%3A%20%2Furl%20%22title%22%0A%0A%5Bfoo%5D%0A
# and https://buildkite.com/docs/agent/v3/cli-annotate#main
echo "FAILURE!"
# buildkite-agent annotate --style "error" --context "${CONTEXTIBOO}" ":bk-status-failed: :whale: curl -H \"Authorization: Bearer \${BK_REST_API_TOKEN}\" -X PUT \"https://api.buildkite.com/v2/organizations/${BUILDKITE_ORGANIZATION_SLUG}/pipelines/${BUILDKITE_PIPELINE_SLUG}/builds/${BUILDKITE_BUILD_NUMBER}/jobs/${BUILDKITE_JOB_ID}/retry\""
buildkite-agent annotate --style "error" --context "${CONTEXTIBOO}" "<div class=\"build-details-pipeline-job-body__actions order-1 flex items-center\"><a href=\"/organizations/${BUILDKITE_ORGANIZATION_SLUG}/pipelines/${BUILDKITE_PIPELINE_SLUG}/builds/${BUILDKITE_BUILD_NUMBER}/jobs/${BUILDKITE_JOB_ID}/retry\" data-method=\"post\" data-remote=\"true\" rel=\"nofollow\" class=\"btn btn-default\" style=\"font-size: 13px; height: 34px; line-height: 13px;\"><svg viewBox=\"0 0 22 22\" width=\"22px\" height=\"22px\" style=\"fill: currentcolor; vertical-align: middle; width: 14px; height: 14px; position: relative; top: -1px; margin-right: 3px;\"><path d=\"M4.03430208,3.3796857 C5.27079657,2.75120158 6.65863635,2.40936572 8.10132276,2.40936572 C13.0159264,2.40936572 17,6.34716333 17,11.2046829 C17,16.0622024 13.0159264,20 8.10132276,20 C5.51529425,20 3.10549271,18.901651 1.42770162,17.0228056 C0.885675327,16.4158268 0.944112199,15.4894779 1.558224,14.9537473 C2.17233589,14.4180169 3.10957097,14.475775 3.65159726,15.0827537 C4.77210276,16.3375325 6.37526376,17.0682276 8.10132276,17.0682276 C11.3777252,17.0682276 14.0337743,14.4430292 14.0337743,11.2046829 C14.0337743,7.9663365 11.3777252,5.3411381 8.10132276,5.3411381 C7.08235065,5.3411381 6.10620958,5.59579155 5.24691615,6.06259004 L6.92877639,6.60271215 C7.70778736,6.8528882 8.13410949,7.67987391 7.88099351,8.44983649 C7.62787746,9.21979908 6.79117317,9.64116938 6.0121622,9.3909934 L1.02520622,7.78945403 C0.246195246,7.53927798 -0.180126885,6.7122922 0.072989167,5.94232961 L1.69334938,1.01329822 C1.94646536,0.243335633 2.78316964,-0.178034671 3.56218061,0.0721413817 C4.34119158,0.322317361 4.76751371,1.14930314 4.51439773,1.91926572 L4.03430208,3.3796857 Z\" transform=\"translate(8.500000, 10.000000) scale(-1, 1) translate(-8.500000, -10.000000) \"></path></svg>Retry</a></div>"
exit 1
