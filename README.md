# prelockd

[![Total alerts](https://img.shields.io/lgtm/alerts/g/hakavlad/prelockd.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/prelockd/alerts/)

prelockd is a daemon that locks mmapped binaries and libraries in memory and prevents code eviction from memory.

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

## Install

```
$ git clone https://github.com/hakavlad/prelockd.git && cd prelockd
$ sudo make install
$ sudo systemctl enable --now prelockd.service
```

## Uninstall

```
$ sudo make uninstall
```

## Output example

```
04:47:42 PC prelockd[5370]: starting prelockd
04:47:44 PC prelockd[5370]: process memory locked with MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT
04:47:44 PC prelockd[5370]: found 962 mapped files
04:47:45 PC prelockd[5370]: mlocked 738 files, 230.1 MiB
04:47:45 PC prelockd[5370]: fd opened: 1481
04:47:45 PC prelockd[5370]: startup time: 3.63s
04:47:45 PC prelockd[5370]: process time: 2.068s
```

## How to use

Just restart the service after starting GUI session, and executables/libraries will be locked.

## Effects

- OOM killer comes faster.
- Fast system reclaiming after OOM.

## Defaults

- Maximum file size that can be locked is 10 MiB.

## TODO

- Set max memory limit for all locked files.
- Add a config and man page.

## Report bugs and ask any questions

https://github.com/hakavlad/prelockd/issues

