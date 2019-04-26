---
title: Installing Falco from Source
weight: 6
---

Building falco requires having `cmake` and `g++` installed.

## Build using falco-builder container

One easy way to build falco is to run the [falco-builder](https://hub.docker.com/r/falcosecurity/falco-builder) container. It contains the reference toolchain we use to build packages.

The image depends on the following parameters:

* `FALCO_VERSION`: the version to give any built packages
* `BUILD_TYPE`: Debug or Release
* `BUILD_DRIVER`: whether or not to build the kernel module when
building. This should usually be OFF, as the kernel module would be
built for the files in the centos image, not the host.
* `BUILD_BPF`: Like `BUILD_DRIVER` but for the ebpf program.
* `BUILD_WARNINGS_AS_ERRORS`: consider all build warnings fatal
* `MAKE_JOBS`: passed to the -j argument of make

A typical way to run this builder is the following. Assuming you have
checked out falco and sysdig to directories below /home/user/src, and
want to use a build directory of /home/user/build/falco, you would run
the following:

```bash
FALCO_VERSION=0.1.2-test docker run --user $(id -u):$(id -g) -v /etc/passwd:/etc/passwd:ro -e MAKE_JOBS=4 -e FALCO_VERSION=${FALCO_VERSION} -it -v /home/user/src:/source -v /home/user/build/falco:/build falcosecurity/falco-builder cmake
FALCO_VERSION=0.1.2-test docker run --user $(id -u):$(id -g) -v /etc/passwd:/etc/passwd:ro -e MAKE_JOBS=4 -e FALCO_VERSION=${FALCO_VERSION} -it -v /home/user/src:/source -v /home/user/build/falco:/build falcosecurity/falco-builder package
```

The default value for FALCO_VERSION is `0.1.1dev`, so you can skip specifying FALCO_VERSION if you want.

### Test using falco-tester container

If you'd like to run the regression test suite against your build, you can use the [falco-tester](https://hub.docker.com/r/falcosecurity/falco-tester) container. Like the builder image, it contains the necessary environment to run the regression tests, but relies on a source directory and build directory that are mounted into the image. It's a different image than `falco-builder` as it doesn't need a compiler and needs a different base image to include the test runner framework [avocado](http://avocado-framework.github.io/).

It does build a new container image `falcosecurity/falco:test` to test the process of buillding and running a container with the falco packages built during the build step.

The image depends on the following parameters:

* `FALCO_VERSION`: The version of the falco package to include in the test container image.

A typical way to run this builder is the following. Assuming you have
checked out falco and sysdig to directories below /home/user/src, and
want to use a build directory of /home/user/build/falco, you would run
the following:

```bash
docker run --user $(id -u):$(id -g) -v /boot:/boot:ro -v /var/run/docker.sock:/var/run/docker.sock -v /etc/passwd:/etc/passwd:ro -e FALCO_VERSION=${FALCO_VERSION} -v /home/user/src::/source -v /home/user/build/falco:/build falcosecurity/falco-tester
```

The default value for FALCO_VERSION is `0.1.1dev`, so you can skip specifying FALCO_VERSION if you want.

## Build directly on host

If you'd rather build directly on the host, you can use your local toolchain and cmake binaries.

Clone this repo in a directory that also contains the sysdig source repo. The result should be something like:

```
22:50 vagrant@vagrant-ubuntu-trusty-64:/sysdig
$ pwd
/sysdig
22:50 vagrant@vagrant-ubuntu-trusty-64:/sysdig
$ ls -l
total 20
drwxr-xr-x  1 vagrant vagrant  238 Feb 21 21:44 falco
drwxr-xr-x  1 vagrant vagrant  646 Feb 21 17:41 sysdig
```

To build from the head of falco's dev branch, make sure you're also using the head of the sysdig dev branch. If you're building from a specific version of falco (say x.y.z), there will be a corresponding tag `falco/x.y.z` on the sysdig repository that you should use.

create a build dir, then setup cmake and run make from that dir:

```bash
mkdir build
cd build
cmake ..
make
```

Afterward, you should have a falco executable in `build/userspace/falco/falco`.

If you'd like to build a debug version, run cmake as `cmake -DCMAKE_BUILD_TYPE=Debug ..` instead.

## Load latest falco-probe kernel module

If you have a binary version of falco installed, an older falco kernel module may already be loaded. To ensure you are using the latest version, you should unload any existing falco kernel module and load the locally built version.

Unload any existing kernel module via:

```bash
rmmod falco_probe
```

To load the locally built version, assuming you are in the `build` dir, use:

```bash
insmod driver/falco-probe.ko
```

## Running falco

Assuming you are in the `build` dir, you can run falco as:

```bash
sudo ./userspace/falco/falco -c ../falco.yaml -r ../rules/falco_rules.yaml
```

By default, falco logs events to standard error.
