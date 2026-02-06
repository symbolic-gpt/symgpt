import logging
logging.basicConfig(filename='console.log', level=logging.INFO)
import subprocess
import os

def run_nftdefect(sols_dir:str): 
    sols_dir = os.path.abspath(sols_dir) 
    
    file2cname = {
        '1155_candidate_3.sol': "PGERC1155",
        '1155_candidate_5.sol': "SunflowerLandInventory"
    }
    
    for root, dirs, files in os.walk(sols_dir):
        for file in files:
            if file.endswith(".sol"):
               
                logging.info(f"file={file}")
                try:
                    cname = file2cname.get(file, "")
                    res = subprocess.run(
                        ["docker", "run", "-v", f"{sols_dir}:/NFTGuard/test", "ghcr.io/nftdefects/nftdefects:latest", "-s", "test/"+file, "-cnames", cname, "-j"], 
                        capture_output=True)
                    if res.returncode != 0:
                        raise Exception(f"error={res.returncode}")
                    logging.info(f"stdout={res.stdout.decode('utf-8')}")
                    logging.info(f"done")
                except Exception as ex:
                    logging.error(ex)
                    logging.error(f"stderr={res.stderr.decode('utf-8')}")


def main():
    run_nftdefect("benchmark/baseline")

if __name__ == "__main__":
    main()