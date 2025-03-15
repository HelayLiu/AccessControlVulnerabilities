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
    for file in os.listdir(os.path.join(root_path,address,'binary')):
        if file.endswith('.bin-runtime'):
            file_name=file.replace('.bin-runtime','')
            src=os.path.join(root_path,address,'binary',file)
            binary_path=os.path.join(root_path,address,'binary',f'{file_name}.hex')
            shutil.copyfile(src,binary_path)
        else:
            continue
        if os.path.exists(os.path.join(root_path,address,'binary','.temp',file_name)):
            shutil.rmtree(os.path.join(root_path,address,'binary','.temp',file_name))
        cmd=[f"gigahorse -C /opt/gigahorse/gigahorse-toolchain/clients/visualizeout.py {binary_path}"]
        try:
            res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=3600,cwd=os.path.join(root_path,address,'binary'))
            res.check_returncode()
        except Exception as e:
            print(e)
            error_reason='Time out' if 'timed out' in str(e) else 'Error'
            res_print=f"error in gigahorse {error_reason} in {address}"
            print(res_print)
