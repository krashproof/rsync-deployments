#!/bin/sh

# Start the SSH agent and load key.
source agent-start "$GITHUB_ACTION"
echo "$INPUT_REMOTE_KEY" | agent-add

# Add strict errors.
set -eu
DEPLOY_BRANCH=$INPUT_DEPLOY_BRANCH

if [ $DEPLOY_BRANCH == "master" ]; then
	INPUT_REMOTE_PATH=$INPUT_PROD_PATH
	echo "On branch master, deploy to path : $INPUT_REMOTE_PATH"
elif [ $DEPLOY_BRANCH == "develop" ]; then
	INPUT_REMOTE_PATH=$INPUT_STAGE_PATH
	echo "On branch develop, deploy to path: $INPUT_REMOTE_PATH"
else
	echo "Invalid DEPLOY_BRANCH name"
	exit 1
fi

# Variables.
SWITCHES="$INPUT_SWITCHES"
RSH="ssh -o StrictHostKeyChecking=no -p $INPUT_REMOTE_PORT $INPUT_RSH"
LOCAL_PATH="$GITHUB_WORKSPACE/$INPUT_PATH"
DSN="$INPUT_REMOTE_USER@$INPUT_REMOTE_HOST"
SSH="ssh -o StrictHostKeyChecking=no -p $INPUT_REMOTE_PORT $DSN"

# Deploy.
sh -c "rsync $SWITCHES -e '$RSH' $LOCAL_PATH $DSN:$INPUT_REMOTE_PATH"

# Post Deploy
if [ $INPUT_POST_DEPLOY_SH ] ; then
	echo $PWD/.github/workflows
	ls -la .github/workflows/$INPUT_POST_DEPLOY_SH
	sh -c ".github/workflows/$INPUT_POST_DEPLOY_SH $DEPLOY_BRANCH"
fi
