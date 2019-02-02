function OverallPar = NEMSplit(topo,OverallPar,Weight)
numNode = topo.numNode;
numDestNode = topo.numDestination;

for jDestNode = 1:numDestNode
    for i=1:numNode
        
        if (OverallPar(jDestNode).NextHopRecord(i).NextHop ~= 0)
            if (OverallPar(jDestNode).numNextHop(i) == 1)
                OverallPar(jDestNode).NextHopRecord(i).SplitRatio = 1;
            else              
                numPath = OverallPar(jDestNode).numShortPath(i);
                PathWeight = zeros(numPath,1);
                for j = 1:numPath
                    tmpPath0 = OverallPar(jDestNode).NextHopRecord(i).ShortestPath(j,:);
                    tmpPath = tmpPath0(tmpPath0 > 0);
                    for k = 1:(length(tmpPath)-1)
                        LinkIndex = topo.NodeMapLink(tmpPath(k),tmpPath(k+1));
                        if LinkIndex==0
                            disp('error!');
                               Fid=fopen('C:\testlog.txt','a+');
        fprintf(Fid,'%s\n','error!');
        fclose(Fid); 
                        end
                        PathWeight(j) = PathWeight(j) + Weight(LinkIndex);
                        clear LinkIndex;
                    end
                    clear tmpPath0 tmpPath;
                end
                
                ExpWeight = exp(-PathWeight);
                TotalExpWeight = sum(ExpWeight);
                CurrentRatio = zeros(1,OverallPar(jDestNode).numNextHop(i));
                for k = 1:numPath
                    for q = 1:OverallPar(jDestNode).numNextHop(i)
                        if (OverallPar(jDestNode).NextHopRecord(i).NextHop(q) == OverallPar(jDestNode).NextHopRecord(i).ShortestPath(k,2))
                            CurrentRatio(q) = CurrentRatio(q) + ExpWeight(k)/TotalExpWeight;
                        end
                    end
                end
                OverallPar(jDestNode).NextHopRecord(i).SplitRatio = CurrentRatio;
                clear CurrentRatio ExpWeight TotalExpWeight PathWeight numPath;
                    
            end
        else
            OverallPar(jDestNode).NextHopRecord(i).SplitRatio = 0;
        end
    end
end