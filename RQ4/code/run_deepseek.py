
import os
import json
from tqdm import tqdm
root_path='..'
from employ_dsr1 import ds_judge_ac
res_map={}
cou=0
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
    path2=os.path.join(root_path,address,'source_code',f'{contract_name}.sol')
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
        # if lines_cou>1000:
            # print(path2)
    res_path=os.path.join(root_path,address,'result')
    os.makedirs(res_path,exist_ok=True)
    res_file=os.path.join(res_path,'ds_res.txt')
    if os.path.exists(res_file):
        continue
    # cou+=1
# print(cou)
    ds_res=ds_judge_ac(code)
    if ds_res!=None:
        with open(res_file,'w') as f:
            f.write(ds_res)
