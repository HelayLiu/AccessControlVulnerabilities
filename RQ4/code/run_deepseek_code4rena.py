import os
import subprocess
import json
from tqdm import tqdm
import pandas as pd
import shutil
from employ_dsr1 import ds_judge_ac
root_path='...'
res_map={}
data = pd.read_csv('...', header=0)
contracts=[]
contract_names_map={}
contract_file_paths={}
for i in tqdm(range(len(data))):

    repo=data.Repo[i].strip()
    repo=repo.strip('/')
    name=repo.split('/blob')[0]
    name=name.split('/')[-1]
    if name not in contract_names_map:
        contract_names_map[name]=[]
    contract_names_map[name].append(data.Contract[i])
    file_path=data.File[i].split('blob/')[-1]
    file_path=file_path.split('#')[0]
    file_path_split=file_path.split('/')
    if len(file_path_split[0])>30:
        file_path_split=file_path_split[1:]
    file_path='/'.join(file_path_split)
    if name not in contract_file_paths:
        contract_file_paths[name]=set()
    if file_path.startswith('main/'):
        file_path=file_path.replace('main/','')
    contract_file_paths[name].add(file_path)
for address in tqdm(os.listdir(root_path)):
    for file_path in contract_file_paths[address]:
        file_path_with_root=os.path.join(root_path,address,'source_code',file_path)
        if not os.path.exists(file_path_with_root):
            print(file_path_with_root)
            continue
        with open(file_path_with_root,'r') as f:
            code=f.read()
        file_name=file_path.split('/')[-1].replace('.sol','')
        res_path=os.path.join(root_path,address,'result')
        os.makedirs(res_path,exist_ok=True)
        res_file=os.path.join(res_path,f'ds_res_{file_name}.txt')
        if os.path.exists(res_file):
            continue
        ds_res=ds_judge_ac(code)
        if ds_res!=None:
            with open(res_file,'w') as f:
                f.write(ds_res)