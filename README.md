# Have We Solved Access Control Vulnerability Detection in Smart Contracts? A Benchmark Study
This repository contains the datasets, analysis code, and research artifacts for the paper "Have We Solved Access Control Vulnerability Detection in Smart Contracts? A Benchmark Study". It provides resources for studying access control vulnerabilities in blockchain systems through four distinct research questions (RQs).

The structure of the repository is as follows:

``` solidity
AccessControlVulnerabilities/
├── datasets/                  # Primary vulnerability datasets
│   ├── datasets.xlsx          # Consolidated vulnerability dataset
│   ├── DeFiHackLabsCVEs/      # Curated vulnerabilities from DeFiHackLabs
│   └── Code4rena/             # Access control reports from Code4rena audits
│
├── RQ1/                       # Research Question 1: Vulnerability Taxonomy
│   └── taxonomy.xlsx          # Classification taxonomy for access control vulnerabilities
│
├── RQ2/                       # Research Question 2: SOTA Tool Effectiveness
│   ├── Code/                  # Analysis scripts for RQ2
│   └── result/                # Processed outputs/results for RQ2
│
├── RQ3/                       # Research Question 3: Practical Gaps
│   ├── Code/                  # Analysis scripts for RQ3
│   └── result/                # Processed outputs/results for RQ3
│
└── RQ4/                       # Research Question 4: LLM-based Detection
    ├── Code/                  # Implementation code for detection approach
    ├── full_prompt.txt        # Complete LLM prompt used in the study
    └── result/                # Detection results and evaluations
```
## Key Contents
* 📁 Datasets  
    - datasets.xlsx: Consolidated dataset of access control vulnerabilities  
    - DeFiHackLabsCVEs/: Real-world vulnerability cases from DeFiHackLabs and CVE database  
    - Code4rena/: Access control vulnerabilities from Code4rena audits  
* 🔍 Research Questions
    1. RQ1: Vulnerability Taxonomy  (taxonomy.xlsx)  
    2. RQ2: SOTA Tool Effectiveness  
    Analysis scripts in RQ2/Code/  
    Processed results in RQ2/result/  
    3. RQ3:  Practical Gaps 
    Analysis scripts in RQ3/Code/  
    Processed results in RQ3/result/  
    4. RQ4: LLM Capabilities  
    Complete LLM prompt: RQ4/full_prompt.txt  
    Detection implementation: RQ4/Code/  
    Evaluation results: RQ4/result/  

## 🛠️ Usage Instructions

### To use the datasets and analysis scripts:
1. Clone the repository:
   ```bash
   git clone 
   ```
2. For datasets:
    - Navigate to the `datasets/` directory to access the vulnerability datasets.
    - `datasets.xlsx` contains the consolidated dataset with detailed vulnerability information.
    - `DeFiHackLabsCVEs/` and `Code4rena/` directories contain curated vulnerabilities from DeFiHackLabs, CVEs and Code4rena audits, respectively.
    - For each vulnerability, we provide the successful compilation binary and the source code, saved in the `source_code/` subdirectory and the `binary/` subdirectory, respectively.
    - Also, we provide a configuration file `config.json` that contains the compilation parameters used to compile the source code.
3. For RQ2,
    - Navigate to the `RQ2/Code/` directory to find analysis scripts for evaluating SOTA tools.
    - How to run the scripts is described in `RQ2/Code/README.md`.
    - Processed results can be found in `RQ2/result/`.
4. For RQ3,
    - Navigate to the `RQ3/Code/` directory for analysis scripts focused on practical gaps anlysis.
    - How to run the scripts is described in `RQ3/Code/README.md`.
    - Processed results are available in `RQ3/result/`.
5. For RQ4,
    - Navigate to the `RQ4/Code/` directory for the implementation code of the LLM-based detection approach.
    - The complete LLM prompt used in the study is available in `RQ4/full_prompt.txt`.
    - How to run the detection code is described in `RQ4/Code/README.md`.
    - Detection results and evaluations can be found in `RQ4/result/`.
