import sgp.sgp.sgp_parser as sgp_parser
from sgp.sgp.ast_node_types import FunctionDefinition,ContractDefinition,ModifierDefinition,ExpressionStatement,FunctionCall,RevertStatement,IfStatement,BaseASTNode,Statement
from pymongo import MongoClient
import argparse
def is_require_stmt(stmt:ExpressionStatement):
    if not isinstance(stmt,ExpressionStatement):
        return False,None,None
    if not hasattr(stmt,'expression'):
        return False,None,None
    if not (hasattr(stmt.expression,'arguments') and hasattr(stmt.expression,'expression') and stmt.type!='FunctionCall' and isinstance(stmt.expression,FunctionCall)):
        return False,None,None
    if not (hasattr(stmt.expression.expression,'name') and stmt.expression.expression.name=='require'):
        return False,None,None
    argus=stmt.expression.arguments
    if len(argus)>1:
        return True,[argus[0].range.offset_start,argus[0].range.offset_end],[argus[1].range.offset_start,argus[1].range.offset_end]
    elif len(argus)==0:
        return True,[argus[0].range.offset_start,argus[0].range.offset_end],None
    else:
        return False,None,None
def get_code(input,range):
    try:
        return input[range[0]:range[1]+1]
    except Exception as e:
        return None
def inorder_traversal_iterative(ast):
    stack = []
    current = ast
    while stack or current:
        while current:  
            stack.append(current)
            current = current.left
        current = stack.pop()
        print(current.value, end=' ')  
        current = current.right 
def main(input):

    save_dic={}
    ast = sgp_parser.parse(input, dump_json=True)
    for child in ast.children:
        if not isinstance(child,ContractDefinition):
            continue
        for cc in child.children:
            if not isinstance(cc,FunctionDefinition) and not isinstance(cc,ModifierDefinition):
                continue
            res=traverse_ast_recursive(cc)
            for item in res:
                typ=item[0]
                con_code=get_code(input,item[1])
                msg_code=get_code(input,item[2])
                dic_str=f"{typ}@@@@{con_code}@@@@{msg_code}"
                if dic_str not in save_dic:
                    save_dic[dic_str]=0
                save_dic[dic_str]+=1
    return save_dic

def traverse_ast_recursive(node, level=0,has_condition=None):
    if node is None:
        return []
    save_res=[]
    if isinstance(node, ExpressionStatement):
        is_require, condition, message=is_require_stmt(node)
        if is_require:
            save_res.append(['REQUIRE',condition,message])
    if isinstance(node,RevertStatement):
        if has_condition:
            save_res.append(['REVERT',has_condition,[node.range.offset_start,node.range.offset_start]]) 
    if isinstance(node, IfStatement):
        condition_range=[node.condition.range.offset_start, node.condition.range.offset_end]
    elif has_condition:
        condition_range=has_condition
    else:
        condition_range=None
    for attr, value in vars(node).items():
        if isinstance(value, list): 
            for child in value:
                if isinstance(child, BaseASTNode):  
                    save_res.extend(traverse_ast_recursive(child, level + 1,condition_range))
        elif isinstance(value, BaseASTNode):  
            save_res.extend(traverse_ast_recursive(value, level + 1,condition_range))
    return save_res
if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description='get_require')
   
    parser.add_argument('--id', required=True,type=str, help='id')

    args = parser.parse_args()
    id=args.id
    client = MongoClient("")
    collection_source=client['contracts']['contracts_source']
    res=collection_source.find_one({'_id':id},{'source_code':1})
    if res and 'source_code' in res:
        input=res['source_code']
        res=main(input)
        collection_source.update_one({'_id':id},{'$set':{'require':res}})
        client.close()
    else:
        exit(1) 