function [B,c,S,DemandMatrix,A,x,H, IngressEgressNoPathNoEgress,DemandMatrixDestination,allPathVector] = topoGen(maxK)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program generates the topo of the network(H)
% Today is 25 , Aug
% generate the node-arc incidence matrix
% row - node; col - arc;
% if j=(u,v), then b_uj = -1, b_vj = 1;else b_nj=0;
%%
global nodeArc dmdMtx

%%
% maxK = 3;
maxNodePerPath = 10;
%%
numNode = length(nodeArc(1,:));
numLink = sum(sum(nodeArc));
N = numNode;
J = numLink;


weightMtx = nodeArc;
nodeSet = zeros(1,numNode);
dstVector = zeros(1,numNode);
numOD= 0;
for row = 1: numNode
    nodeSet(1,row) = row;
    for col = 1: numNode
        if dmdMtx(row,col)>0
            numOD = numOD + 1;
            dstVector(1,col) = 1;
        end
    end
end

linkIndexMtx = zeros(numNode,numNode); % store the linkindex in (i,j)
c = 10*ones(J,1); % link capacity
B = zeros(N,J); % node-link adjcent mtx
linkCounter = 0;
for row = 1:numNode
    for col = 1:numNode
        if nodeArc(row,col) > 0
            linkCounter = linkCounter + 1;
            B(row,linkCounter) = -1;
            B(col,linkCounter) = 1;
            linkIndexMtx(row,col) = linkCounter;
        end
    end
end

% This is for 'Fig.1 Internet Traffic Engineering without Full Mesh Overlaying: IEEE INFOCOM 2001' 
S = numOD;
T = sum(dstVector);
x = zeros(numOD,1);
%DemandMatrix
DemandMatrix = zeros(N,S); % numNode by numOD
IngressEgressNoPathNoEgress = zeros(S,3); % numOD by 3
ODCounter = 0;
for row = 1: numNode
    for col = 1: numNode
        if dmdMtx(row,col)>0
            ODCounter = ODCounter + 1; 
            DemandMatrix(row,ODCounter) = -dmdMtx(row,col);
            DemandMatrix(col,ODCounter) = dmdMtx(row,col);
            [disArray,pathArray] = KShortestPaths(weightMtx,nodeSet,row,col,maxK,maxNodePerPath);
            validPathCounter = 0;
            for tmpIndex = 1:maxK
                tmpPath = pathArray(tmpIndex,:);
                if sum(tmpPath) > 0
                    validPathCounter = validPathCounter + 1;
                end
            end
            IngressEgressNoPathNoEgress(ODCounter,1) = row;
            IngressEgressNoPathNoEgress(ODCounter,2) = col;
            IngressEgressNoPathNoEgress(ODCounter,3) = validPathCounter;
            x(ODCounter,1) = dmdMtx(row,col);
        end
    end
end

R = sum(IngressEgressNoPathNoEgress(:,3));
allPathVector = zeros(R,maxNodePerPath);
A = zeros(J,R); % numLink by numPath
pathCounter = 0;
for row = 1:numNode
    for col = 1:numNode
        if dmdMtx(row,col)>0
             [disArray,pathArray] = KShortestPaths(weightMtx,nodeSet,row,col,maxK,maxNodePerPath);
             for tmpIndex = 1:maxK            
                 tmpPath = pathArray(tmpIndex,:);      
                 tmpPathLen = length(find(tmpPath>0)) - 1;
                 if tmpPathLen > 0
                     pathCounter = pathCounter + 1;
                     allPathVector(pathCounter,:) = pathArray(tmpIndex,:);
                     for tmplink = 1:tmpPathLen
                         tmpLinkIndex = linkIndexMtx(tmpPath(1,tmplink),tmpPath(1,tmplink+1));
                         A(tmpLinkIndex,pathCounter) = 1;
                     end
                 end
             end
        end
    end
end
save allPathVector allPathVector
%DemandMatrixDestination based destination
DemandMatrixDestination=zeros(N,T); % numNode by numDst
dstCounter = 0;
for index = 1: length(dstVector)
    if dstVector(1,index) == 1
        dstCounter = dstCounter + 1;
        for row = 1:numNode
            if dmdMtx(row,index) > 0
                DemandMatrixDestination(row,dstCounter) = - dmdMtx(row,index);
            end
        end
        DemandMatrixDestination(index,dstCounter) = sum(dmdMtx(:,index));
    end
end

H = zeros(numOD,R);
col = 0;
for row = 1:numOD
    numCols = IngressEgressNoPathNoEgress(row,3);
    for j = 1:numCols
        col = col + 1;
        H(row,col) = 1;
    end
end
% H = blkdiag(ones(1,IngressEgressNoPathNoEgress(1,3)),ones(1,IngressEgressNoPathNoEgress(2,3)),ones(1,IngressEgressNoPathNoEgress(3,3)),ones(1,IngressEgressNoPathNoEgress(4,3)));


% % the source-destination pair 1
% DemandMatrix(1,1) = -4; DemandMatrix(2,1) = 4;
% % the source-destination pair 2
% DemandMatrix(1,2) = -4; DemandMatrix(3,2) = 4;
% % the source-destination pair 3
% DemandMatrix(3,3) = -4; DemandMatrix(2,3) = 4;
% % the source-destination pair 4
% DemandMatrix(1,4) = -4; DemandMatrix(7,4) = 4;

% % the destination 2
% DemandMatrixDestination(1,1) = -4; DemandMatrixDestination(2,1) = 8;DemandMatrixDestination(3,1) = -4;
% % the destination 3
% DemandMatrixDestination(1,2) = -4; DemandMatrixDestination(3,2) = 4;
% % the destination 7
% DemandMatrixDestination(1,3) = -4; DemandMatrixDestination(7,3) = 4;

% IngressEgressNoPathNoEgress = [1 2 5  1; 1 3 5 2; 3 2 6 1; 1 7 6 3]; % s=1: 5 paths; s=2: 5 paths; s=3: 6 paths; s=4: 6 paths
% R = sum(IngressEgressNoPathNoEgress(:,3));
% A = zeros(J,R);
% %     s = 1: paths
% A(1,1) = 1;
% A(7,2) = 1; A(11,2) = 1; A(6,2) = 1;
% A(7,3) = 1; A(13,3) = 1; A(17,3) = 1; A(16,3) = 1; A(6,3) = 1;
% A(3,4) = 1; A(9,4) = 1; A(14,4) = 1; A(11,4) = 1; A(6,4) = 1;
% A(3,5) = 1; A(9,5) = 1; A(17,5) = 1; A(16,5) = 1; A(6,5) = 1;
% 
% %     s = 2: paths
% A(3,6) = 1;
% A(7,7) = 1; A(13,7) = 1; A(10,7) = 1;
% A(7,8) = 1; A(11,8) = 1; A(15,8) = 1; A(18,8) = 1; A(10,8) = 1;
% A(1,9) = 1; A(5,9) = 1; A(12,9) = 1; A(13,9) = 1; A(10,9) = 1;
% A(1,10) = 1; A(5,10) = 1; A(15,10) = 1; A(18,10) = 1; A(10,10) = 1;
% 
% %     s = 3: paths
% A(4,11) = 1; A(1,11) = 1;
% A(4,12) = 1; A(7,12) = 1; A(11,12) = 1; A(6,12) = 1;
% A(4,13) = 1; A(7,13) = 1; A(13,13) = 1; A(17,13) = 1; A(16,13) = 1; A(6,13) = 1;
% A(9,14) = 1; A(14,14) = 1; A(8,14) = 1; A(1,14) = 1;
% A(9,15) = 1; A(14,15) = 1; A(11,15) = 1; A(6,15) = 1;
% A(9,16) = 1; A(17,16) = 1; A(16,16) = 1; A(6,16) = 1;
% 
% %     s = 4: paths
% A(1,17) = 1; A(5,17) = 1; A(15,17) = 1;
% A(1,18) = 1; A(5,18) = 1; A(12,18) = 1; A(13,18) = 1; A(17,18) = 1;
% A(7,19) = 1; A(11,19) = 1; A(15,19) = 1;
% A(7,20) = 1; A(13,20) = 1; A(17,20) = 1;
% A(3,21) = 1; A(9,21) = 1; A(17,21) = 1;
% A(3,22) = 1; A(9,22) = 1; A(14,22) = 1; A(11,22) = 1; A(15,22) = 1;

%     demand for the source-destination pair
% x= [4 4 4 4]';
% H = blkdiag(ones(1,IngressEgressNoPathNoEgress(1,3)),ones(1,IngressEgressNoPathNoEgress(2,3)),ones(1,IngressEgressNoPathNoEgress(3,3)),ones(1,IngressEgressNoPathNoEgress(4,3)));
