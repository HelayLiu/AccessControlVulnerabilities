import os
import subprocess
import json
from tqdm import tqdm
import shutil
root_path='...'
res_map={}
for address in tqdm(os.listdir(root_path)):
    config_path=os.path.join(root_path,address,'source_code','config.json')
    if os.path.exists(config_path):
        continue
    file='contract.bin-runtime'
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
        # res_print=res.stdout.decode('utf-8')
    except Exception as e:
        error_reason='Time out' if 'timed out' in str(e) else 'Error'
        res_print=f"Error in tac23ir {error_reason} in {address}"
        print(cmd)