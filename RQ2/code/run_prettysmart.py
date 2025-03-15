import os
import subprocess
import json
from tqdm import tqdm
import shutil
root_path='...'
res_map={}
for address in tqdm(os.listdir(root_path)):
    config_path=os.path.join(root_path,address,'source_code','config.json')
    if not os.path.exists(config_path):
        continue
    with open(config_path,'r') as f:
        config=json.load(f)
        contract_name=config['ContractName']
    need_analysis=[contract_name]
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
        res_print=f"error in prettysmart {error_reason} in {address}"
        print(cmd)
    warning_funcs=set()
    for res_line in res_print:
        if 'finding 0 Permission constraints that could be bypassed. set()' in res_line:
            continue
        if 'Permission constraints that could be bypassed.' in res_line:
            warning_funcs.add(res_line.split('Permission constraints that could be bypassed.')[-1])
        if 'Error in prettysmart' in res_line:
            warning_funcs.add(res_line)
    warning_funcs=list(warning_funcs)
    if warning_funcs!=[]:
        res_map[address]=warning_funcs
with open('PrettySmart.json','w') as f:
    json.dump(res_map,f,indent=4)
