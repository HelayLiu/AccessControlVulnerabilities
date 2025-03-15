import os
import subprocess
import json
from tqdm import tqdm
import shutil
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
    contract_names=contract_names_map[address]
    need_analysis=[]
    for file in os.listdir(os.path.join(root_path,address,'binary')):
        if file.endswith('.bin-runtime'):
            file_name=file.replace('.bin-runtime','')
            if os.path.exists(os.path.join(root_path,address,'binary',f'{file_name}.csv')):
                need_analysis.append(file_name)
    need_analysis_cmd=','.join(need_analysis)
    tac_path=os.path.join(root_path,address,'binary','.temp')
    csv_path=os.path.join(root_path,address,'binary')
    res_path=os.path.join(root_path,address,'result','prettySmart')
    os.makedirs(res_path,exist_ok=True)
    cmd=f"python ../PrettySmart/code/PRDDetect.py --csvPath {csv_path} --tacPath {tac_path} --target {need_analysis_cmd} --resultPath {res_path}"
    try:
        res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1800,cwd=os.path.join(root_path,address,'binary'))
        res.check_returncode()
        res_print=res.stdout.decode('utf-8').split('\n')
    except Exception as e:
        error_reason='Time out' if 'timed out' in str(e) else 'Error'
        res_print=f"Error in prettysmart {error_reason} in {address}"
        print(cmd)
    warning_funcs=set()
    for res_line in res_print:
        if 'finding 0 Permission constraints that could be bypassed. set()' in res_line:
            continue
        if 'Permission constraints that could be bypassed.' in res_line:
            warning_funcs.add(res_line.split('Permission constraints that could be bypassed.')[-1])
        if 'error in prettysmart' in res_line:
            warning_funcs.add(res_line)
        
    warning_funcs=list(warning_funcs)
    if warning_funcs!=[]:
        res_map[address]=warning_funcs
with open('PrettySmart.json','w') as f:
    json.dump(res_map,f,indent=4)
