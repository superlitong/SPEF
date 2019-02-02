function [OverallPar,Weight] = SecondWeightMatlab(topo,OverallPar,b)
b=b+0.001;
A = [];
Aeq = [];
ShortPathRoute = [];

numNode = topo.numNode;
numLink = topo.numLink;

DestinationNode = find(sum(topo.demand) > 0);
SourceNode = 1:numNode;
SourceNode = SourceNode';
numDestNode = length(DestinationNode);

% initial: optimization solution processing
x0 = [];
% b = [4.5 4 4 0 0 0.5 3.5 0 3.75 2 3.5 0 2 0 1.75 3.75 1.75 0]';
beq = [];

% calculate the number of lineare equality constraints
countLEC = 0;
for k1=1:numDestNode
    for k2=1:numNode
        if (OverallPar(k1).numShortPath(SourceNode(k2))>1 && topo.demand(SourceNode(k2),DestinationNode(k1))>0)
            countLEC = countLEC + 1;
        end
    end
end


tmpcountLEC = 0;
for k1=1:numDestNode
    for k2=1:numNode
        if (topo.demand(SourceNode(k2),DestinationNode(k1))>0)

%             % node pair map to link
            mypath = OverallPar(k1).NextHopRecord(k2).ShortestPath;
            R = OverallPar(k1).numShortPath(k2);
            CurrentShortPathRoute = zeros(numLink,R);
            for i=1:R
                tmp = mypath(i,mypath(i,:)>0);
                len = length(tmp);
                for j=1:(len-1)
                    CurrentShortPathRoute(topo.NodeMapLink(tmp(j),tmp(j+1)),i) = 1;
                end
            end
            if (R > 1)
                tmpcountLEC = tmpcountLEC + 1;
                CurrentAeq = zeros(countLEC,R);
                CurrentAeq(tmpcountLEC,:) = ones(1,R);                
                Aeq = [Aeq,CurrentAeq];
                beq = [beq;1];
                A = [A,topo.demand(SourceNode(k2),DestinationNode(k1))*CurrentShortPathRoute];
                ShortPathRoute = [ShortPathRoute, CurrentShortPathRoute];
                x0 = [x0;1/R*ones(R,1)];
            else
                b = b - topo.demand(SourceNode(k2),DestinationNode(k1))*CurrentShortPathRoute;
            end
        end
    end
end
[x,fval,exitflag,output,lambda] = fmincon(@(u)objSecondWeight(u,OverallPar,topo.demand),x0,A,b,Aeq,beq);
Weight = lambda.ineqlin;
Weight=Weight;
OverallPar = NEMSplit(topo,OverallPar,Weight);       
