#!/bin/bash
source third_party/AChecker/.venv/bin/activate

# for loop
for file in ./benchmark/small_bin/**/*.bin; do
    
    # output file is ./local/achecker/xxx/xxx.bin
    BASE_NAME="${file#./benchmark/small_bin/}"
    OUTPUT_FILE="./local/achecker/${BASE_NAME%.*}.log"
    OUTPUT_DIR=$(dirname "$OUTPUT_FILE")

    echo "Processing $file with achecker, Output File is $OUTPUT_FILE"
    mkdir -p "$OUTPUT_DIR"

    if [ -f "$OUTPUT_FILE" ]; then
        echo "$OUTPUT_FILE already exists, skip"
        continue
    fi

    timeout 30m python ../AChecker/bin/achecker.py -f "$file" -b > "$OUTPUT_FILE" 2>&1

    # Check if timeout occurred
    if [ $? -eq 124 ]; then
        echo "Timeout occurred for $file" >> "$OUTPUT_FILE"
    fi
done