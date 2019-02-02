function [disArray,pathArray] = KShortestPaths(adjcentMatrix,nodeSet,source_index,desti_index,maxK,maxNodePerPath)
%KSHORTESTPATHS Summary of this function goes here
% Input_Paras:
% adjcentMatrix   -> a N*N matrix, where N is # of nodes and (i,j) is the weight of link(i,j).
% nodeSet         -> a vector indicating nodeID 
% source_index    -> src
% desti_index     -> dst
% maxK            -> the maximum value of K
% maxNodePerPath  -> maximum # of nodes in each path, i.e, 50

% Output_Paras:
% disArray        -> a maxK*1 vector, the j-th element is the distance of the j-th path.
% pathArray       -> a maxK*maxNodePerPath matrix, row i is the node consequence of the i-th path.
%%
% global adjWeightMtx % for KShortestPaths() only.
%%
adjMtx = adjcentMatrix;
srcIndex = source_index;
dstIndex = desti_index;

%maxNodePerPath = 50;
pathArray = zeros(maxK,maxNodePerPath);
disArray = zeros(maxK,1);

% step: 1
k = 1;
row = 1;
scale = 10000; % for generate index for extended node
adjMtx(dstIndex,:)=0; % delete all out-going links for dstination node
bg1 = biograph(adjMtx);
[dist, path] = shortestpath(bg1,srcIndex,dstIndex);

for i =1:length(path)
    pathArray(row,i) = path(1,i);
end
disArray(row,1) = dist;

while k < maxK % step 2
    % step 3
    for i = 2 : length(path)
        nodeID = path(1,i);
        for j = 1:length(nodeSet)
            if nodeSet(1,j) == nodeID
                adjMtxIndex = j;
                break;
            end
        end
        sum = 0;
        for j = 1:length(nodeSet)
            if adjMtx(j,adjMtxIndex) > 0
                sum = sum + 1;
            end
        end
        if sum > 1
            break; % nodeIndex is the node in the path with in_degree > 1
        end
    end
    nh = i; % denote the index of node in the path (in_dgree > 1) as nh
    ni = 0;
    
    extendID = scale + path(1,nh); % ID for the extended node
    inNodeSet = 0; % flag
    for i = 1:length(nodeSet)
        if nodeSet(1,i) == extendID
            inNodeSet = 1; % find the extended node in nodeSet
            extendIndex = i;% remember the index of that node in nodeSet
            break;
        end
    end
    
    % step 4
    if inNodeSet == 0  % not in
        ni = nh + 1; 
        nodeSet = [nodeSet extendID]; % add the extended node into nodeSet
                
        % find its predecessor node in the path
        predNodeID = path(1,nh-1);
        
        % find its corresponding index in the nodeSet (also is the index in adjMtx)
        for i = 1:length(nodeSet)
            if nodeSet(1,i) == predNodeID
                predNodeIndex = i;
                break;
            end
        end
        
        % create edges from all predecessor nodes to the extended node except
        % for the predecessor node (i.e., predNodeIndex) in the path
        
        % firstly find the father node of the extended node
        fatherIndex = adjMtxIndex;

        inAdjVec = adjMtx(:,fatherIndex);
        inAdjVec(predNodeIndex,1) = 0;
        adjMtx = [adjMtx inAdjVec];
        
        outAdjVec = zeros(1,length(inAdjVec)+1);
        adjMtx = [adjMtx; outAdjVec];
      
        clear inAdjVec outAdjVec;
    else % the extended node is in the nodeSet
       % find the first successor node of nh in the path, whose extended node
       % is not in nodeSet
       for i = nh+1 : length(path)
           tmpExtNodeID = scale + path(1,i);
           isFind = 0; % flag
           for num = 1:length(nodeSet)
               if nodeSet(1,num) == tmpExtNodeID
                   isFind = 1;
                   break;
               end
           end
           if isFind == 0 % not in the nodeSet
               ni = i;
               break;
           end
       end
    end
    
    % stp 5
    for num = ni: length(path)
        extendID = scale + path(1,num);
        nodeSet = [nodeSet extendID]; % add the extended node into nodeSet
                
        % find its predecessor node in the path      
        predNodeID = path(1,num-1);
        
        % find its index in the nodeSet (also is the index in adjMtx)
        for i = 1:length(nodeSet)
            if nodeSet(1,i) == predNodeID
                predNodeIndex = i;
                break;
            end
        end
        
        % create edges from all processor nodes to the extended node except
        % for the processor node in the path
        for i = 1: length(nodeSet)
            if nodeSet(1,i) == extendID-scale
                fatherIndex = i;
                break;
            end
        end
        inAdjVec = adjMtx(:,fatherIndex);
        inAdjVec(predNodeIndex,1) = 0;
        adjMtx = [adjMtx inAdjVec];
        
        % outAdjVec = [inAdjVec; 0]';
        outAdjVec = zeros(1,length(inAdjVec)+1);
        adjMtx = [adjMtx; outAdjVec];
      
        clear inAdjVec outAdjVec;
        
        % check if ni-1 has extended node in nodeSet, if yes, add edges
        % from ni-1's extended node to the ni's extended node
        extPredNodeID = scale + path(1,num-1);
        inNodeSet = 0;
        for i = 1:length(nodeSet)
            if nodeSet(1,i) == extPredNodeID
                inNodeSet = 1; % find the extended node in nodeSet
                extPredNodeIndex = i;
                break;
            end
        end
        if inNodeSet == 1
            adjMtx(extPredNodeIndex,length(nodeSet)) = adjMtx(predNodeIndex,fatherIndex);
            % adjMtx(length(nodeSet),extPredNodeIndex) = adjMtx(predNodeIndex,fatherIndex);
        end
    end
    
    bg1 = biograph(adjMtx);
    dstIndex = length(nodeSet);
    [dist, path] = shortestpath(bg1,srcIndex,dstIndex);
    k = k+1;
    
    tmpPath = path;
    for i = 1: length(path)
        tmp = nodeSet(1,path(1,i));
        path(1,i) = tmp;
        tmpPath(1,i) = mod(tmp,scale);
    end
    if length(unique(tmpPath))== length(tmpPath)
        % only loop-free path can be added into pathArray
        row = row + 1;
        pathArray(row,1:length(tmpPath)) = tmpPath;
        disArray(row,1) = dist; 
    end       
end

end

