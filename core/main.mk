export EFIDROID_MAKE := $(MAKE)

# enable GCC colors by default (if supported)
export GCC_COLORS ?= 1


.PHONY: $(MAKECMDGOALS) all
$(MAKECMDGOALS) all: makeforward makeforward_pipes
	@python -B ./build/core/configure.py "$(firstword $(DEVICEID))" "$(BUILDTYPE)"
	
	@echo -n "" > out/buildtime_variables.sh
	@echo -n "" > out/buildtime_variables.py
	
	@ # log start time
	@start_time=$$(date +"%s"); \
	\
	# run build \
	if [ "$(DEVICEID)" == "" ];then \
		$(MAKE) -f out/build_host.mk $(MAKECMDGOALS); \
	else \
		$(MAKE) -f out/build_$(subst /,-,$(DEVICEID)).mk $(MAKECMDGOALS); \
	fi; \
	\
	# compute and show build time \
	ret=$$?; \
	end_time=$$(date +"%s"); \
	tdiff=$$(($$end_time-$$start_time)); \
	hours=$$(($$tdiff / 3600 )); \
	mins=$$((($$tdiff % 3600) / 60)); \
	secs=$$(($$tdiff % 60)); \
	echo; \
	if [ $$ret -eq 0 ] ; then \
		echo -n -e "#### make completed successfully "; \
	else \
		echo -n -e "#### make failed to build some targets "; \
	fi; \
	if [ $$hours -gt 0 ] ; then \
		printf "(%02g:%02g:%02g (hh:mm:ss))" $$hours $$mins $$secs; \
	elif [ $$mins -gt 0 ] ; then \
		printf "(%02g:%02g (mm:ss))" $$mins $$secs; \
	elif [ $$secs -gt 0 ] ; then \
		printf "(%s seconds)" $$secs; \
	fi; \
	echo -e " ####"; \
	echo; \
	exit $$ret;

# MAKEFORWARD
out/host/makeforward: build/tools/makeforward.c
	@mkdir -p out/host
	@gcc -Wall -Wextra -Wshadow -Werror $< -o $@
makeforward: out/host/makeforward

# MAKEFORWARD_PIPES
out/host/makeforward_pipes: build/tools/makeforward_pipes.c
	@mkdir -p out/host
	@gcc -Wall -Wextra -Wshadow -Werror $< -o $@
makeforward_pipes: out/host/makeforward_pipes
