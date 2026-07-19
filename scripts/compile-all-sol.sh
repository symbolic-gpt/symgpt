# solc-select install 0.4.19 
# solc-select use 0.4.19
# solc --bin --overwrite -o benchmark/baseline_bin/aoa benchmark/small/aoa.sol 


dirs=("benchmark/baseline")

extract_version() {
    local file="$1"
    # Look for pragma solidity version
    local version=$(grep -E "pragma solidity" "$file" | head -1 | sed -E 's/.*pragma solidity[[:space:]]*[^0-9]*([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
    
    # If exact version not found, try to extract major.minor version
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        version=$(grep -E "pragma solidity" "$file" | head -1 | sed -E 's/.*pragma solidity[[:space:]]*[^0-9]*([0-9]+\.[0-9]+).*/\1/')
        # Add .0 for patch version if only major.minor found
        if [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
            version="${version}.0"
        fi
    fi
    
    echo "$version"
}

for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "Processing $dir directory..."
        for file in "$dir"/*.sol; do
            version=$(extract_version "$file")
            if [ -n "$version" ]; then
                solc-select install "$version" || echo "Failed to install Solidity version $version"
                solc-select use "$version" || echo "Failed to use Solidity version $version"
                solc --bin --overwrite -o "benchmark/baseline_bin/$(basename "$file" .sol)" "$file" || echo "Failed to compile $file"
            else
                echo "No Solidity version found in $file"
            fi
        done
    fi
done
