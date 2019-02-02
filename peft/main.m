function main(startnum,endnum)

for index=startnum:endnum
   clearvars -except  index startnum endnum;
    
   strIndex=num2str(index); 
   if index<10
       strIndex=['00' strIndex];
   elseif index<100
       strIndex=['0' strIndex];
   end



% main function
%clear all;
%%
global nodeArc dmdMtx
global B c S DemandMatrix A x H IngressEgressNumberPath DemandMatrixDestination
%%
inter='5min'; %决定使用多少分钟时间间隔的流量矩阵
pathMtx= ['./data/AbileneTM/AbileneTM_' inter '/AbileneTM_' inter '_' strIndex '.txt'];

nodeArc = load('./data/AbileneEdge.txt');
%dmdMtx = load('./data/AbileneDemand.txt');
dmdMtx = load(pathMtx);

scale=15;
dmdMtx=scale*dmdMtx;

% numNode = length(nodeArc(1,:));
maxK = 3;
[B,c,S,DemandMatrix,A,x,H, IngressEgressNumberPath,DemandMatrixDestination,allPathVector] = topoGen(maxK);
% [nece_capacity,Weight_LinkUtilization]=TE_lp(type,obj,B,c,S,DemandMatrix,A,x,H,IngressEgressNumberPath,DemandMatrixDestination)
[xPathFT,nece_capacity,Weight_LinkUtilization] = TE_lp('path','FT');

[numNode,numLink] = size(B); 
tmp = length(xPathFT)-numLink;
result = xPathFT(numLink+1:tmp,1);


matFileName3='';
matFileName4='';
  matFileName3=strcat('TrafPath',strIndex);
  
  
if length(result) == length(allPathVector(:,1))
    TrafPath = [result allPathVector];
  %  save TrafPath TrafPath;
  save(matFileName3, 'TrafPath');
end

%save Weight_LinkUtilization Weight_LinkUtilization; 
matFileName4=strcat('Weight_LinkUtilization',strIndex);
save(matFileName4, 'Weight_LinkUtilization');



OPESD2txt(strIndex);

end





end

