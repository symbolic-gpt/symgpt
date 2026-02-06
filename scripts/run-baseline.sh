# Check if an argument was provided
if [ -z "$1" ]; then
    FILE=benchmark/baseline/*.sol
else
    FILE="$1"
fi

./x audit $FILE --out-dir local/baseline \
--cname2ercs=TokenERC20:20 --cname2ercs=MyToken:20 --cname2ercs=KIMEX:20 --cname2ercs=HBToken:20 \
--cname2ercs=CustomToken:20 --cname2ercs=ArthurStandardToken:20 --cname2ercs=KINGSGLOBAL:20 --cname2ercs=AxpireToken:20 \
--cname2ercs=xEuro:20 --cname2ercs=ZRXToken:20 --cname2ercs=IOSToken:20 \
--cname2ercs=Egypt:20 --cname2ercs=WiT:20 --cname2ercs=GEIMCOIN:20 \
--cname2ercs=BAToken:20 --cname2ercs=BITCOINSVGOLD:20 --cname2ercs=BNB:20