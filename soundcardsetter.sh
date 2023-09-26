#!/bin/bash

BACKYARD_USB_PORT=usb-0000:00:14.0-1.4
FRONTYARD_USB_PORT=usb-0000:00:14.0-1.3
DECK_USB_PORT=usb-0000:00:14.0-1.2
MASTERBR_USB_PORT=usb-0000:00:14.0-1.1
INTEL_ONBOARD_AUDIO="HDA Intel PCH at"

ASOUNDCARDS=/proc/asound/cards

BACKYARD_LINE_NUM=$(grep -n $BACKYARD_USB_PORT $ASOUNDCARDS | cut -f1 -d":")
FRONTYARD_LINE_NUM=$(grep -n $FRONTYARD_USB_PORT $ASOUNDCARDS | cut -f1 -d":")
DECK_LINE_NUM=$(grep -n $DECK_USB_PORT $ASOUNDCARDS | cut -f1 -d":")
MASTERBR_LINE_NUM=$(grep -n $MASTERBR_USB_PORT $ASOUNDCARDS | cut -f1 -d":")
INTEL_LINE_NUM=$(grep -n "$INTEL_ONBOARD_AUDIO" $ASOUNDCARDS | cut -f1 -d":")


BACKYARD_CARD_INDEX=100
FRONTYARD_CARD_INDEX=100
DECK_CARD_INDEX=100
MASTERBR_CARD_INDEX=100
INTEL_CARD_INDEX=100

case $BACKYARD_LINE_NUM in
  2)
    BACKYARD_CARD_INDEX=0
    ;;
  4)
    BACKYARD_CARD_INDEX=1
    ;;
  6)
    BACKYARD_CARD_INDEX=2
    ;;
  8)
    BACKYARD_CARD_INDEX=3
    ;;
  10)
    BACKYARD_CARD_INDEX=4
    ;;
esac

case $FRONTYARD_LINE_NUM in
  2)
    FRONTYARD_CARD_INDEX=0
    ;;
  4)
    FRONTYARD_CARD_INDEX=1
    ;;
  6)
    FRONTYARD_CARD_INDEX=2
    ;;
  8)
    FRONTYARD_CARD_INDEX=3
    ;;
  10)
    FRONTYARD_CARD_INDEX=4
    ;;
esac

case $INTEL_LINE_NUM in
  2)
    INTEL_CARD_INDEX=0
    ;;
  4)
    INTEL_CARD_INDEX=1
    ;;
  6)
    INTEL_CARD_INDEX=2
    ;;
  8)
    INTEL_CARD_INDEX=3
    ;;
  10)
    INTEL_CARD_INDEX=4
    ;;
esac

case $DECK_LINE_NUM in
  2)
    DECK_CARD_INDEX=0
    ;;
  4)
    DECK_CARD_INDEX=1
    ;;
  6)
    DECK_CARD_INDEX=2
    ;;
  8)
    DECK_CARD_INDEX=3
    ;;
  10)
    DECK_CARD_INDEX=4
    ;;
esac

case $MASTERBR_LINE_NUM in
  2)
    MASTERBR_CARD_INDEX=0
    ;;
  4)
    MASTERBR_CARD_INDEX=1
    ;;
  6)
    MASTERBR_CARD_INDEX=2
    ;;
  8)
    MASTERBR_CARD_INDEX=3
    ;;
  10)
    MASTERBR_CARD_INDEX=4
    ;;
esac

echo "BACKYARD_CARD_INDEX: $BACKYARD_CARD_INDEX"
echo "FRONTYARD_CARD_INDEX: $FRONTYARD_CARD_INDEX"
echo "INTEL_CARD_INDEX: $INTEL_CARD_INDEX"
echo "DECK_CARD_INDEX: $DECK_CARD_INDEX"
echo "MASTERBR_CARD_INDEX: $MASTERBR_CARD_INDEX"

rm -f /etc/pulse/system.pa

echo "load-module module-native-protocol-unix auth-anonymous=1" > /etc/pulse/system.pa
echo "load-module module-alsa-sink device=hw:$BACKYARD_CARD_INDEX,0 sink_name=backyard" >> /etc/pulse/system.pa
echo "load-module module-alsa-sink device=hw:$FRONTYARD_CARD_INDEX,0 sink_name=frontyard" >> /etc/pulse/system.pa
echo "load-module module-alsa-sink device=hw:$INTEL_CARD_INDEX,0 sink_name=onboard" >> /etc/pulse/system.pa
echo "load-module module-alsa-sink device=hw:$DECK_CARD_INDEX,0 sink_name=deck" >> /etc/pulse/system.pa
echo "load-module module-alsa-sink device=hw:$MASTERBR_CARD_INDEX,0 sink_name=masterbr" >> /etc/pulse/system.pa

systemctl restart pulseaudio
docker restart $(docker ps -a -q)
