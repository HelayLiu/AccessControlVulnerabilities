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
            res_print=f"Error in gigahorse {error_reason} in {address}"
            print(res_print)
