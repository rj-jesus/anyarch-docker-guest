# anyarch-docker-guest

This README summarizes a method for running docker guest systems of arbitrary
architectures on a single host system. It is highly based on the approaches
described in [1] and [2]. Interested readers who would like to learn how the
method works are referred to those references. The main contribution of this
repository is providing an up-to-date patch for QEMU that brings the original
work of Petros Angelatos [3] in line with current versions of the emulator
software. The patch has been submitted for inclusion in QEMU and can be tracked
in [5].

## Goal

By following the steps below, we will create and run a docker container based
on Debian arm64 [4] on an x86 host. The choice of architecture is quite
arbitrary: as long as QEMU supports it, any guest/host architecture should
work.

## Steps

### 1. Compile a patched static QEMU emulator

```bash
git clone git://git.qemu.org/qemu.git
cd qemu
git apply ../v4-linux-user-add-option-to-intercept-execve-syscalls.diff
./configure --target-list=aarch64-linux-user --static
make
```

This will create a static QEMU emulator patched to include a new option,
`--execve`, that can be used to issue the recursive (emulated) execution of a
process and the children it may create.

Next, we copy the static binary to outside the QEMU tree.
```bash
cp aarch64-linux-user/qemu-aarch64 ..
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
