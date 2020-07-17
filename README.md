# prelockd

[![Total alerts](https://img.shields.io/lgtm/alerts/g/hakavlad/prelockd.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/hakavlad/prelockd/alerts/)

prelockd is a daemon that locks mmapped binaries and libraries in memory and prevents code eviction from memory.

## What is the problem?


> "Would it be possible to reserve a fixed (configurable) amount of RAM for caches, and trigger OOM killer earlier, before most UI code is evicted from memory? In my use case, I am happy sacrificing e.g. 0.5GB and kill runaway tasks _before_ the system freezes. Potentially OOM killer would also work better in such conditions. I almost never work at close to full memory capacity, it's always a single task that goes wrong and brings the system down."

— [lkml](https://lkml.org/lkml/2019/8/8/639)


> "Why not fix the problem in the kernel?

> Like not swap executable code when the system is near-OOM?"

— [phoronix](https://www.phoronix.com/forums/forum/phoronix/general-discussion/1193342-systemd-oomd-looks-like-it-will-come-together-for-systemd-247?p=1193384#post1193384)


> "No caches means all executable pages, ro pages (e.g. fonts) are evicted
> from memory and have to be constantly reloaded on every user action.

> It is indeed a difficult problem - some
> cached pages (streaming IO) will likely not be needed again and should
> be discarded asap, other (like mmapped executable/ro pages of UI
> utilities) will cause thrashing when evicted under high memory pressure."

— [lkml](https://lkml.org/lkml/2019/8/9/294)


> "I would like to try disabling/limiting eviction of some/all
> file pages (for example exec pages) akin to disabling swapping, but
> there is no such mechanism. Yes, there would likely be problems with
> large RO mmapped files that would need to be addressed, but in many
> applications users would be interested in having such options."

— [lkml](https://lkml.org/lkml/2019/8/10/161)

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

## Report bugs

https://github.com/hakavlad/prelockd/issues
