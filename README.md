# anyarch-docker-guest

This README summarizes a method for running docker guest systems of arbitrary
architectures on a given host system. It is largely based on the approaches
described in [1] and [2]. In brief, the method works by running syscalls issued
in the docker guest system through QEMU, which makes the interface between host
and guest system. Interested readers who would like to learn how the method
works in more detail are referred to the aforementioned references. The main
contribution of this repository is to provide an updated patch for QEMU that
brings the original work of Petros Angelatos [3] in line with current versions
of the emulator. The patch has been submitted for inclusion in QEMU and can be
tracked in [5].

Edit 2022/02/24: Patch bumped to QEMU-6.2.0.

## Goal

The following steps describe how to run a guest docker container based on
Debian AArch64 [4] on an x86 host. The choice of architecture is rather
arbitrary (as long as QEMU supports it, any guest/host architecture should
work).

## Steps

### 1. Compile a patched static QEMU emulator

```bash
git clone git://git.qemu.org/qemu.git
git checkout v6.2.0
cd qemu
git apply ../v5-linux-user-add-option-to-intercept-execve-syscalls.diff
./configure --static --target-list=aarch64-linux-user
make
```

This will create a static QEMU emulator, `build/qemu-aarch64`, patched with a
new option, `--execve`, that can be used to issue the recursive emulated
execution of a process and its children.

Next, we copy the static binary to outside the QEMU tree.
```bash
cp build/qemu-aarch64 ..
```

### 2. Create a docker image for the architecture you wish to emulate

```bash
docker build -t debian-arm64v8 .
```

Note that the Dockerfile included in this repository purposefully updates the
base Debian image, and the commands involved to accomplish the update already
run emulated.

Next, simply start a container based on the image created and test that
everything works.
```bash
$ docker run -it --rm debian-arm64v8
root@8b88909fa3f1:/# uname -m
aarch64
root@8b88909fa3f1:/# 
```

## References

[1] https://www.balena.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/  
[2] https://blog.cloudflare.com/porting-our-software-to-arm64/  
[3] https://patchwork.ozlabs.org/project/qemu-devel/patch/1455515507-26877-1-git-send-email-petrosagg@resin.io/  
[4] https://hub.docker.com/r/arm64v8/debian/  
[5] https://patchew.org/QEMU/20200730160106.16613-1-rj.bcjesus@gmail.com/  
