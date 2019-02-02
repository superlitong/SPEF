function [TotalLinkLoad,OverallPar] = ActualLinkLoad(topo,OverallPar)

% Calculate the actual link load
% Input:
%       topo -- the network topology data
%       OverallPar -- data record

% Output:
%       TotalLinkLoad -- the aggregate load via each link
%       SourceDestination -- information on SourceDestination, including
%       index, source node, destination node, shortest path(possiable
%       multi-path) , cost, traffic  


% find the destination node
DestNode = find(sum(topo.demand) > 0);
numDestNode = length(DestNode);

% read the number of node and the number of link
numLink = topo.numLink;
numNode = topo.numNode;

for jDestNode = 1:numDestNode
    % Calculate the load for each link with the respect to DestNode
    value = OverallPar(jDestNode).value;
    numNextHop = OverallPar(jDestNode).numNextHop;
    NextHopRecord = OverallPar(jDestNode).NextHopRecord;  
    
    LinkLoad = zeros(numLink,1);
    [B,IX] = sort(value,'descend');
    for i=1:(numNode - 1)
        len = length(topo.Node(IX(i)).outLink);    
        for j=1:len
            for k=1:numNextHop(IX(i))
                if (topo.Link(topo.Node(IX(i)).outLink(j)).head == NextHopRecord(IX(i)).NextHop(k))
                    LinkLoad(topo.Node(IX(i)).outLink(j)) = (topo.demand(IX(i),DestNode(jDestNode)) + sum(LinkLoad(topo.Node(IX(i)).inLink)))*NextHopRecord(IX(i)).SplitRatio(k);
                end
            end
        end
    end
    OverallPar(jDestNode).LinkLoad = LinkLoad;
    clear value numNextHop NextHopRecord LinkLoad B IX;
end

TotalLinkLoad = zeros(numLink,1);
for jDestNode = 1:numDestNode
    TotalLinkLoad = TotalLinkLoad + OverallPar(jDestNode).LinkLoad;
end