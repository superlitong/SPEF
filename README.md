# SPEF

# SPEF

This is the matlab scripts for reproducible results in our published paper: Ke Xu, Meng Sheng, Hongying Liu, Jiangchuan Liu, Fan Li and Tong Li, "Achieving Optimal Traffic Engineering Using a Generalized Routing Framework." IEEE Transactions on Parallel and Distributed Systems (TPDS), vol. 27, no. 1, pp. 51-65, 2014. 

1、The input file directory：.\edge_demand\AbileneTM

2、The output file directory：.\result

3、The final result is generated the "path" and "traffic ratio" for different traffic matrices and allocation algorithms. They are preserved in the output files directory (TXT file). This is the final data called by NS2.

4、How to run：input "main(97,168);" in the command window.  %The digital represents from 97th traffic matrix to 168th traffic matrices files in the input file directory.

5、The relationship of procedure calls：main.m -> testTE.m -> topoGenerate.m etc. -> CSD2txt.m & OPSD2txt.m.

6、Routing oscillation run "getPathofTM.m" alone.

7、The routing path quantity run "getPathCount.m" alone.

