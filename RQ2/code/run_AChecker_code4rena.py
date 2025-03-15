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
    contract_names=contract_names_map[address]
    for contract_name in contract_names:
        binary_path=os.path.join(root_path,address,'binary',contract_name+'.bin-runtime')
        cmd=[f"python ../AChecker/bin/achecker.py -f {binary_path} -b -m 48"]
        # print(binary_path)
        # exit(1)
        try:
            res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1800,cwd='../AChecker')
            res_print=res.stdout.decode('utf-8')
        except Exception as e:
            error_reason='Time out' if 'timed out' in str(e) else 'Error'
            res_print=f"Error in AChecker {error_reason}"
        res_path=os.path.join(root_path,address,'result')
        os.makedirs(res_path,exist_ok=True)
        res_file=os.path.join(res_path,f'AChecker_{contract_name}.txt')
        with open(res_file,'w') as f:
            f.write(res_print)
        res_print=res_print.split('\n')
        warning_funcs=set()
        for res_line in res_print:
            if 'function' in res_line:
                warning_funcs.add(res_line.split('function')[1].strip())
        warning_funcs=list(warning_funcs)
        res_map[f"{address}_{contract_name}"]=warning_funcs
with open('AChecker.json','w') as f:
    json.dump(res_map,f,indent=4)
