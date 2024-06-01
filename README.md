# Base Localstack repository

This repo is set up to emulate an opinionated way of configuring localstack so that you can clean and commit base values
in your aws environment for running.

Examples of where this might be useful:

* You are designing an application that relies on secrets set up by your DevOps team in separate repos
* You are trying to run integration tests against docker-compose of an int-test profile and need things cleaned

# Baseline technologies

* docker-compose >= 3.9
* localstack 
  * Configured for no accounts, but you can modify if you want remote/pro configurations
* aws-nuke
  * Used for cleaning your localstack environment on reinitialization
* aws-cli
  * Use for connecting and populating 
* expect
  * For automating aws-nuke against your localstack within docker

# Examining docker-compose

Docker compose is used as the orchestrator of stages for initializing your localstack.  It makes heavy use of the `depends_on`
field to ensure things are brought up in a deterministic way.

1. localstack - bring up and wait until healthy
2. locakstack-init - runs shell script that 
   1. cleans the localstack account according to your [localstack-nuke-config](./dev/config/localstack-nuke-config.yaml)
   2. runs aws cli commands to populate the localstack
3. "dependent service" - you can add your applications as `depends_on` localstack-init 

## localstack

Given that we want to use our localstack-init to clean and populate our localstack, the localstack configuration in our 
[compose file](./dev/compose.yml) is a variant of the [recommended setup](https://docs.localstack.cloud/getting-started/installation/).
The only difference is that we do not mount a volume since we are avoiding persisting the localstack data.  You may choose to
update the mounts.

You may also choose to reconfigure localstack for pro/remove accounts.

## localstack-init

The main customization of this setup is the init container that runs after localstack is healthy.  The docker image calls the 
[localstack.sh](./dev/bin/localstack.sh) which:

### 1. Adds an account alias if it doesn't exist

This is necessary for aws-nuke to work against the localstack

### 2. Runs aws-nuke via expect automation

Since aws-nuke has many manual safe gaurds (and it should), we use expect to run aws-nuke against the localstack container. This makes
use of the [aws-nuke config file](./dev/config/localstack-nuke-config.yaml), which you may customize to determine exactly which resources
to delete.

**Note:** We recommend setting the particular resources to delete in your config file since there are plenty of localstack endpoints
that will fail and take much longer because the functionality is not implemented.

### 3. Runs your own aws cli commands

You are meant to update the [localstakh.sh file](./dev/bin/localstack.sh) so that you run aws cli calls to initialize your localstack to 
particular values.  This will involve running the aws cli commands that you would normally - the aws cli is already set up with the correct
AWS_ENDPOINT_URL.


## Adding your own dependent services

You can add your applications that depend on localstack by using the `depends_on` field as well.  We leave a commmented out example
configuration in the compose file as an example.


# Calling Scripts

We use a `dev/` folder to help in isolating other functions that you might put into this repo.  For instance, if you were setting up a package with
its own Dockerfile for building the real application, etc.  the dev folder can be seen as a collection of development only resources.

Feel free to adopt the following scripts to and folder structure to your desired repo boilerplate.

## Starting up all services

```shell
docker-compose -f ./dev/compose.yaml up
```

## Bringing down all services

```shell
docker-compose -f ./dev/compose.yaml down
```

## Running after making changes to your localstack-init files

```shell
docker-compose -f ./dev/compose.yaml up --build localstack-init
```