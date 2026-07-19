# Check if an argument was provided
if [ -z "$1" ]; then
    FILE=benchmark/erc4907/injected/*.sol
else
    FILE="$1"
fi

./x audit $FILE --out-dir local/erc4907