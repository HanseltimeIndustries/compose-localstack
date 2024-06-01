#!/usr/bin/expect

# This expect script is used to automate the confirmation of aws-nuke
# We do this because we are only running against localstack

set CONFIG_LOCATION [lindex $argv 0]
set ACCT_ALIAS [lindex $argv 1]

spawn aws-nuke -c $CONFIG_LOCATION --no-dry-run

expect {
  "Enter account alias to continue.\r" {
    send -- "${ACCT_ALIAS}\r"
    exp_continue
  }
  "No resource to delete.\r" {}
  eof {}
}