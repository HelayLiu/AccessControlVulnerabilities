## RQ2 SOTA Tool Effectiveness
This section focuses on evaluating the effectiveness of state-of-the-art (SOTA) tools in detecting access control vulnerabilities in smart contracts. The analysis scripts and results are organized as follows:

``` solidity
code/
├── run_AChecker_code4rena.py               # AChecker tool analysis on Code4rena dataset
├── run_AChecker_no_source.py               # AChecker tool analysis without source code
├── run_AChecker.py                         # AChecker tool analysis on CVE and DeFiHackLabs datasets
├── run_gigahorse_code4rena.py              # Gigahorse tool analysis on Code4rena dataset
├── run_gigahorse_no_source.py              # Gigahorse tool analysis without source code
├── run_gigahorse.py                        # Gigahorse tool analysis on CVE and DeFiHackLabs datasets
├── run_mythril_code4rena.py                # Mythril tool analysis on Code4rena dataset
├── run_mythril.py                          # Mythril tool analysis on CVE and DeFiHackLabs datasets
├── run_prettysmart_code4rena.py            # PrettySmart tool analysis on Code4rena dataset
├── run_prettysmart_no_source.py            # PrettySmart tool analysis without source code
├── run_prettysmart.py                      # PrettySmart tool analysis on CVE and DeFiHackLabs datasets
├── run_slither_code4rena.py                # Slither tool analysis on Code4rena dataset
├── run_slither.py                          # Slither tool analysis on CVE and DeFiHackLabs datasets
├── run_somo_code4rena.py                   # SoMo tool analysis on Code4rena dataset
├── run_somo.py                             # SoMo tool analysis on CVE and DeFiHackLabs datasets
├── run_spcon.py                            # SPCon tool analysis on CVE and DeFiHackLabs datasets
├── run_tac23ir_code4rena.py                # TAC23IR tool analysis on Code4rena dataset
├── run_tac23ir_no_source.py                # TAC23IR tool analysis without source code
└── run_tac23ir.py                          # TAC23IR tool analysis on CVE and DeFiHackLabs datasets


result/                                    # Processed outputs/results for RQ2
├── AChecker/                              
│   ├── C4/
│   └── DCs/
├── Mythril/
│   ├── C4/
│   └── DCs/
├── PrettySmart/
│   ├── C4/
│   └── DCs/
├── Slither/
│   ├── C4/
│   └── DCs/
├── SoMo/
│   ├── C4/
│   └── DCs/
└── SPCon/
    └── DCS/
``` 
### How to Run the Scripts
1. For each tool, you should have the corresponding environment set up according to their websites(e.g., AChecker, Gigahorse, Mythril, etc.).

2. Then, run the scripts in the `RQ2/Code/` directory. Each script is designed to analyze a specific dataset or tool configuration:
   - For example, to run AChecker on the Code4rena dataset, execute:
     ```bash
     python run_AChecker_code4rena.py
     ```
   - To run AChecker without source code, execute:
     ```bash
     python run_AChecker_no_source.py
     ```
   - To run AChecker on the CVE and DeFiHackLabs datasets, execute:
     ```bash
     python run_AChecker.py
     ```
3. For the PrettySmart tool, you should first run the `run_gigahorse.py` script to generate the necessary data,
 then run the `run_tac23ir.py` script to generate anthoer set of data, and finally run the `run_prettysmart.py` script to analyze the PrettySmart tool.

4. The results for each tool will be saved in the `RQ2/result/` directory, organized by tool and dataset.

5. You can also modify the scripts to analyze other datasets or configurations as needed.