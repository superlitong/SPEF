function [OverallPar, Weight,ObjDual] = SecondWeight(topo,OverallPar,TargetCapacity,WeightSet,scale,MaxIter)
if (strcmp(WeightSet,'integer'))
    TargetCapacity=TargetCapacity+0.3;
    gamma=5e-3; % step-size
else
    TargetCapacity=TargetCapacity+0.2;
    StepSize=1/max( TargetCapacity)
    gamma=scale*StepSize; % step-size
end
%MaxIter=2000;

numLink=topo.numLink;
numNode = topo.numNode;
SourceNode = 1:numNode;
SourceNode = SourceNode';
DestinationNode = find(sum(topo.demand) > 0);
numDestNode = length(DestinationNode);


ObjDual = [];
v=zeros(numLink,1);

for k = 1:MaxIter
    %k
    OverallPar = NEMSplit(topo,OverallPar,v);
    [TotalLinkLoad,OverallPar] = ActualLinkLoad(topo,OverallPar);
    tmp = TargetCapacity - TotalLinkLoad;
    obj_tmp=0;
    for j=1:numLink
        v(j) = v(j) - gamma*tmp(j);
        if (v(j) < 1e-4)
            v(j) = 0;
        end
        obj_tmp=obj_tmp+v(j)*TargetCapacity(j);
    end
    % calculate the other part of the dual objective function for NEM
    for jDestNode = 1:numDestNode
        for i=1:numNode
            DemandCurrentR=topo.demand(SourceNode(i),DestinationNode(jDestNode));            
            if (DemandCurrentR>0)
                % caculate the path length under the second weight                              
                numPath = OverallPar(jDestNode).numShortPath(i);
                PathWeight = zeros(numPath,1);
                for j = 1:numPath
                    tmpPath0 = OverallPar(jDestNode).NextHopRecord(i).ShortestPath(j,:);
                    tmpPath = tmpPath0(tmpPath0 > 0);
                    for k = 1:(length(tmpPath)-1)
                        LinkIndex = topo.NodeMapLink(tmpPath(k),tmpPath(k+1));
                        PathWeight(j) = PathWeight(j) + v(LinkIndex);
                        clear LinkIndex;
                    end
                    clear tmpPath0 tmpPath;
                end                
                ExpWeight = exp(-PathWeight);
                TotalExpWeight = sum(ExpWeight);
                tmp1=0;
                RatioPathj=0;
                for j=1:numPath
                    RatioPathj=ExpWeight(j)/TotalExpWeight;
                    tmp1=tmp1+(log(RatioPathj)+PathWeight(j))*RatioPathj;
                end
                obj_tmp=obj_tmp-DemandCurrentR*tmp1;
                clear DemandCurrentR, tmp1;                
                clear CurrentRatio ExpWeight TotalExpWeight PathWeight numPath;                    
            end            
        end        
    end    
    ObjDual=[ObjDual obj_tmp];
    clear obj_tmp;
end
Weight=v;
%if (strcmp(WeightSet,'integer'))
%    figure(3);
%else
%    figure(2);
%end
%plot(ObjDual)