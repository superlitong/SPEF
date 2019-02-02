
function Recordpath(SrcNode,pos,DestNode,IndDestNode,OverallPar)

global mypath;
global iRow;
if (SrcNode == DestNode)
    disp('no path find: the source node is just the destination node')
          Fid=fopen('C:\testlog.txt','a+');
        fprintf(Fid,'%s\n','no path find: the source node is just the destination node');
        fclose(Fid);
else
    SrcNode_NextHop = OverallPar(IndDestNode).NextHopRecord(SrcNode).NextHop;    
    posDestNode = find(SrcNode_NextHop==DestNode);
    if (posDestNode)
        SrcNode_NextHop(posDestNode) = [];
        SrcNode_NextHop = [SrcNode_NextHop DestNode];   % place the DestNode in the rear within SrcNode_NextHop
        OverallPar(IndDestNode).NextHopRecord(SrcNode).NextHop = SrcNode_NextHop; % record the sequence-modified NextHop
    end    
    
    numNextHop_SrcNode = length(SrcNode_NextHop);       % obtain the number of next hop of current source node
    rowSrcNode = iRow;                                  % obtain the position, i.e., the row index, of current source node
    r = size(mypath,1);                                 % obtain the current path record
    forePath = mypath(1:(rowSrcNode-1),:);              % the fore part the current path
    [rfore,cfore] = size(forePath);
    backPath = mypath((rowSrcNode+1):r,:);              % the back path of the current path
    [rback,cback] = size(backPath);
    midPath = [];                                       % the middle part of the current path that should be modified
    
    for i=1:numNextHop_SrcNode
        tmpPath = [mypath(rowSrcNode,1:(pos-1)) SrcNode_NextHop(i)];   % replica of fore part of mypath to match multiple nexthops
        midPath = [[midPath zeros(size(midPath,1),size(tmpPath,2)-size(midPath,2))];tmpPath];
    end
    clear i;
    [rmid,cmid] = size(midPath);
    mypath = [[forePath zeros(rfore,cmid-cfore)];
              [midPath zeros(rmid,cback-cmid)];
              [backPath zeros(rback,cmid-cback)]];
   
    for i=1:numNextHop_SrcNode        
        if (OverallPar(IndDestNode).NextHopRecord(SrcNode).NextHop(i) == DestNode)
            iRow = iRow + 1;                        % update the row index of the coming source node
            return;
        else         
            tmpSrcNode = OverallPar(IndDestNode).NextHopRecord(SrcNode).NextHop(i);
            Recordpath(tmpSrcNode,pos+1,DestNode,IndDestNode,OverallPar);
        end
    end   
end