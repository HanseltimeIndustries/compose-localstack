#!/bin/sh -e

#####################################################################################
#
# Localstack modification and nuking - does not require changes
#
#####################################################################################

# Ensure we have an account alias for us to nuke
ALIAS=localstack-test
existingAlias=$(aws iam list-account-aliases | grep ${ALIAS} || true)
echo $existingAlias
if [[ -z "$existingAlias" ]]; then
    echo "Setting Account alias since it does not yet exist"
    aws iam create-account-alias --account-alias ${ALIAS}
fi

# Run aws-nuke via expect so that we clear the values
expect /aws-nuke-expect.e /localstack-nuke-config.yaml $ALIAS


#####################################################################################
#
# Place your aws calls here to initiate the expected fake resources
#
#####################################################################################

# Example Secret being created
cat > special-secret.json << EOF
{
  "key": "testKey",
}
EOF
aws secretsmanager create-secret \
    --name /mySecret \
    --description "My Secret that I need" \
    --secret-string file://special-secret.json

