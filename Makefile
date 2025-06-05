LDFLAGS=-lwiringPi -lpthread -lm
CFLAGS=-Wall -Werror -Wextra
CC=cc
dabpi_ctl: dabpi_ctl.o si46xx_dab.o si46xx_fm.o si46xx_core.o utils.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
.PHONY: clean

clean:
	rm -f dabpi_ctl *.o
