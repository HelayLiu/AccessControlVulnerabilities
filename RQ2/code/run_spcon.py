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
    chain,address_no_chain=address.split('@')
    if chain=='eth':
        chain='ethereum'
    work_path=os.path.join(root_path,address,'result','spcon_temp')
    os.makedirs(work_path,exist_ok=True)
    cmd=[f"python ../SpCon/spcon/__main__.py --eth_address {address_no_chain} --workspace {work_path} --network {chain}"]
    try:
        res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1800,cwd=work_path)
        res_print=res.stderr.decode('utf-8')
        if 'CRITICAL:' not in res_print:
            res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1800,cwd=work_path)
            res_print=res.stderr.decode('utf-8')
    except Exception as e:
        error_reason='Time out' if 'timed out' in str(e) else 'Error'
        res_print=f"Error in spcon {error_reason}"
    res_path=os.path.join(root_path,address,'result')
    os.makedirs(res_path,exist_ok=True)
    res_file=os.path.join(res_path,'spcon_res_30.txt')
    with open(res_file,'w') as f:
        f.write(res_print)
    res_print=res_print.split('\n')
    warning_funcs=set()
    for res_line in res_print:
        if res_line.startswith('CRITICAL:'):
            try:
                warning_funcs.add(res_line.split('Permission Bug: find an attack sequence')[1].strip())
            except:
                warning_funcs.add(res_line)
    warning_funcs=list(warning_funcs)
    res_map[address]=warning_funcs
with open('res_map_spcon.json','w') as f:
    json.dump(res_map,f,indent=4)
