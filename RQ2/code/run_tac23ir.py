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
    # if address!='eth@0x418c24191ae947a78c99fdc0e45a1f96afb254be':
    #     continue
    with open(config_path,'r') as f:
        config=json.load(f)
        contract_name=config['ContractName']
    for file in os.listdir(os.path.join(root_path,address,'binary')):
        if file.endswith('.bin-runtime'):
            file_name=file.replace('.bin-runtime','')
        else:
            continue
        tac_path=os.path.join(root_path,address,'binary','.temp',file_name,'out','contract.tac')
        save_path=os.path.join(root_path,address,'binary',f'{file_name}.csv')
        # res_path=os.path.join(root_path,address,'binary','results.json')
        if not os.path.exists(tac_path):
            # shutil.rmtree(os.path.join(root_path,address,'binary','.temp'))
            continue
        if os.path.exists(save_path):
            # os.remove(save_path)
            continue
        cmd=f"python ../PrettySmart/code/infer3IRCVE.py --tac_path {tac_path} --save_path {save_path}"
        try:
            res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=3600,cwd=os.path.join(root_path,address,'binary'))
            res.check_returncode()
            # res_print=res.stdout.decode('utf-8')
        except Exception as e:
            error_reason='Time out' if 'timed out' in str(e) else 'Error'
            res_print=f"error in tac23ir {error_reason} in {address}"
            print(cmd)
    # finally:
    #     if os.path.exists(os.path.join(root_path,address,'binary','.temp')):
    #         shutil.rmtree(os.path.join(root_path,address,'binary','.temp'))
#     res_path=os.path.join(root_path,address,'result')
#     os.makedirs(res_path,exist_ok=True)
#     res_file=os.path.join(res_path,'achecker_res_30.txt')
#     with open(res_file,'w') as f:
#         f.write(res_print)
#     res_print=res_print.split('\n')
#     warning_funcs=set()
#     for res_line in res_print:
#         if 'function' in res_line:
#             warning_funcs.add(res_line.split('function')[1].strip())
#     warning_funcs=list(warning_funcs)
#     res_map[address]=warning_funcs
# with open('res_map_30.json','w') as f:
#     json.dump(res_map,f,indent=4)
