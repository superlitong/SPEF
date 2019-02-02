function [Weight TargetCapacity] = FirstWeightMatlab(topo,beta)
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program solves the problem of TE with objective function proposed by liuhongying through fmincon in matlab optimization tool.
% Today is 22 , Augest, 2009;; Sep. 26, 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate matrices Aeq, beq, A and b
numNode=topo.numNode;
numLink=topo.numLink;
demand=topo.demand;
demandgreaterthanzero = sum(demand);
index_demandgreaterthanzero = find(demandgreaterthanzero>0);
nonzerosdestination = length(index_demandgreaterthanzero);
Aeq = [];
beq= topo.demanddestination ;       % demand based on destination
A = [];
Aeqcount = 0;
for i=1:nonzerosdestination
    tmp1 = zeros(nonzerosdestination*numNode,numLink);
    tmp1(Aeqcount*numNode+1:(Aeqcount+1)*numNode,:) = topo.B;
    Aeqcount = Aeqcount + 1;
    Aeq = [Aeq tmp1];                
    A = [A eye(numLink,numLink)];
end    
 b = zeros(numLink,1);
 for i=1:numLink
     b(i) = topo.Link(i).capacity;
 end
 Aeq = [eye(numLink) A; zeros(nonzerosdestination*numNode,numLink) Aeq];
 beq=[b;beq];
 
 %  generate lower bound lb and upper bound ub
 lb = [1e-6*ones(numLink,1);zeros(nonzerosdestination*numLink,1)];               % set the lower and upper bound
 ub=[topo.Link.capacity]';
 for i=1:nonzerosdestination
     ub=[ub;[topo.Link.capacity]'];
 end    
sf0 = 0.1*ub;  % get theinitial solution                       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the paramters for fmincon.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt=optimset;                  
opt.LargeScale='off';
opt.MaxFunEvals=20000;
opt.TolFun = 1e-4;
opt.GradObj = 'on';
opt.Hessian = 'on';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solve the problem of TE with objective function proposed by liuhongying through fmincon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (beta<1.5)
    [sf,fval,exitflag,output,LAMBDA] = fmincon(@(v)objTE(v,beta,numLink),sf0,[],[],Aeq,beq,lb,ub,[],opt);
else
    for k=1:beta
        [sf,fval,exitflag,output,LAMBDA] = fmincon(@(v)objTE(v,k,numLink),sf0,[],[],Aeq,beq,lb,ub,[],opt);
        sf0 = sf;
    end    
end
exitflag
TargetCapacity =  [topo.Link.capacity]'-sf(1:numLink); 
Weight=abs(LAMBDA.eqlin(1:numLink)); 
clear ans;