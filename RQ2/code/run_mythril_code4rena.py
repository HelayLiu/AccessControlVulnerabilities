
import os
import subprocess
import json
from tqdm import tqdm
import pandas as pd
def get_all_command():
    all_command={}
    root_path='...'
    data = pd.read_csv('...', header=0)
    contract_names_map={}
    all_contracts=set()
    for i in tqdm(range(len(data))):

        repo=data.Repo[i].strip()
        repo=repo.strip('/')
        name=repo.split('/blob')[0]
        name=name.split('/')[-1]
        if name not in contract_names_map:
            contract_names_map[name]=[]
        contract_names_map[name].append(data.Contract[i])
        all_contracts.add(data.Contract[i])
    for address in tqdm(os.listdir(root_path)):
        with open(os.path.join(root_path,address,'source_code','config.json'),'r') as f:
            config=json.load(f)
            file_names=config['ContractName']
            version=config['CompilerVersion']
            version=version.split('+')[0]
            version=version.replace('v','')
            via_ir=config['via-ir']
            opt=config['optimize']
        for file in file_names:
                
            cmd_args_ir=True if via_ir else False
            cmd_args_opt=True if opt else False
            solc_settings={"viaIR": cmd_args_ir,
                "optimizer": {
                "enabled": cmd_args_opt,
                "runs": 200
            }}
            solc_settings_file=os.path.join(root_path,address,f'{file}_solc_settings.json')
            with open(solc_settings_file,'w') as f:
                json.dump(solc_settings,f)
            file_path=os.path.join(root_path,address,'source_code',f'{file}.sol')
            res_path=os.path.join(root_path,address,'result')
            os.makedirs(res_path,exist_ok=True)
            res_file=os.path.join(res_path,f'mythril_res_30_{file}.json')
            if os.path.exists(res_file):
                with open(res_file,'r') as f:
                    res=f.read()
                    if 'error in mythril' not in res:
                        continue
            cmd=f'myth analyze {file_path}:{file} -o json --solv {version} --solc-json {solc_settings_file}'
            all_command[res_file]=cmd
    return all_command
