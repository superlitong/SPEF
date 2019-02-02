function [LinkData,SD,numPath MaxDiffHop] = TrafficDistribution(topo,WeightSet,Split,level2LC,beta,LinkWeight,TargetCapacity)

% The mail function to simulate the traffic distribution
% Input:
%       topostr               -- the name string of topology to simulate
%       level1LinkCapacity    -- the first category of link capacity
%       level2LinkCapacity    -- the second category of link capacity
%       Weight                -- the rule to specify the link weights
%       beta                  -- the tune parameter used in calculating the link weights
%       Split                 -- the rule to specify the path split ratio 指定路径分流比

% output:
%       TatoalLinkLoad --
%       OverallPar --

clear LinkData OverallPar ans;
clc;
% ====== Begin the network simulation process ====== %

% Step 1 -- specify the link weights
switch lower(WeightSet)
    case 'unitweight'
        disp('unit weight');    
        for i=1:topo.numLink
            topo.Link(i).weight = 1;
        end
    case 'cisco'
        disp('inverse of the capacity');
      for i=1:topo.numLink
            topo.Link(i).weight =(1/ topo.Link(i).capacity)*level2LC;
        end
        ThresholdValue=0.5;
    case 'lhy'
        disp('Lagrange Multiplier corresponding to the NUM');  
        [WeightOne,TargetCapacity,ObjDual1] = FirstWeight(topo,beta);
        for i=1:topo.numLink
            topo.Link(i).weight = WeightOne(i);
        end
        if (NetworkLoading<0.05)
            ThresholdValue=0.06;
        elseif (NetworkLoading<0.11)
            ThresholdValue=0.1;
        elseif (NetworkLoading<0.17)
            ThresholdValue=0.3;
        else
            ThresholdValue=0.5;
        end
    case 'integer'
        disp('rounding from the Lagrange Multiplier corresponding to the NUM');      
        for i=1:topo.numLink
            topo.Link(i).weight =LinkWeight(i);
        end
        ThresholdValue=0.9;
    otherwise
        disp('Unknown weight specification.');
end

% find the destination node
DestNode = find(sum(topo.demand) > 0);
numDestNode = length(DestNode);

OverallPar = [];
for i=1:numDestNode
    DNode = [];
    DNode.DestNode = [];
    DNode.numShortPath = 0;
    DNode.numNextHop = 0;
    DNode.NextHopRecord = [];
    DNode.value = [];
    DNode.LinkLoad = [];
    OverallPar = [OverallPar;DNode];
end

% Step 2 -- specify the shortest paths
for k=1:numDestNode
    [numShortPath,numNextHop,NextHopRecord,value] = SpecificDest(topo,DestNode(k),ThresholdValue);
    OverallPar(k).DestNode = DestNode(k);
    OverallPar(k).numShortPath = numShortPath;
    OverallPar(k).numNextHop = numNextHop;
    OverallPar(k).NextHopRecord = NextHopRecord;
    OverallPar(k).value = value;
    clear LinkLoad numShortPath numNextHop NextHopRecord ShortPath vaule;
end

% Step 3 -- choose a split and record the split result in the OverallPar
if (strcmp(Split,'NEM'))
   
    [OverallPar, WeightTwo,ObjDual2] = SecondWeight(topo,OverallPar,TargetCapacity,WeightSet,0.5,1000);
else
    OverallPar = TrafficSplit(topo.NodeMapLink,OverallPar,Split);
end

% Step 4 -- calculate the actual link load
[TotalLinkLoad,OverallPar] = ActualLinkLoad(topo,OverallPar);

% Step 5 -- get the desired date on the Nodes and Links
if (strcmp(WeightSet,'lhy'))
    LinkData = [[topo.Link.capacity];[topo.Link.weight];TotalLinkLoad';TargetCapacity';WeightTwo'];
else
    LinkData = [[topo.Link.capacity];[topo.Link.weight];TotalLinkLoad'];
end

%Step 6 -- record the data for SD
[ SD numPath MaxDiffHop] = StatPath(topo,OverallPar,DestNode);



