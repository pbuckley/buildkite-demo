#!/bin/bash

decision_steps=$(cat <<EOF
  - block: ":thinking_face: What now?"
    prompt: "Choose the next set of steps to be dynamically generated"
    fields:
      - select: "Choices"
        key: "choice"
        options:
          - label: "Display the UnblockConf logo again"
            value: "logo"
          - label: "Randomly pass/fail a bunch of times in parallel"
            value: "pass-fail"
          - label: "Finish the build green"
            value: "build-pass"
          - label: "Finish the build red"
            value: "build-fail"
          - label: "Deploy to us-east-2"
            value: "build-deploy"
          - label: "Create release tag"
            value: "build-tag"
          - label: "Deploy to all envs"
            value: "build-final"
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
first_step_label=":pipeline: Upload Pipeline"
if [ "$BUILDKITE_LABEL" != "$first_step_label" ]; then
  current_state=$(buildkite-agent meta-data get "choice")
else
  printf "steps:\n"
  printf "%s\n" "$decision_steps"
  exit 0
fi

new_yaml=""
case $current_state in
  logo)
    action_step=$(cat <<EOF
  - label: ":buildkite: Display UnblockConf Logo"
    command: "buildkite-agent artifact upload unblock.png && ./log_image.sh artifact://unblock.png"
EOF
)
    new_yaml=$(printf "%s\n%s\n%s" "$action_step" "$wait_step" "$decision_steps")
  ;;

  pass-fail)
    action_step=$(cat <<EOF
  - label: ":zap: Shard %N of %t"
    command: "bash .buildkite/scripts/random_pass_fail.sh"
    parallelism: 5 
EOF
)
    new_yaml=$(printf "%s\n%s\n%s" "$action_step" "$wait_step" "$decision_steps")
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
  build-deploy)
    action_step=$(cat <<EOF
  - label: ":rocket: Deploying to us-east-2"
    command: "echo 'Deploying to us-east-2 ' && exit 0"
EOF
)
  build-tag)
    action_step=$(cat <<EOF
  - label: ":ship: Tagging release"
    command: "echo 'Tagging release' && exit 0"
EOF
)
  build-final)
    action_step=$(cat <<EOF
  - label: ":smile: Finalizing deploy to all envs"
    command: "echo 'Deploying to all environments' && exit 0"
EOF
)
    new_yaml=$(printf "%s\n" "$action_step")
  ;;
esac

printf "%s\n" "$new_yaml" | buildkite-agent pipeline upload
#printf "%s\n" "$new_yaml"
