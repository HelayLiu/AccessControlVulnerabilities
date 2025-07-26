## RQ2 Practical Gaps

This directory contains scripts for analyzing the practical gaps in access control vulnerability detection tools, focusing on their effectiveness across different datasets.
The analysis scripts and results are organized as follows:
``` solidity
Code/
├── get_require.py                       # Script to extract require/revert/if statements from contracts
├── sgp                                  # The tools used for get_require.py

result/
├── save.json                            # Processed results from the analysis

```
### How to Run the Scripts

1. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```
2. Run the script to extract require/revert/if statements from contracts:
   ```bash
   python get_require.py
   ```
