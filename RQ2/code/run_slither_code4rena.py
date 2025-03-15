
import os
import subprocess
import json
from tqdm import tqdm
import pandas as pd
root_path='...'
res_map={}
data = pd.read_csv('...', header=0)
contracts=[]
contract_names_map={}
for i in tqdm(range(len(data))):

    repo=data.Repo[i].strip()
    repo=repo.strip('/')
    name=repo.split('/blob')[0]
    name=name.split('/')[-1]
    if name not in contract_names_map:
        contract_names_map[name]=[]
    contract_names_map[name].append(data.Contract[i])
for address in tqdm(os.listdir(root_path)):
    if address=='2024-08-benddao':
        continue
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
        solc_args='"via-ir ' if cmd_args_ir else '"'
        solc_args+='--optimize"' if opt else '"'
        if solc_args=='""':
            solc_args=''
        file_path=os.path.join(root_path,address,'source_code',f'{file}.sol')
        res_path=os.path.join(root_path,address,'result')
        os.makedirs(res_path,exist_ok=True)
        res_file=os.path.join(res_path,f'slither_res_30_{file}.json')
        cmd=f'solc-select use {version};slither {file_path}'
        if solc_args:
            cmd+=f' --solc-args {solc_args}'
        cmd+=f' --json {res_file}'
        try:
            res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1800,cwd=os.path.join(root_path,address,'source_code'))
        except Exception as e:
            print(e)
            error_reason='Time out' if 'timed out' in str(e) else 'Error'
            res_print=f"Error in slither {error_reason}"
            print(f'{res_print} in {address}')
