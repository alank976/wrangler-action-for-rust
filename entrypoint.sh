#!/bin/bash

set -e

export HOME="/github/workspace"
export WRANGLER_HOME="/github/workspace"

mkdir -p "$HOME/.wrangler"
chmod -R 770 "$HOME/.wrangler"


# Used to execute any specified pre and post commands
execute_commands() {
  COMMANDS=$1
  while IFS= read -r COMMAND; do
    CHUNKS=()

    for CHUNK in $COMMAND; do
      CHUNKS+=("$CHUNK")
    done

    eval "${CHUNKS[@]}"

    CHUNKS=()
  done <<< "$COMMANDS"
}

secret_not_found() {
  echo "::error::Specified secret \"$1\" not found in environment variables."
  exit 1
}

# If an API token is detected as input
if [ -n "$INPUT_APITOKEN" ]
then
  export CF_API_TOKEN="$INPUT_APITOKEN"
fi

# If a Wrangler version is detected as input
if [ -z "$INPUT_WRANGLERVERSION" ]
then
  cargo install wrangler
else
  cargo install --version $INPUT_WRANGLERVERSION wrangler
fi

# If a working directory is detected as input
if [ -n "$INPUT_WORKINGDIRECTORY" ]
then
  cd "$INPUT_WORKINGDIRECTORY"
fi

# If precommands is detected as input
if [ -n "$INPUT_PRECOMMANDS" ]
then
  execute_commands "$INPUT_PRECOMMANDS"
fi

# If an environment is detected as input, for each secret specified get the value of
# the matching named environment variable then configure using wrangler secret put.
# Skip if publish is set to false.
if [ "$INPUT_PUBLISH" != "false" ]
then
  if [ -z "$INPUT_ENVIRONMENT" ]
  then
    wrangler publish

    for SECRET in $INPUT_SECRETS; do
      VALUE=$(printenv "$SECRET") || secret_not_found "$SECRET"
      echo "$VALUE" | wrangler secret put "$SECRET"
    done
  else
    wrangler publish -e "$INPUT_ENVIRONMENT"

    for SECRET in $INPUT_SECRETS; do
      VALUE=$(printenv "$SECRET") || secret_not_found "$SECRET"
      echo "$VALUE" | wrangler secret put "$SECRET" --env "$INPUT_ENVIRONMENT"
    done
  fi
fi

# If postcommands is detected as input
if [ -n "$INPUT_POSTCOMMANDS" ]
then
  execute_commands "$INPUT_POSTCOMMANDS"
fi

# If a working directory is detected as input, revert to the
# original directory before continuing with the workflow
if [ -n "$INPUT_WORKINGDIRECTORY" ]
then
  cd $HOME
fi