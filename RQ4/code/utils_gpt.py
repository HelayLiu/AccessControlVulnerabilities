
from openai import OpenAI

OPENAI_API_KEY = "..."
def GPT_judge_ac(desc,model="gpt-4o-mini-2024-07-18"):
    role_content="""Now you are a smart contracts security audit expert, you are now doing audit on some smart contracts to find access control issues in it. You need to find all the possible access control issues in the given file of the smart contracts. 
    You first need to analyze the context in which the contract operates. Understand the variables and functions that need to be restricted in each specific context. Then, analyze each state variable and function in sequence. If you discover that a public function fails to perform the necessary access control checks before invoking certain functions or modifying certain variables, this constitutes a potential access control issue. Based on this analysis, you need to create a proof of concept to verify the issue. Please finally out put the vulnerable function name, line and the reasons in the response. For example,
    The contract is :
    <contract>
    contract Ownable {
        address public owner;

        function Ownable() public {
            owner = msg.sender;
        }

        modifier onlyOwner() {
            require(msg.sender == owner);
            _;
        }

        function transferOwnership(address newOwner) onlyOwner public {
            require(newOwner != address(0));
            OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        }
        
        function withdraw() onlyOwner public {
            uint256 etherBalance = address(this).balance;
            owner.transfer(etherBalance);
        }
    }
    </contract>
    OutPut:
    1. Function Ownable() (line 4-6) has the access control issues. Reason: The Ownable() function can change the owner variable which is significant because with the role, we can do anything on the contract.
    Now I will give you the contract.
    """


    try:
        client= OpenAI(api_key=OPENAI_API_KEY)
        response = client.chat.completions.create(
                            model=model,
                            messages=[
                                {"role": "system", "content": role_content},
                                {"role": "user", "content": f'''The contract is <contract> {desc} </contract>'''},
                            ],
                            temperature = 0,
                        )
    except Exception as e:
        print('Error in response')
        return None
    return response.choices[0].message.content