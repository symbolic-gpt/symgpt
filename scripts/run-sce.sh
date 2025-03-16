# for loop
for file in ./benchmark/smallext/*.sol; do

    # output file is ./eval/sce/xxx/xxx.log
    BASE_NAME="${file#./benchmark/smallext/}"
    OUTPUT_FILE="./eval/sce/${BASE_NAME%.*}.log"
    OUTPUT_DIR=$(dirname "$OUTPUT_FILE")

    echo "Processing $file with sce, Output File is $OUTPUT_FILE"
    mkdir -p "$OUTPUT_DIR"


    slither $file --detect arbitrary-send-erc20,erc20-interface,erc721-interface,arbitrary-send-eth,arbitrary-send-erc20-permit > "$OUTPUT_FILE" 2>&1


done