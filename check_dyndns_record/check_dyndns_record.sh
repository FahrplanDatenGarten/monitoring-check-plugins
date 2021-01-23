#!/usr/bin/env bash
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
      -s|--nameserver)
      NAMESERVER="$2"
      shift
      shift
      ;;
      -r|--record)
      RECORD_NAME="$2"
      shift
      shift
      ;;
      -4|--ipv4)
      IPV4=true
      shift
      shift
      ;;
      -6|--ipv6)
      IPV6=true
      shift
      shift
      ;;
      *)
      shift
      ;;
  esac
done

if [ -z "$NAMESERVER" ] || [ -z "$RECORD_NAME" ] || { [ -z "$IPV4" ] && [ -z "$IPV6" ]; }; then
  echo "UNKNOWN: Wrong arguments given"
  exit 3
fi

if [ $IPV4 ]; then
  REAL_IP_ADDRESS=$(curl -s ip4.clerie.de)
  RECORD_TYPE="A"
elif [ $IPV6 ]; then
  REAL_IP_ADDRESS=$(curl -s ip6.clerie.de)
  RECORD_TYPE="AAAA"
fi


NS_IP_ADDRESS=$(dig +short $RECORD_TYPE @"$NAMESERVER" "$RECORD_NAME")

if [ "$REAL_IP_ADDRESS" == "$NS_IP_ADDRESS" ]; then
  echo "OK: $RECORD_TYPE record ($RECORD_NAME @ $NAMESERVER) is $NS_IP_ADDRESS"
	exit 0
else
  echo "CRITICAL: $RECORD_TYPE record ($RECORD_NAME @ $NAMESERVER) is $NS_IP_ADDRESS not $REAL_IP_ADDRESS"
  exit 2
fi

echo "UNKNOWN: Wrong arguments given or command broken"
exit 3
