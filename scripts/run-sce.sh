# for loop
for file in ./benchmark/baseline/*.sol; do

    # output file is ./local/sce/xxx.log
    BASE_NAME="${file#./benchmark/baseline/}"
    OUTPUT_FILE="./local/sce/${BASE_NAME%.*}.log"
    OUTPUT_DIR=$(dirname "$OUTPUT_FILE")

    echo "Processing $file with sce, Output File is $OUTPUT_FILE"
    mkdir -p "$OUTPUT_DIR"


    slither $file --detect arbitrary-send-erc20,erc20-interface,erc721-interface,arbitrary-send-eth,arbitrary-send-erc20-permit > "$OUTPUT_FILE" 2>&1


done