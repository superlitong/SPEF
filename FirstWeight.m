function [Weight,TargetCapacity,ObjDual] = FirstWeight(topo,beta,gamma)
format long e;
 if nargin < 3,  gamma =1e-2; end
numNode = topo.numNode;
numLink = topo.numLink;
newweight = ones(numLink,1);
for i=1:topo.numLink
    newweight(i) =(1/ topo.Link(i).capacity);
end

numDestination = topo.numDestination;
Aeq = topo.B;
lb = zeros(numLink,1);
ub =[ topo.Link.capacity]';
% x0 = 0.1*ub;

opt = optimset;                  
opt.LargeScale = 'on';
opt.Display = 'off';
opt.MaxFunEvals = 20000;
opt.TolFun = 1e-4;

ObjDual = [];
maxiter =2000;
numIter=0;
for i=1:maxiter
    %i,
    weight = newweight; 
    f = [];
    for i=1:numDestination
        beq = topo.demanddestination((i-1)*numNode+1:i*numNode);
        tmp = Aeq;
        tmp(i,:) = [];
        tmp1 = beq;
        tmp1(i) = [];
%         x = linprog(weight,[],[],Aeq,beq,lb,ub,[],opt);
        x = linprog(weight,[],[],tmp,tmp1,lb,[],[],opt);
        f = [f x];
        x0 = x;
        clear tmp tmp1;
    end
    
    obj_tmp=0;
    for j=1:numLink
        if (beta==0)
            if (weight(j)<=1)
                s(j)=topo.Link(j).capacity;
            else
                s(j)=0;
            end
            obj_tmp=obj_tmp+s(j);
        elseif (beta==1)
            if (1/ topo.Link(j).capacity > weight(j))
                s(j) = topo.Link(j).capacity;
            else
                s(j) = 1/weight(j);
            end
            obj_tmp=obj_tmp+log(s(j));
        else
            if ((1/topo.Link(j).capacity)^beta >= weight(j))
                s(j) = topo.Link(j).capacity;
            else
                s(j) = (weight(j))^(-1/beta);
            end
            obj_tmp=obj_tmp+(1-beta)^(-1)*(s(j))^(1-beta);
        end
    end
   [weight(1)  s(1)]
    numIter=numIter+1;
    for i=1:numLink
        DeltaWeight=topo.Link(i).capacity-sum(f(i,:))-s(i);
        newweight(i) = weight(i) - gamma*DeltaWeight;
        if (newweight(i) < 1e-5)
            newweight(i) = 0;
        end
        obj_tmp=obj_tmp+weight(i)*DeltaWeight;
    end
    ObjDual=[ObjDual obj_tmp];    
end
TargetCapacity=zeros(numLink,1);
for i=1:numLink
    TargetCapacity(i)=topo.Link(i).capacity-s(i);
end
Weight=weight;
%figure(1)
%plot(ObjDual)
