function [SourceDestination numPath MaxDiffHop] = StatPath(topo,NodeData, DestNode)

numPath = zeros(1,4);
MaxDiffHop = zeros(1,4);
numDestNode = size(NodeData,1);

for i=1:numDestNode
    CurrentNode = NodeData(i).numShortPath;    
    for j=1:length(CurrentNode)
        tmp = NodeData(i).NextHopRecord(j).ShortestPath;        
        if(CurrentNode(j) == 1)
            numPath(1) = numPath(1) + 1;
        elseif (CurrentNode(j) == 2)
            numPath(2) = numPath(2) + 1;
            numHopPath = zeros(1,2);
            for k=1:2
                CurrentPath = tmp(tmp(k,:)>0);
                numHopPath(k) = length(CurrentPath) - 1;
            end
            MinHop=min(numHopPath);
            for k=1:2
                if (numHopPath(k)-MinHop)> MaxDiffHop(2)
                    MaxDiffHop(2)=numHopPath(k)-MinHop;
                end
            end            
        elseif (CurrentNode(j) == 3)
            numPath(3) = numPath(3) + 1;
            numHopPath = zeros(1,3);
            for k=1:3
                CurrentPath = tmp(tmp(k,:)>0);
                numHopPath(k) = length(CurrentPath) - 1;
            end
            MinHop=min(numHopPath);
            for k=1:3
                if (numHopPath(k)-MinHop)> MaxDiffHop(3)
                    MaxDiffHop(3)=numHopPath(k)-MinHop;
                end
            end            
        elseif (CurrentNode(j) > 3)
            numPath(4) = numPath(4) + 1;
            numHopPath = zeros(1,4);
            for k=1:4
                CurrentPath = tmp(tmp(k,:)>0);
                numHopPath(k) = length(CurrentPath) - 1;
            end
            MinHop=min(numHopPath);
            for k=1:4
                if (numHopPath(k)-MinHop)> MaxDiffHop(4)
                    MaxDiffHop(4)=numHopPath(k)-MinHop;
                end
            end       
        end
    end
end
% record the information ob the source-destination
 SourceDestination = [];
 numDestNode = topo.numDestination;
 numNode = topo.numNode;
 for i=1:numDestNode
     DNode = [];
     DNode.DestNode = [];
     DNode.SD = [];
     DNode.Load = [];
     SourceDestination = [SourceDestination;DNode];
 end
 for jDestNode = 1:numDestNode
     SourceDestination(jDestNode). DestNode= DestNode(jDestNode);    
     % Calculate the load for each link with the respect to DestNode
     SourceNode = [];
     for iSourceNode =1:numNode
        if ((topo.demand(iSourceNode,DestNode(jDestNode))>0))
            SNode = [];
            SNode.SourNode = iSourceNode;
            SNode.ShortestPathRecord = NodeData(jDestNode).NextHopRecord(iSourceNode).ShortestPath;
            CnumShortestPath=NodeData(jDestNode).numShortPath(iSourceNode);
            SNode.Cost = zeros(1,CnumShortestPath);
            PathTraffic = zeros(1,CnumShortestPath);
            for kPath = 1:CnumShortestPath
                CurrentPath = SNode.ShortestPathRecord(kPath,:);
                CurrentPath = CurrentPath(find(CurrentPath));
                CurrentPathHopCount = length(CurrentPath);
                CurrentPathCost = 0;
                CurrentPathTraffic = inf;
                for kHop =1:(CurrentPathHopCount-1)
                     if (min(CurrentPath(kHop),CurrentPath(kHop+1))==0)
                         disp('error!')
                           Fid=fopen('C:\testlog.txt','a+');
        fprintf(Fid,'%s\n','error!');
        fclose(Fid);
                     else
                        CurrentLink = topo.NodeMapLink(CurrentPath(kHop),CurrentPath(kHop+1));
                        CurrentPathCost = CurrentPathCost + topo.Link(CurrentLink).weight;
                        if (CurrentPathTraffic>NodeData(jDestNode).LinkLoad(CurrentLink))
                            CurrentPathTraffic = NodeData(jDestNode).LinkLoad(CurrentLink);
                        end
                     end
                end
                SNode.Cost(kPath) = CurrentPathCost;
                PathTraffic(kPath) = CurrentPathTraffic;
            end
            CurrentRatio = PathTraffic./sum(PathTraffic);
            SNode.Traffic = CurrentRatio.*topo.demand(iSourceNode,DestNode(jDestNode));
            SourceNode = [SourceNode;SNode];            
        end
     end
     SourceDestination(jDestNode). SD = SourceNode;
     SourceDestination(jDestNode). Load = NodeData(jDestNode).LinkLoad;
 end