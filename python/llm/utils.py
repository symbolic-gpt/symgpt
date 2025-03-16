def trim_json_markers(input_str: str) -> str:
    start_marker = "json```"
    alt_start_marker = "```json"
    end_marker = "```"
    
    start_index = input_str.find(start_marker)
    if start_index == -1:
        start_index = input_str.find(alt_start_marker)
        if start_index != -1:
            start_index += len(alt_start_marker)
    else:
        start_index += len(start_marker)
    
    if start_index != -1:
        end_index = input_str.find(end_marker, start_index)
        if end_index != -1:
            input_str = input_str[start_index:end_index]
    
    input_str = input_str.replace("\"\"\"", "\"")

    ## Repleace raw hex to string:
    ## Ex. ..."xxx": 0x4e2312e0... -> ..."xxx": "0x4e2312e0"...
    while input_str.find(": 0x") != -1:
        start_idx = input_str.find(": 0x")
        end_idx = start_idx + 4
        while end_idx < len(input_str) and input_str[end_idx] != "\n":
            end_idx += 1
        orig_hex = input_str[start_idx+2:end_idx]
        input_str = input_str.replace(orig_hex, f"\"{orig_hex}\"")
        
    ## clean possible comments
    lines = input_str.split("\n")
    for idx, line in enumerate(lines):
        if line.find("//") != -1:
            lines[idx] = line[:line.find("//")]
    input_str = "\n".join(lines)
    return input_str