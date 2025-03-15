
import os
import subprocess
import json
from tqdm import tqdm
root_path='...'
res_map={}
for address in tqdm(os.listdir(root_path)):
    config_path=os.path.join(root_path,address,'source_code','config.json')
    if not os.path.exists(config_path):
        continue
    with open(config_path,'r') as f:
        config=json.load(f)
        contract_name=config['ContractName']
        version=config['CompilerVersion']
    version=version.split('+')[0].replace('v','')
    path=os.path.join(root_path,address,'source_code','MainContractFlattened.sol')
    res_path=os.path.join(root_path,address,'result')
    os.makedirs(res_path,exist_ok=True)
    res_file=os.path.join(res_path,'slither_res_30.json')
    cmd=f"solc-select use {version};slither {path} --json {res_file}"
    try:
        res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1800,cwd=os.path.join(root_path,address,'source_code'))
    except Exception as e:
        print(e)
        error_reason='Time out' if 'timed out' in str(e) else 'Error'
        res_print=f"Error in slither {error_reason}"
        print(f'{res_print} in {address}')
