from glob import glob
import subprocess
def update_progma_solidity_version(to_version: str, file_content:str) -> str:
    """
    Update the pragma solidity version in the given file content to the given version.
    """
    # Split the file content by new line
    lines = file_content.split('\n')
    # Iterate over the lines
    for i, line in enumerate(lines):
        # If the line contains pragma solidity
        if 'pragma solidity' in line:
            # Update the pragma solidity version
            lines[i] = f'pragma solidity {to_version};'
            break
    # Join the lines and return the updated file content
    return '\n'.join(lines)

def update_progma_solidity_version_in_file(to_version: str, file_path: str):
    """
    Update the pragma solidity version in the given file to the given version.
    """
    # Read the file content
    with open(file_path, 'r') as file:
        file_content = file.read()
    # Update the pragma solidity version
    updated_file_content = update_progma_solidity_version(to_version, file_content)
    # Write the updated file content
    with open(file_path, 'w') as file:
        file.write(updated_file_content)
        
if __name__ == "__main__":
    files = glob('*.sol')
    for file in files:
        update_progma_solidity_version_in_file('0.8.20', file)
        # verify it can compile by solc
        try:
            subprocess.run(['solc', file], check=True)
            print(f'Updated {file} to 0.8.20')
        except Exception as ex:
            print(f'Failed to update {file} to 0.8.20')
            print(ex)
            break
            
            