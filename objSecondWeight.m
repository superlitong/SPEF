function f = objSecondWeight(x,OverallPar,demand)

% f = x(1)*log(x(1)) + x(2)*log(x(2)) + x(3)*log(x(3)) + x(4)*log(x(4)) + x(5)*log(x(5)) + x(6)*log(x(6)) + x(7)*log(x(7));
% f = f * 4;


DestinationNode = find(sum(demand) > 0);
numDestNode = length(DestinationNode);
numSrcNode = size(demand,1);

f = 0;
countPath = 0;
for k1=1:numDestNode
    for k2=1:numSrcNode
        if (demand(k2,DestinationNode(k1))>0)
            R = OverallPar(k1).numShortPath(k2);
            if (R > 1)
                for i=1:R
                    countPath = countPath + 1;
                    f = f + demand(k2,DestinationNode(k1))*x(countPath)*log(x(countPath));
                end
            end
        end
    end
end
