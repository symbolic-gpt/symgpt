import logging
logging.basicConfig(filename='console.log', level=logging.INFO)
import subprocess
import os
import shutil

def run_nftdefect(sols_dir:str): 
    sols_dir = os.path.abspath(sols_dir) 

    if shutil.which("docker") is None:
        logging.error("docker is not installed or not in PATH")
        return False
    
    file2cname = {
        '1155_candidate_1.sol': "AssetContractShared",
        '1155_candidate_2.sol': "Capsule",
        '1155_candidate_3.sol': "PGERC1155",
        '1155_candidate_4.sol': "ChildERC1155",
        '1155_candidate_5.sol': "SunflowerLandInventory",
        '721_candidate_1.sol': "NonFungibleToken",
        '721_candidate_2.sol': "AKCB",
        '721_candidate_3.sol': "LicenseCore",
        '721_candidate_4.sol': "BaseRegistrarImplementation",
        '721_candidate_5.sol': "HaikuNFT",
        'CMBToken.sol': "CMBToken",
        'EZOToken.sol': "EZOToken",
        'KIMEX.sol': "KIMEX",
        'KINGSGLOBAL.sol': "KINGSGLOBAL",
        'KuCoin.sol': "MyToken",
        'LUTOKEN.sol': "LutToken",
        'PKG.sol': "CustomToken",
        'aoa.sol': "ArthurStandardToken",
        'axpire.sol': "AxpireToken",
        'battoken.sol': "BAToken",
        'bitcoinsvgold.sol': "BITCOINSVGOLD",
        'bnb.sol': "BNB",
        'dai.sol': "DSToken",
        'egypt.sol': "Egypt",
        'gencoin.sol': "GEIMCOIN",
        'huobi.sol': "HBToken",
        'husky.sol': "SiberianHusky",
        'idex.sol': "MyToken",
        'iostoken.sol': "IOSToken",
        'jntr.sol': "JNTR",
        'mkr.sol': "DSToken",
        'mxm.sol': "TokenERC20",
        'omg.sol': "OMGToken",
        'organicco.sol': "Organicco",
        'pandai.sol': "PandAIToken",
        'silkroad.sol': "SilkToken",
        'wit.sol': "WiT",
        'xeuro.sol': "xEuro",
        'xn35.sol': "Projecton",
        'zrx.sol': "ZRXToken",
    }
    
    success = True
    for root, dirs, files in os.walk(sols_dir):
        for file in files:
            if file.endswith(".sol"):
               
                logging.info(f"file={file}")
                res = None
                try:
                    cname = file2cname[file]
                    res = subprocess.run(
                        ["docker", "run", "-v", f"{sols_dir}:/NFTGuard/test", "ghcr.io/nftdefects/nftdefects:v0.1", "-s", "test/"+file, "-cnames", cname, "-j"],
                        capture_output=True)
                    if res.returncode != 0:
                        raise Exception(f"error={res.returncode}")
                    logging.info(f"stdout={res.stdout.decode('utf-8')}")
                    logging.info(f"done")
                except FileNotFoundError:
                    logging.error("docker is not installed or not in PATH")
                    return False
                except Exception as ex:
                    success = False
                    logging.error(ex)
                    if res is not None and res.stderr:
                        logging.error(f"stderr={res.stderr.decode('utf-8')}")

    return success


def main():
    if not run_nftdefect("benchmark/baseline_nftguard"):
        raise SystemExit(1)

if __name__ == "__main__":
    main()
