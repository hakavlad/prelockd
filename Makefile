NAME = prelockd

DESTDIR ?=
PREFIX ?=         /usr/local
SYSCONFDIR ?=     /usr/local/etc
SYSTEMDUNITDIR ?= /usr/local/lib/systemd/system

SBINDIR ?= $(PREFIX)/sbin
DATADIR ?= $(PREFIX)/share
DOCDIR ?=  $(DATADIR)/doc/$(NAME)
MANDIR ?=  $(DATADIR)/man

PANDOC := $(shell command -v pandoc 2> /dev/null)

all:
	@ echo "Use: make install, make uninstall"

update-manpage:

ifdef PANDOC
	pandoc MANPAGE.md -s -t man > prelockd.8
else
	@echo "pandoc is not installed, skipping manpages generation"
endif

base:
	install -p -d $(DESTDIR)$(SBINDIR)
	install -p -m0755 $(NAME) $(DESTDIR)$(SBINDIR)/$(NAME)

	install -p -d $(DESTDIR)$(SYSCONFDIR)
	install -p -m0644 $(NAME).conf $(DESTDIR)$(SYSCONFDIR)/$(NAME).conf

	install -p -d $(DESTDIR)$(DATADIR)/$(NAME)
	install -p -m0644 $(NAME).conf $(DESTDIR)$(DATADIR)/$(NAME)/$(NAME).conf

	install -p -d $(DESTDIR)$(DOCDIR)
	install -p -m0644 README.md $(DESTDIR)$(DOCDIR)/README.md
	install -p -m0644 MANPAGE.md $(DESTDIR)$(DOCDIR)/MANPAGE.md

	install -p -d $(DESTDIR)$(MANDIR)/man8
	sed "s|:SYSCONFDIR:|$(SYSCONFDIR)|g; s|:DATADIR:|$(DATADIR)|g" \
		$(NAME).8 > tmp.$(NAME).8
	gzip -9cn tmp.$(NAME).8 > $(DESTDIR)$(MANDIR)/man8/$(NAME).8.gz
	rm -fv tmp.$(NAME).8

	install -p -dm0700 $(DESTDIR)/var/lib/$(NAME)

units:
	install -p -d $(DESTDIR)$(SYSTEMDUNITDIR)

	sed "s|:TARGET_SBINDIR:|$(SBINDIR)|; s|:TARGET_SYSCONFDIR:|$(SYSCONFDIR)|" \
		$(NAME).service.in > $(NAME).service

	install -p -m0644 $(NAME).service $(DESTDIR)$(SYSTEMDUNITDIR)/$(NAME).service

	rm -fv $(NAME).service

useradd:
	useradd -r -s /bin/false $(NAME) || :

chcon:
	chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/$(NAME).service || :

daemon-reload:
	systemctl daemon-reload || :

build_deb: base units

reinstall-deb:
	set -v
	deb/build.sh
	sudo apt install --reinstall ./deb/package.deb

install: base units useradd chcon daemon-reload
	# This is fine.

uninstall-base:
	rm -fv $(DESTDIR)$(SBINDIR)/$(NAME)
	rm -fvr $(DESTDIR)$(SYSCONFDIR)/$(NAME).conf
	rm -fv $(DESTDIR)$(MANDIR)/man8/$(NAME).8.gz
	rm -fvr $(DESTDIR)$(DATADIR)/$(NAME)/
	rm -fvr $(DESTDIR)$(DOCDIR)/
	rm -fvr $(DESTDIR)/var/lib/$(NAME)/

uninstall-units:
	systemctl stop $(NAME).service || :
	systemctl disable $(NAME).service || :

	rm -fv $(DESTDIR)$(SYSTEMDUNITDIR)/$(NAME).service

uninstall: uninstall-base uninstall-units daemon-reload
