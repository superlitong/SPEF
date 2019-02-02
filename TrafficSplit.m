function OverallPar = TrafficSplit(NodeMapLink,OverallPar,Split)

% Allocate split ratio to each shortest path according to required split rule

% Input:
%       Split -- path split rule
%       OverallPar -- traffic information data

% Output:
%       OverallPar -- traffic information data including the path split ratio

% Calculate the number of node and the number of destination node
numNode = length(OverallPar(1).numShortPath);
numDestNode = size(OverallPar,1);

% to calculate the path split ratio
switch lower(Split)
    case 'firstnexthop'
        disp('choose the first nexthop');
            Fid=fopen('C:\testlog.txt','a+');
        fprintf(Fid,'%s\n','choose the first nexthop');
        fclose(Fid);
        for jDestNode = 1:numDestNode
            for i=1:numNode
                if (OverallPar(jDestNode).NextHopRecord(i).NextHop ~= 0)
                    OverallPar(jDestNode).NextHopRecord(i).SplitRatio = [1 zeros(1,OverallPar(jDestNode).numNextHop(i)-1)];
                else
                    OverallPar(jDestNode).NextHopRecord(i).SplitRatio = 0;
                end
            end
        end

    case 'randomnexthop'
        disp('choose a random nexthop');
             Fid=fopen('C:\testlog.txt','a+');
        fprintf(Fid,'%s\n','choose a random nexthop');
        fclose(Fid);
        for jDestNode = 1:numDestNode
            for i=1:numNode            
                if (OverallPar(jDestNode).NextHopRecord(i).NextHop ~= 0)
                    randi=OverallPar(jDestNode).numNextHop(i)*rand+1;
                    ChooseNextHop = floor(randi);
                    OverallPar(jDestNode).NextHopRecord(i).SplitRatio = zeros(1,OverallPar(jDestNode).numNextHop(i));
                    OverallPar(jDestNode).NextHopRecord(i).SplitRatio(ChooseNextHop) = 1;                
                else
                    OverallPar(jDestNode).NextHopRecord(i).SplitRatio = 0;
                end
            end
        end
        
    case 'evensplit'
        disp('even split rule for multihop');
                Fid=fopen('C:\testlog.txt','a+');
        fprintf(Fid,'%s\n','even split rule for multihop');
        fclose(Fid);
        for jDestNode = 1:numDestNode
            for i=1:numNode
                if (OverallPar(jDestNode).NextHopRecord(i).NextHop ~= 0)
                    OverallPar(jDestNode).NextHopRecord(i).SplitRatio = 1/OverallPar(jDestNode).numNextHop(i)*ones(1,OverallPar(jDestNode).numNextHop(i));
                else
                    OverallPar(jDestNode).NextHopRecord(i).SplitRatio = 0;
                end
            end
        end     
    otherwise
        disp('Unknown Split rule.');
        Fid=fopen('C:\testlog.txt','a+');
        fprintf(Fid,'%s\n','Unknown Split rule.');
        fclose(Fid);
end