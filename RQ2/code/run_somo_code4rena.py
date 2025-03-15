import os
import subprocess
import json
from tqdm import tqdm
root_path='...'
res_map={}
contracts=[]
contract_names_map={}
for address in tqdm(os.listdir(root_path)):
    with open(os.path.join(root_path,address,'source_code','config.json'),'r') as f:
        config=json.load(f)
        file_names=config['ContractName']
        version=config['CompilerVersion']
        via_ir=config['via-ir']
        opt=config['optimize']
    for file in file_names:    
        cmd_args_ir=True if via_ir else False
        cmd_args_opt=True if opt else False
        file_path=os.path.join(root_path,address,'source_code',f'{file}.sol')
        config_path=os.path.join(root_path,address,'source_code',f'{file}_config.json')
        config_content={
            'ContractName':file,
            'CompilerVersion':version,
            'via-ir':via_ir,
            'optimize':opt
        }
        with open(config_path,'w') as f:
            json.dump(config_content,f)
        cmd=f"python somo -c {file_path} -s {config_path}"
        try:
            res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=1800,cwd='../SoMo')
            res.check_returncode()
            res_print=res.stdout.decode('utf-8')
        except Exception as e:
            error_reason='Time out' if 'timed out' in str(e) else 'Error'
            res_print=f"Error in somo {error_reason}"
        res_path=os.path.join(root_path,address,'result')
        os.makedirs(res_path,exist_ok=True)
        res_file=os.path.join(res_path,f'somo_res_30_{file}.txt')
        with open(res_file,'w') as f:
            f.write(res_print)
        res_print=res_print.split('\n')
        warning_funcs=set()
        for res_line in res_print:
            if 'Modifier:' in res_line:
                warning_funcs.add(res_line.replace('Modifier:',''))
        warning_funcs=list(warning_funcs)
        res_map[f"{address}_{file}"]=warning_funcs
with open('SoMo.json','w') as f:
    json.dump(res_map,f,indent=4)
