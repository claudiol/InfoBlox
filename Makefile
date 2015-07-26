all:InfoBlox_gem

InfoBlox_gem:
	gem build spec/InfoBlox.gemspec
	cp InfoBloxConnection-*.gem dist/

install:
	sudo gem install --local dist/InfoBloxConnection-0.2.gem

uninstall:
	sudo gem uninstall InfoBloxConnection 

