
import os
import subprocess
import json
from tqdm import tqdm
from run_mythril_code4rena import get_all_command
import multiprocessing
def get_all_command_realword():
    all_command={}
    root_path='...'
    res_map={}
    for address in tqdm(os.listdir(root_path)):
        config_path=os.path.join(root_path,address,'source_code','config.json')
        if not os.path.exists(config_path):
            continue
        with open(config_path,'r') as f:
            config=json.load(f)
            contract_name=config['ContractName']
            version=config['CompilerVersion']
        version=version.split('+')[0].replace('v','')
        # continue
        path=os.path.join(root_path,address,'source_code','MainContractFlattened.sol')
        res_path=os.path.join(root_path,address,'result')
        os.makedirs(res_path,exist_ok=True)
        res_file=os.path.join(res_path,'mythril.json')
        if os.path.exists(res_file):
            with open(res_file,'r') as f:
                res=f.read()
                if 'Error in mythril' not in res:
                    continue
        cmd=f"myth analyze {path}:{contract_name} -o json --solv {version}"
        all_command[res_file]=cmd
    return all_command
def run_cmd(args):
    cmd=args['cmd']
    res_path=os.path.dirname(args['res_file'])
    res_file=args['res_file']
    print(f'run cmd : {cmd}')
    try:
        res=subprocess.run(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=3600*24,cwd=res_path)
        res.check_returncode()
        res_print=res.stdout.decode('utf-8')
    except Exception as e:
        print(e)
        try:
            err_msg=str(json.loads(res.stderr.decode('utf-8')))
        except:
            err_msg='Error'
        error_reason='Time out' if 'timed out' in str(e) else err_msg
        res_print=f"Error in mythril \n\n\n {error_reason}"
        print(f"{res_print} in {res_file.replace('...','')}")
    with open(res_file,'w') as f:
        f.write(res_print)
if __name__=='__main__':
    all_command=get_all_command_realword()
    all_command.update(get_all_command())
    args=[]
    for res_file in all_command.keys():
        args.append({'cmd':all_command[res_file],'res_file':res_file})
    pool=multiprocessing.Pool(50)
    pool.map(run_cmd,args)

