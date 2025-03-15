import os
import subprocess
import json
from tqdm import tqdm
root_path='...'
res_map={}
for address in tqdm(os.listdir(root_path)):
    config_path=os.path.join(root_path,address,'source_code','config.json')
    if not os.path.exists(config_path):
        continue
    with open(config_path,'r') as f:
        config=json.load(f)
        contract_name=config['ContractName']
    binary_path=os.path.join(root_path,address,'binary',contract_name+'.bin-runtime')
    cmd=[f"python ../AChecker/bin/achecker.py -f {binary_path} -b -m 48"]
    print(binary_path)
    exit(1)
    try:
        res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1800,cwd='../AChecker')
        res.check_returncode()
        res_print=res.stdout.decode('utf-8')
    except Exception as e:
        error_reason='Time out' if 'timed out' in str(e) else 'Error'
        res_print=f"Error in AChecker {error_reason}"
    res_path=os.path.join(root_path,address,'result')
    os.makedirs(res_path,exist_ok=True)
    res_file=os.path.join(res_path,'AChecker.txt')
    with open(res_file,'w') as f:
        f.write(res_print)
    res_print=res_print.split('\n')
    warning_funcs=set()
    for res_line in res_print:
        if 'function' in res_line:
            warning_funcs.add(res_line.split('function')[1].strip())
    warning_funcs=list(warning_funcs)
    res_map[address]=warning_funcs
with open('AChecker.json','w') as f:
    json.dump(res_map,f,indent=4)
