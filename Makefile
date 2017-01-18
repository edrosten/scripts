INSTALLDIR=$(HOME)/bin


AWK=

all:
	#Super-fast make finished already!!!!!!!!
	echo w00t

install:
	find . -type f | grep -v Makefile \
		| grep -v \.swp \
		| sed -e's!.*/\(.*\)!cp & $(INSTALLDIR)/\1!' \
		| sh

