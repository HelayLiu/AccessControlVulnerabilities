import os
import subprocess
import json
from tqdm import tqdm
import pandas as pd
import shutil
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
    for file in os.listdir(os.path.join(root_path,address,'binary')):
        if file.endswith('.bin-runtime'):
            file_name=file.replace('.bin-runtime','')
        else:
            continue
        tac_path=os.path.join(root_path,address,'binary','.temp',file_name,'out','contract.tac')
        save_path=os.path.join(root_path,address,'binary',f'{file_name}.csv')
        if not os.path.exists(tac_path):
            continue
        if os.path.exists(save_path):
            continue
        cmd=f"python ../PrettySmart/code/infer3IRCVE.py --tac_path {tac_path} --save_path {save_path}"
        try:
            res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=3600,cwd=os.path.join(root_path,address,'binary'))
            res.check_returncode()
        except Exception as e:
            error_reason='Time out' if 'timed out' in str(e) else 'Error'
            res_print=f"Error in tac23ir {error_reason} in {address}"
            print(cmd)