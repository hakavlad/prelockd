# prelockd

[![Total alerts](https://img.shields.io/lgtm/alerts/g/hakavlad/prelockd.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/prelockd/alerts/)
[![Packaging status](https://repology.org/badge/tiny-repos/prelockd.svg)](https://repology.org/project/prelockd/versions)

prelockd is a daemon that locks memory mapped binaries and libraries in memory to improve system responsiveness under low-memory conditions.

## What is the problem?

> Would it be possible to reserve a fixed (configurable) amount of RAM for caches, and trigger OOM killer earlier, before most UI code is evicted from memory? In my use case, I am happy sacrificing e.g. 0.5GB and kill runaway tasks _before_ the system freezes. Potentially OOM killer would also work better in such conditions. I almost never work at close to full memory capacity, it's always a single task that goes wrong and brings the system down.

— [lkml](https://lkml.org/lkml/2019/8/8/639)

> Why not fix the problem in the kernel?

> Like not swap executable code when the system is near-OOM?

— [www.phoronix.com](https://www.phoronix.com/forums/forum/phoronix/general-discussion/1193342-systemd-oomd-looks-like-it-will-come-together-for-systemd-247?p=1193384#post1193384)


> No caches means all executable pages, ro pages (e.g. fonts) are evicted
> from memory and have to be constantly reloaded on every user action.

> It is indeed a difficult problem - some
> cached pages (streaming IO) will likely not be needed again and should
> be discarded asap, other (like mmapped executable/ro pages of UI
> utilities) will cause thrashing when evicted under high memory pressure.

— [lkml.org](https://lkml.org/lkml/2019/8/9/294)

> I would like to try disabling/limiting eviction of some/all
> file pages (for example exec pages) akin to disabling swapping, but
> there is no such mechanism. Yes, there would likely be problems with
> large RO mmapped files that would need to be addressed, but in many
> applications users would be interested in having such options.

— [lkml.org](https://lkml.org/lkml/2019/8/10/161)

> Once swap runs out, the kernel stops having a choice. It can only make room by reclaiming important caches. And this will turn bad quickly, as it will eventually include the executables/libraries that must be loaded as they are doing work!

> So, we don't want to get the kernel into the situation where it must remove executables/libraries from main memory. If that happens, you can end up hitting the disk for *every* function call.

— [lists.fedoraproject.org](https://lists.fedoraproject.org/archives/list/devel@lists.fedoraproject.org/message/5V2BBYBQ6AWAL7LXYLYV6XBZYGPDS5RV/)


## Effects
- OOM killer comes faster (especially with noswap).
- Fast system reclaiming after OOM.
- Improved system responsiveness under low-memory conditions.

## Demo

https://www.youtube.com/watch?v=vykUrP1UvcI

On this video: running fast memory hogs in a loop on Debian 10 GNOME, 4 GiB MemTotal without swap space.
- prelockd enabled: about 500 MiB mlocked. Starting `while true; do tail /dev/zero; done`: no freezes. The OOM killer comes quickly, the system recovers quickly.
- prelockd disabled: system hangs with `while true; do tail /dev/zero; done`.

See also https://youtu.be/fPnbnNX9CPE, https://youtu.be/O8QNnfb_Vm0.

## Install

#### On [Fedora](https://src.fedoraproject.org/rpms/prelockd):
```
$ sudo dnf install prelockd
$ sudo systemctl enable --now prelockd.service
```

#### For Arch Linux there's an [AUR package](https://aur.archlinux.org/packages/prelockd-git/)

Use your favorite [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers). For example,
```bash
$ yay -S prelockd-git
$ sudo systemctl enable --now prelockd.service
```

#### To install on Debian and Ubuntu-based systems:

It's easy to build a deb package with the latest git snapshot. Install build dependencies:
```bash
$ sudo apt install make fakeroot
```

Clone the latest git snapshot and run the build script to build the package:
```bash
$ git clone https://github.com/hakavlad/prelockd.git && cd prelockd
$ deb/build.sh
```

Install the package:
```bash
$ sudo apt install --reinstall ./deb/package.deb
```

Start and enable `prelockd.service` after installing the package:
```bash
$ sudo systemctl enable --now prelockd.service
```

#### On other distros:

Install:
```bash
$ git clone https://github.com/hakavlad/prelockd.git && cd prelockd
$ sudo make install
$ sudo systemctl enable --now prelockd.service
```

Uninstall:
```bash
$ sudo make uninstall
```

## How to configure

Edit the config (`/etc/prelockd.conf` or `/usr/local/etc/prelockd.conf`) and restart the service.

## TODO

- Improve the documentation.

## Report bugs and ask any questions

https://github.com/hakavlad/prelockd/issues
