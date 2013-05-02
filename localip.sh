wireless="`ifconfig en1 | grep inet | cut -d " " -f 2`"
eth="`ifconfig en0 | grep inet | cut -d " " -f 2`"
if [[ -z "$wireless" && -z "$eth" ]]; then
  echo "No Connection"
elif [[ -z "$wireless" ]]; then
  echo "$eth"
else
  echo "$wireless"
fi
