
import os
import json
from tqdm import tqdm
# Define the root path for the dataset
# This should be replaced with the actual path to your dataset
root_path='..'
from RQ4.code.utils_dsr1 import ds_judge_ac
res_map={}
cou=0
for address in tqdm(os.listdir(root_path)):
    # Load configuration file
    config_path=os.path.join(root_path,address,'source_code','config.json')
    if not os.path.exists(config_path):
        continue
    with open(config_path,'r') as f:
        config=json.load(f)
        contract_name=config['ContractName']
        version=config['CompilerVersion']
    version=version.split('+')[0].replace('v','')
    # Load the main contract source code
    path=os.path.join(root_path,address,'source_code','MainContractFlattened.sol')
    path2=os.path.join(root_path,address,'source_code',f'{contract_name}.sol')
    # Check if the code is too long
    with open(path,'r') as f:
        code=f.read()
        lines_cou=code.count('\n')
        if lines_cou>500:
            if not os.path.exists(path2):
                print(os.path.join(root_path,address,'source_code'))
                continue
            with open(path2,'r') as f:
                code=f.read()
                lines_cou=code.count('\n')
    res_path=os.path.join(root_path,address,'result')
    os.makedirs(res_path,exist_ok=True)
    res_file=os.path.join(res_path,'ds_res.txt')
    # If the result file already exists, skip processing
    if os.path.exists(res_file):
        continue
    # Use DeepSeek to judge access control vulnerabilities
    ds_res=ds_judge_ac(code)
    if ds_res!=None:
        with open(res_file,'w') as f:
            f.write(ds_res)
