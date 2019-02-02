function numNextHopRatio = StatNextHop(NodeData)

numNextHop=zeros(1,4);
numNode = size(NodeData,1);

for i=1:numNode
    CurrentNode = NodeData(i).numNextHop;
     for j=1:length(CurrentNode)
         if (CurrentNode(j)==1)
             numNextHop(1)=numNextHop(1)+1;
         elseif  (CurrentNode(j)==2)
             numNextHop(2)=numNextHop(2)+1;
         elseif (CurrentNode(j)==3)
             numNextHop(3)=numNextHop(3)+1;
         elseif (CurrentNode(j)>3)
             numNextHop(4)=numNextHop(4)+1;
         end
     end
end
numNextHopRatio=numNextHop/(numNode*(numNode-1));