#!/bin/bash

decision_steps=$(cat <<EOF
  - block: ":thinking_face: What now?"
    prompt: "Choose the next set of steps to be dynamically generated"
    fields:
      - select: "Choices"
        key: "choice"
        options:
          - label: "Randomly pass/fail a bunch of times in parallel :copybara:"
            value: "pass-fail"
          - label: "Retry Failed Steps ONLY"
            value: "retry-failed-only"
          - label: "Finish the build green"
            value: "build-pass"
          - label: "Finish the build red"
            value: "build-fail"
  - label: "Process input"
    command: ".buildkite/generate_steps.sh"
EOF
)

wait_step=$(cat <<EOF
  - wait
EOF
)

# this bit is an ugly hack to avoid checking metadata on first run of the script
current_state=""
first_step_label=":pipeline: Upload Dynamic Pipeline"
if [ "$BUILDKITE_LABEL" != "$first_step_label" ]; then
  current_state=$(buildkite-agent meta-data get "choice")
else
  printf "steps:\n"
  printf "%s\n" "$decision_steps"
  exit 0
fi

new_yaml=""
case $current_state in
  pass-fail)
    action_step=$(cat <<EOF
  - label: ":zap: Shard %N of %t"
    key: "shard-%N"
    command: "bash .buildkite/scripts/random_pass_fail.sh $SHARDS"
    parallelism: 5
EOF
)
    new_yaml=$(printf "%s\n%s\n%s" "$action_step" "$wait_step" "$decision_steps")
  ;;

  retry-failed-only)
    action_step=$(cat <<EOF
  - label: ":bk-status-pending: Retry only your failed steps? :magic_wand:"
    command: "echo 'Exiting build with status 0' && exit 0"
EOF
)
    new_yaml=$(printf "%s\n" "$action_step")
  ;;

  build-pass)
    action_step=$(cat <<EOF
  - label: ":thumbsup: Passing build"
    command: "echo 'Exiting build with status 0' && exit 0"
EOF
)
    new_yaml=$(printf "%s\n" "$action_step")
  ;;

  build-fail)
    action_step=$(cat <<EOF
  - label: ":thumbsdown: Failing build"
    command: "echo 'Exiting build with status 1' && exit 1"
EOF
)
    new_yaml=$(printf "%s\n" "$action_step")
  ;;
esac

printf "%s\n" "$new_yaml" | buildkite-agent pipeline upload
#printf "%s\n" "$new_yaml"
