## RQ4: LLM-based Detection
This directory contains the implementation code for the LLM-based detection approach, the complete prompt used in the study, and the results of the detection evaluations.
The analysis scripts and results are organized as follows:
``` solidity
Code/
├── run_deepseek.py                  # DeepSeek tool analysis on CVE and DeFiHackLabs datasets
├── run_deepseek_code4rena.py        # DeepSeek tool analysis on Code4rena dataset
├── run_GPT.py                       # GPT tool analysis on CVE and DeFiHackLabs datasets
├── run_GPT_code4rena.py             # GPT tool analysis on Code4rena dataset
├── utils_dsr1.py                    # Utility functions for DeepSeek detection
├── utils_gpt.py                     # Utility functions for GPT detection
result/                              # Processed outputs/results for RQ4
├── DeepSeek-R1/                     # Results from DeepSeek tool
│   ├── C4/                          # Results on Code4rena dataset
│   └── DCs/                         # Results on CVE and DeFiHackLabs datasets
├── GPT-4o/                          # Results from GPT-4o tool
│   ├── C4/                          # Results on Code4rena dataset
│   └── DCs/                         # Results on CVE and DeFiHackLabs
├── GPT-4o-mini/                     # Results from GPT-4o-mini tool
│   ├── C4/                          # Results on Code4rena dataset
│   └── DCs/                         # Results on CVE and DeFiHackLabs
├── GPT-o3-mini/                     # Results from GPT-o3-mini tool
│   ├── C4/                          # Results on Code4rena dataset
│   └── DCs/                         # Results on CVE and DeFiHackLabs
└── full_prompt.txt                  # Complete LLM prompt used in the study
```

### How to Run the Scripts
1. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. For DeepSeek:
   - To run DeepSeek on the CVE and DeFiHackLabs datasets, execute:
     ```bash
     python run_deepseek.py
     ```
   - To run DeepSeek on the Code4rena dataset, execute:
     ```bash
     python run_deepseek_code4rena.py
     ```
3. For GPT:
  - For GPT-4o, GPT-4o-mini, you can run the scripts by change the `model` parameter in the script:
    - To run GPT on the CVE and DeFiHackLabs datasets, execute:
      ```bash
      python run_GPT.py
      ```
    - To run GPT on the Code4rena dataset, execute:
      ```bash
      python run_GPT_code4rena.py
      ```
  - For GPT-o3-mini, you can run the script by change the `model` parameter and delete the `temperature` in the script:
    - To run GPT-o3-mini on the CVE and DeFiHackLabs datasets, execute:
      ```bash
      python run_GPT.py
      ```
    - To run GPT-o3-mini on the Code4rena dataset, execute:
      ```bash
      python run_GPT_code4rena.py
      ```
