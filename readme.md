## Repository for the data and analyses that will be presented in:
### Griffin, M. L., Yuquimpo, J., & Benjamin, A. S. (in prep). The dimensionality of recognition memory: a state-trace analysis of the effects of dividing attention.

---  

**Summary**  
In these experiments, subjects completed a series of recognition memory tests while sometimes dividing their attention across a secondary task. Divided attention has often been used to argue for dual process accounts of recognition, since it leads to greater apparent harm to *recollection* rather than *familiarity*. Single process accounts have countered that many of these results *could* be obtained with a single, *memory strength* variable under the right conditions. We measured recognition under a variety of conditions to obtain a wide-range of performance. Then we will apply state-trace analysis to the resulting data and contrast it with more conventional inferential statistics.

**Organization - Folders**  
- analysis/ Code and graphs for preprocessing data, running inferential statistics, and preliminary work for the state-trace analyses
- analysis/data/ Data files for each subject and summary files by experiment
- exp1-3/ Matlab code to generate input files and run experiment. Running requires CogToolbox Library
- Java Source/ and STACMR/ are both needed for the CMR analysis, run by **analysis_exps_cmrR.R**
  
**Organization - Analysis Code**  
- Preprocessing
    - **analysis_preproc.m** *takes raw data and saves SPSS compatible summary file.*
	- **analysis_formatforR.m** *takes summary file made in analysis_preproc and tidies (each column a variable, each row an observation)*
- Analysis
    - **analysis_anovas.R**	*runs repeated measures ANOVAS for each experiment*
    - **analysis_exps_cmrR.R**	*runs Kalish and Dunn's CMR analysis on exps 1-3*
    - **analysis_exps_isoperm.m** 	*Runs PIRST analysis described [here](https://github.com/michael-griffin/State-Trace-PIRST). Requires calciso.m*
