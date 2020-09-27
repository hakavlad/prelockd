NAME = prelockd

DESTDIR ?=
PREFIX ?=         /usr/local
SYSCONFDIR ?=     /usr/local/etc
SYSTEMDUNITDIR ?= /usr/local/lib/systemd/system

SBINDIR ?= $(PREFIX)/sbin
DATADIR ?= $(PREFIX)/share
DOCDIR ?=  $(DATADIR)/doc/$(NAME)

all:
	@ echo "Use: make install, make uninstall"

base:
	install -d $(DESTDIR)$(SBINDIR)
	install -m0755 $(NAME) $(DESTDIR)$(SBINDIR)/$(NAME)

	install -d $(DESTDIR)$(SYSCONFDIR)
	install -m0644 $(NAME).conf $(DESTDIR)$(SYSCONFDIR)/$(NAME).conf

	install -d $(DESTDIR)$(DOCDIR)
	install -m0644 README.md $(DESTDIR)$(DOCDIR)/README.md

	install -dm0700 $(DESTDIR)/var/lib/$(NAME)

units:
	install -d $(DESTDIR)$(SYSTEMDUNITDIR)

	sed "s|:TARGET_SBINDIR:|$(SBINDIR)|; s|:TARGET_SYSCONFDIR:|$(SYSCONFDIR)|" \
		$(NAME).service.in > $(NAME).service

	install -m0644 $(NAME).service $(DESTDIR)$(SYSTEMDUNITDIR)/$(NAME).service

	rm -fv $(NAME).service

useradd:
	-useradd -r -M -s /bin/false $(NAME)

chcon:
	-chcon -t systemd_unit_file_t $(DESTDIR)$(SYSTEMDUNITDIR)/$(NAME).service
	# Don't worry if you see "make: [chcon] Error 1", just ignore it.

daemon-reload:
	-systemctl daemon-reload

install: base units useradd chcon daemon-reload

uninstall-base:
	rm -fv $(DESTDIR)$(SBINDIR)/$(NAME)
	rm -fvr $(DESTDIR)$(DOCDIR)/
	rm -fvr $(DESTDIR)$(SYSCONFDIR)/$(NAME).conf
	rm -fvr $(DESTDIR)/var/lib/$(NAME)/

uninstall-units:
	# 'make uninstall-units' must not fail with error if systemctl is unavailable or returns error
	-systemctl stop $(NAME).service || true
	-systemctl disable $(NAME).service || true

	rm -fv $(DESTDIR)$(SYSTEMDUNITDIR)/$(NAME).service

uninstall: uninstall-base uninstall-units daemon-reload
