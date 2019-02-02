function  testTE(strTMIndex)
% to test the performance of OSPF_PEFT with cernet 2/abilene topo
% output:
%   Objective value vs Network Loading for three kinds of routing schemes
%   LinkWeight-LinkLoad;
%   source-destination pair's multipath and traffic load
level1LC=10;
level2LC=10;

    HotNode=[1 1];
    Adjust=[0 0];
    scale =1;
    strTmIndex=strTMIndex;
[topo,TotalDemand,TotalCapacity]  = TopoGenerate(strTmIndex,'Abilene',level1LC,level2LC,HotNode,Adjust,scale);%Cernet6
% the results of "evensplit for nexthop"
clear CLink;
clear CSD;
clear OPLink;
clear OPSD;
clear OPILink;
clear OPISD;
matFileName1='';
matFileName2='';
matFileName3='';
matFileName4='';
matFileName5='';
matFileName6='';

[CLink, CSD] =  TrafficDistribution(topo,'cisco','evensplit',level2LC);
numNode=topo.numNode;
numLink=topo.numLink;
LinkUtilization=zeros(3,numLink);
ObjectiveValue=zeros(3);
for j=1:numLink
    LinkUtilization(1,j)=LinkUtilization(1,j)+CLink(3,j)/CLink(1,j);
end

matFileName1=strcat('CLink',strTmIndex);
save(matFileName1, 'CLink')
matFileName2=strcat('CSD',strTmIndex);
save(matFileName2, 'CSD')
%max(CLink(3,:)./CLink(1,:))  求最大链路利用率

% %the results of "OSPF-PEFT"
[OPLink, OPSD] =  TrafficDistribution(topo,'lhy','NEM',level2LC,1);
for j=1:numLink
    LinkUtilization(2,j)=LinkUtilization(2,j)+OPLink(3,j)/OPLink(1,j);
end
TargetCapacity=OPLink(4,:)';
SpareCapacity=[topo.Link.capacity]'-TargetCapacity;
MaxSpareCapacity=max(SpareCapacity);
for j=1:numLink
    LinkWeight(j) = round(OPLink(2,j)*MaxSpareCapacity);
end
OPLink(4:5,:)=[ ];
matFileName3=strcat('OPLink',strTmIndex);
save(matFileName3, 'OPLink');
matFileName4=strcat('OPSD',strTmIndex);
save(matFileName4, 'OPSD');

% %the results of "OSPF-PEFT" with integer link weights
[OPILink, OPISD] =  TrafficDistribution(topo,'integer','NEM',level2LC,1,LinkWeight,TargetCapacity);
for j=1:numLink
    LinkUtilization(3,j)=LinkUtilization(3,j)+OPILink(3,j)/OPILink(1,j);
end
matFileName5=strcat('OPILink',strTmIndex);
save(matFileName5, 'OPILink');
matFileName6=strcat('OPISD',strTmIndex);
save(matFileName6, 'OPISD');
    
%% deal with the date
NetworkLoading=TotalDemand/TotalCapacity;
for j=1:numLink
    if (LinkUtilization(1,j)<0.99999999)
        ObjectiveValue(1)=ObjectiveValue(1)+log(1-LinkUtilization(1,j));
    else
        ObjectiveValue(1)=-Inf;
    end
    if (LinkUtilization(2,j)<0.99999999)
        ObjectiveValue(2)=ObjectiveValue(2)+log(1-LinkUtilization(2,j));
    else
        Objective(2)=-Inf;
    end
    if (LinkUtilization(3,j)<0.99999999)
        ObjectiveValue(3)=ObjectiveValue(3)+log(1-LinkUtilization(2,j));
    else
        Objective(3)=-Inf;
    end
end        
[U1,Index1]=sort(LinkUtilization(1,:));U1,Index1
[U2,Index2]=sort(LinkUtilization(2,:));U2,Index2
[U3,Index3]=sort(LinkUtilization(3,:));U3,Index3