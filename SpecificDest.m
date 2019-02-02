function [numShortPath,numNextHop,NextHopRecord,value] = SpecificDest(topo,DestNode,ThresholdValue)


% Calculate the number of node and the number of link
numNode = topo.numNode;
numLink = topo.numLink;

% initial
numNextHop = zeros(numNode,1);

tmp = [];
for i=1:numNode
    Node = [];
    Node.Src_Dest_Pair = [num2str(i) ' -> ' num2str(DestNode)];
    Node.NextHop = [];
    Node.SplitRatio = [];
    Node.ShortestPath = [];
    tmp = [tmp;Node];
end
NextHopRecord = tmp;
clear tmp;

value = ones(numNode,1)*inf;
value(DestNode) = 0;
Label = zeros(numNode,1);
numUnFinish = numNode;

while(numUnFinish > 0)
    
    tmp = Inf;
    for q=1:numNode
        if (Label(q) == 0)
            if (value(q) < tmp)
                tmp = value(q);
                I = q;
            end
        end
    end
    Label(I) = 1;
    numUnFinish = numUnFinish - 1;
    
    Nexthop = 0;
    len = length(topo.Node(I).outLink);
    for p=1:len
        if (Label(topo.Link(topo.Node(I).outLink(p)).head) == 1)
            if (value(topo.Link(topo.Node(I).outLink(p)).head) + topo.Link(topo.Node(I).outLink(p)).weight <= value(I)+ThresholdValue)
                Nexthop = Nexthop + 1;                                            
                NextHopRecord(I).NextHop(Nexthop) = topo.Link(topo.Node(I).outLink(p)).head;                            
            end
         end
    end
    numNextHop(I) = Nexthop;
    
    for i=1:numNode
        if (Label(i) == 0)
            len = length(topo.Node(i).outLink);
            for j=1:len
                if (topo.Link(topo.Node(i).outLink(j)).head == I)
                    if (topo.Link(topo.Node(i).outLink(j)).weight + value(I) <= value(i)) 
                        value(i) = topo.Link(topo.Node(i).outLink(j)).weight + value(I);
                    end
                end
            end
        end
    end
end
    
% Calculate the number of shortest path for each node
global mypath;
global iRow;

numShortPath = zeros(numNode,1);    % record the number of shortest path for each node
for k2=1:numNode
    if (NextHopRecord(k2).NextHop > 0)        
        iRow = 1;
        pos = 2;
        SrcNode = k2;
        mypath = [SrcNode];
        Par.NextHopRecord = NextHopRecord;      % for the purpose of not modiying function Recordpath()
        Recordpath(SrcNode,pos,DestNode,1,Par);
        
        % calculate the number of path
        R = size(mypath,1);
        numShortPath(k2) = R;
    else
        numShortPath(k2) = 0;       % no shortest path exists
        mypath = [];
    end
    NextHopRecord(k2).ShortestPath = mypath;
end