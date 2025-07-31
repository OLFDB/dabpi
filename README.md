# dabpi
Raspberry Si4688 FM / DAB+ Receiver

Original Project from Heiko Jehmlich, see https://github.com/teknoid/dabpi

Original Project from Bjoern Biesenbach, see https://github.com/elmo2k3/dabpi_ctl

New Boards can be ordered from Christoph Orth at https://ugreen.eu/product/ugreen-dab-board/

## News

27.07.2025 - added DAB data service functionality

-f starts all data services for a given serviceid

-p starts dumping the service data into a fifo file dabdata in the current directory

-r1 enables debug output when using -p

```bash
dsrvpcktint: 	0x1
dsrvovflint: 	0x0
buff_count: 	0x4
srv_state: 	0x3 -> New Object
data_src: 	0x0 -> standard data service and DATA_TYPE is DSCTy
service_id: 	0xd210
comp_id: 	0xc001
dscty: 		0x5 -> TDC
uatype: 	0x44a -> Journaline™
byte_cnt: 	0x80
seg_num: 	0x0
num_segs: 	0x0

DAB_GET_DIGITAL_SERVICE_DATA data:
  0000  00 91 80 00 c0 01 04 03 05 10 d2 00 00 01 c0 00  ................
  0010  00 4a 04 80 00 00 00 00 00 40 50 79 59 59 08 5d  .J.......@PyYY.]
  0020  c9 cb 0d 02 21 10 00 50 95 2e f6 34 15 80 6e 62  ....!..P...4..nb
  0030  a2 db 81 37 13 f7 6e 88 8c b0 e1 9b 61 90 76 2c  ...7..n.....a.v,
  0040  55 ce 5e df db 4f 4f 71 70 cc a5 2e 4a f5 de a5  U.^..OOqp...J...
  0050  c1 c6 f5 e5 82 4e e6 dd 92 f7 2d 70 a3 a1 aa 50  .....N....-p...P
  0060  b6 a4 63 fc 64 1a af 9b 9c 2f f3 70 e9 38 86 dd  ..c.d..../.p.8..
  0070  fd 2f 61 8b 70 4b 8c 94 90 27 f1 b5 48 a7 79 39  ./a.pK...'..H.y9
  0080  9e e1 c1 cd 6c 19 ae e0 73 2c da b3 58 1d 46 4c  ....l...s,..X.FL
  0090  60 b0 c2 aa 2d d6 1f b8 01                       `...-....
```

The dumped data is prefixed by "FF 0E FF 0E" and then contains the output of GET_DIGITAL_SERVICE_DATA starting with RESP5 BUFF_COUNT. See https://www.skyworksinc.com/-/media/Skyworks/SL/documents/public/application-notes/an649.pdf, page 175.
```bash
00000000  ff 0e ff 0e 04 03 05 10  d2 00 00 01 c0 00 00 4a  |...............J|
00000010  04 a6 01 00 00 00 00 40  90 6e 61 59 08 75 51 4d  |.......@.naY.uQM|
00000020  ae d3 30 10 2e af 17 e8  ba ab 39 c0 73 e2 b4 69  |..0.......9.s..i|
00000030  9b 74 07 08 09 c4 cf 82  47 f5 d6 6e 32 49 4c 1c  |.t......G..n2IL.|
```

13.12.2016 - added FM functionality

10.12.2016 - initial github project, only DAB implemented, contributors welcome

### Installation Instructions

Step 1: patch kernel to get I2S Audio Record Device for Si468x

```bash
patch -p 1 < 0001-Added-support-for-Si468x-Digital-Radio-Receiver-DABP.patch
```
Follow kernel build instructions at https://www.raspberrypi.org/documentation/linux/kernel/building.md

To enable the Si4688 driver execute (for cross-compiling)

```bash
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- menuconfig
```
go to "Device Drivers" --> "Sound Card Support" --> "Advanced Linux Sound Architecture" --> "Alsa for SoC Audio Support"

say "module" for "Support for DABPi featuring a Si4688 FM/FMHD/DAB receiver"

Compile and install the kernel + modules, add following lines to /boot/config.txt

```bash
dtparam=i2s=on
dtparam=spi=on

dtoverlay=rpi-dabpi
```
Then reboot. On success you should see correct I2S initialization and a new alsa recording source:

```bash
root@pidev:~# dmesg |grep i2s
[    6.411170] snd-rpi-dabpi soc:sound: si468x-hifi <-> 3f203000.i2s mapping ok

root@pidev:~# arecord -l
**** List of CAPTURE Hardware Devices ****
card 0: sndrpirpidabpi [snd_rpi_rpi_dabpi], device 0: DABPi Hifi si468x-hifi-0 []
  Subdevices: 0/1
  Subdevice #0: subdevice #0
```

Step 2: compile Si4688 controller software

```bash
git clone https://github.com/teknoid/dabpi
cd dabpi
make clean && make
```
Step 3: place firmware in ../si46xx_firmware/

```bash
root@pidev:/anus/si46xx_firmware# ls -la
total 2040
drwxr-xr-x 2 hje  hje     4096 Dec  9  2016 .
drwxrwxr-x 5 root users   4096 Dec 10  2016 ..
-rw-r--r-- 1 hje  hje   517708 Aug 15  2014 dab_radio_3_2_7.bif
-rw-r--r-- 1 hje  hje   521448 Dec  9  2015 dab_radio_5_0_5.bin
-rw-r--r-- 1 hje  hje   493128 Aug 15  2014 fmhd_radio_3_0_19.bif
-rw-r--r-- 1 hje  hje   530180 Dec  2  2015 fmhd_radio_5_0_4.bin
-rw-r--r-- 1 hje  hje     5796 Nov  9  2012 rom00_patch.016.bin
```

### Usage

Enter DAB+ mode

```bash
root@pidev:/anus/dabpi# ./dabpi_ctl -a
dabpi_ctl version v0.01-43-g369d8de
POWER_UP:
  0000  00 80 00 00 80                                   .....
LOAD_INIT:
  0000  00 80 00 00 80                                   .....
HOST_LOAD:
  0000  00 80 00 00 80                                   .....
  
...

HOST_LOAD:
  0000  00 80 00 00 80                                   .....
HOST_LOAD:
  0000  00 80 00 00 80                                   .....
BOOT:
  0000  00 80 80 00 c0                                   .....
GET_SYS_STATE:
  0000  00 80 80 00 c0 02 ff                             .......
Current mode: 
DAB is active
GET_PART_INFO:
  0000  00 80 80 00 c0 00 00 00 00 50 12 00 00 00 00 50  .........P.....P
  0010  12 00 00 00 00 01 00                             .......
SET_PROPERTY:
  0000  00 80 80 00 c0                                   .....
SET_PROPERTY:
  0000  00 80 80 00 c0                                   .....
SET_PROPERTY:
  0000  00 80 80 00 c0                                   .....
SET_PROPERTY:
  0000  00 80 80 00 c0                                   .....

```
Set Frequency depending on your Region (0 - 16) - example for South Tyrol

```bash
root@pidev:/anus/dabpi# ./dabpi_ctl -j 15
dabpi_ctl version v0.01-43-g369d8de
DAB_SET_FREQ_LIST:
  0000  00 80 80 00 c0                                   .....

```
Tune to DAB channel

```bash
root@pidev:/anus/dabpi# ./dabpi_ctl -i 0
dabpi_ctl version v0.01-43-g369d8de
DAB_TUNE_FREQ:
  0000  00 81 80 00 c0                                   .....

```
Get ensemble information

```bash
root@pidev:/anus/dabpi# ./dabpi_ctl -g
dabpi_ctl version v0.01-43-g369d8de
DAB_GET_DIGITAL_SERVICE_LIST:
  0000  00 81 80 00 c0 56 01                             .....V.
List size:     342
List version:  36
Services:      12

 Nr | Service ID | Service Name     | Component IDs
--------------------------------------------------
 00 |       42f1 | RAS Swiss Pop+   | 11 
 01 |       42f2 | RAS SwissClassic | 10 
 02 |       43e2 | RAS RSI Rete 2+  | 12 
 03 |       5203 | Rai Radio3+      | 3 
 04 |       5301 | Rai Radio1+ TAA  | 1 
 05 |       5302 | Rai Radio2+ TAA  | 2 
 06 |       5304 | RAI SUEDTIROL+   | 4 
 07 |       d220 | RAS DKULTUR+     | 9 
 08 |       d313 | RAS BAYERN 3     | 5 
 09 |       d314 | RAS BR-KLASSIK   | 6 
 10 |       d315 | RAS B5 aktuell   | 7 
 11 |       df95 | RAS KIRAKA+      | 8 
 ```
 Start one of the services in ensemble 
 
 ```bash
 root@pidev:/anus/dabpi# ./dabpi_ctl -f 0

...
Starting service RAS Swiss Pop+   42f1 b
DAB_START_DIGITAL_SERVICE:
  0000  00 81 80 00 c0                                   .....
```

Start alsa playback

```bash
ssh hje@pidev 'arecord -D hw:0,0 -f dat -' | aplay -f dat -
```

Enjoy the music ;-)
 
