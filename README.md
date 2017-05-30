# mitchese/gitlab-ci-multi-runner-docker:1.1.4-7

- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
  - [Changelog](Changelog.md)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Command-line arguments](#command-line-arguments)
  - [Persistence](#persistence)
  - [Deploy Keys](#deploy-keys)
  - [Trusting SSL Server Certificates](#trusting-ssl-server-certificates)
- [Maintenance](#maintenance)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)
- [List of runners using this image](#list-of-runners-using-this-image)

# Introduction

This is a clone of sameersbn's excellent gitlab-ci-multirunner, but with additional binaries included to allow building of Docker containers from gitlab-ci.

I use this with my Gitlab-CI to build containers for my continuous integration pipeline. For additional information see  [gitlab-ci-multi-runner](https://gitlab.com/gitlab-org/gitlab-ci-multi-runner) and [my blog post](https://www.muzik.ca/2017/05/10/building-whalesay-with-docker-and-gitlab-ci/).

## Issues

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.
- Please state if you are using [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), etc.

# Getting started

## Installation

A finished image of this is available on [Dockerhub](https://hub.docker.com/r/mitchese/gitlab-ci-multi-runner-docker) and is the recommended method of installation.

```bash
docker pull mitchese/gitlab-ci-multi-runner-docker:latest
```

Alternatively you can build the image yourself.

```bash
docker build -t mitchese/gitlab-ci-multi-runner-docker github.com/mitchese/docker-gitlab-ci-multi-runner-docker
```

## Quickstart

Before a runner can process your CI jobs, it needs to be authorized to access the the GitLab CI server. The `CI_SERVER_URL`, `RUNNER_TOKEN`, `RUNNER_DESCRIPTION` and `RUNNER_EXECUTOR` environment variables are used to register the runner on GitLab CI.

```bash
docker run --name gitlab-ci-multi-runner-docker -d --restart=always \
  --volume /srv/docker/gitlab-runner:/home/gitlab_ci_multi_runner/data \
  --env='CI_SERVER_URL=http://git.muzik.ca/ci' --env='RUNNER_TOKEN=xxxxxxxxx' \
  --env='RUNNER_DESCRIPTION=dockerrunner' --env='RUNNER_EXECUTOR=shell' \
  mitchese/gitlab-ci-multi-runner-docker:latest
```
Update the values of `CI_SERVER_URL`, `RUNNER_TOKEN` and `RUNNER_DESCRIPTION` in the above command. If these enviroment variables are not specified, you will be prompted to enter these details interactively on first run.

## Command-line arguments

You can customize the launch command by specifying arguments to `gitlab-ci-multi-runner` on the `docker run` command. For example the following command prints the help menu of `gitlab-ci-multi-runner` command:

```bash
docker run --name gitlab-ci-multi-runner-docker -it --rm \
  --volume /srv/docker/gitlab-runner:/home/gitlab_ci_multi_runner/data \
  mitchese/gitlab-ci-multi-runner-docker:latest --help
```

## Persistence

For the image to preserve its state across container shutdown and startup you should mount a volume at `/home/gitlab_ci_multi_runner/data`.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

SELinux users should update the security context of the host mountpoint so that it plays nicely with Docker:

```bash
mkdir -p /srv/docker/gitlab-runner
chcon -Rt svirt_sandbox_file_t /srv/docker/gitlab-runner
```

## Deploy Keys

At first run the image automatically generates SSH deploy keys which are installed at `/home/gitlab_ci_multi_runner/data/.ssh` of the persistent data store. You can replace these keys with your own if you wish to do so.

You can use these keys to allow the runner to gain access to your private git repositories over the SSH protocol.

> **NOTE**
>
> - The deploy keys are generated without a passphrase.
> - If your CI jobs clone repositories over SSH, you will need to build the ssh known hosts file which can be done in the build steps using, for example, `ssh-keyscan github.com | sort -u - ~/.ssh/known_hosts -o ~/.ssh/known_hosts`.

## Trusting SSL Server Certificates

If your GitLab server is using self-signed SSL certificates then you should make sure the GitLab server's SSL certificate is trusted on the runner for the git clone operations to work.

The runner is configured to look for trusted SSL certificates at `/home/gitlab_ci_multi_runner/data/certs/ca.crt`. This path can be changed using the `CA_CERTIFICATES_PATH` enviroment variable.

Create a file named `ca.crt` in a `certs` folder at the root of your persistent data volume. The `ca.crt` file should contain the root certificates of all the servers you want to trust.

With respect to GitLab, append the contents of the `gitlab.crt` file to `ca.crt`. For more information on the `gitlab.crt` file please refer the [README](https://github.com/sameersbn/docker-gitlab/blob/master/README.md#ssl) of the [docker-gitlab](https://github.com/sameersbn/docker-gitlab) container.

Similarly you should also trust the SSL certificate of the GitLab CI server by appending the contents of the `gitlab-ci.crt` file to `ca.crt`.

# Maintenance

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull mitchese/gitlab-ci-multi-runner-docker:latest
  ```

  2. Stop the currently running image:

  ```bash
  docker stop gitlab-ci-multi-runner-docker
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v gitlab-ci-multi-runner-docker
  ```

  4. Start the updated image

  ```bash
  docker run -name gitlab-ci-multi-runner-docker -d \
    [OPTIONS] \
    mitchese/gitlab-ci-multi-runner-docker:latest
  ```
