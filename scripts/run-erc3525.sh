# Check if an argument was provided
if [ -z "$1" ]; then
    FILE=benchmark/erc3525/*.sol
else
    FILE="$1"
fi

./x audit $FILE --out-dir local/erc3525