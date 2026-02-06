# for loop
for file in ./benchmark/baseline_bin/**/*.bin; do
    
    # output file is ./local/mythril/xxx/xxx.bin
    BASE_NAME="${file#./benchmark/baseline_bin/}"
    OUTPUT_FILE="./local/mythril/${BASE_NAME%.*}.log"
    OUTPUT_DIR=$(dirname "$OUTPUT_FILE")

    echo "Processing $file with mythril, Output File is $OUTPUT_FILE"
    mkdir -p "$OUTPUT_DIR"


    docker run --rm -v "$file:/code/bin" mythril/myth analyze --codefile /code/bin > "$OUTPUT_FILE" 2>&1

done