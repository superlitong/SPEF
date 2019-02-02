function [topo,TotalDemand,TotalCapacity] = TopoGenerate(strTMIndex,topostr,level1LinkCapacity,level2LinkCapacity,HotNode,Adjust,scale)



if nargin < 4
    HotNode=[1 1];
    Adjust=[0 0];
    scale =1;
elseif nargin < 5
    scale=1;
end

% read data files
FolderName = '.\edge_demand\AbileneTM\AbileneTM_120min\';          % directory for data files --------- modify it according to your requirement
MyPrefix = topostr;                                          % the corresponding topology type -- modify it according to your requirement

VarName0 = [MyPrefix 'Edge'];
VarName1 = [MyPrefix 'TM_120min_' strTMIndex];
DatFile0 = [FolderName VarName0 '.txt'];
DatFile1 = [FolderName VarName1 '.txt'];

load (DatFile0);                                    % edge matrix: row - tail, col - head;  SQUARE matrix
load (DatFile1);                                    % demand vector;                        COLUMN VECTOR

edge = eval(VarName0);
demand =eval(VarName1);

%creat hot node and scale the traffic matrix
scale=15/24;%%这里修改流量矩阵扩大倍数=采样时间间隔/5


demand=scale*demand;
demand(HotNode(1),:)=demand(HotNode(1),:)+Adjust(1);
demand(HotNode(1),HotNode(1))=0;
demand(:,HotNode(2))=demand(:,HotNode(2))+Adjust(2);
demand(HotNode(2),HotNode(2))=0;
TotalDemand=sum(sum(demand,1));

% determine the number of nodes and links
numNode = size(edge,1);
tmp = edge;
tmp(tmp>0) = 1;
numLink = sum(sum(tmp));
clear tmp;

% check the format of edge matrix and the demand matrix
CorrectFiles = 0;
[row,col] = size(edge);

 Fid=fopen('C:\testlog.txt','a+');

        
if (row ~= col)
    disp('edge.txt is not a squre matrix');
     fprintf(Fid,'%s\n','edge.txt is not a squre matrix');
else
    if (row ~= numNode)
        disp('Error in loading edge.txt');
         fprintf(Fid,'%s\n','Error in loading edge.txt');
    else
        [row,col] = size(demand);
        if (row ~= col)
            disp('demand.txt is not a squre matrix');
             fprintf(Fid,'%s\n','demand.txt is not a squre matrix');
        else
            if (row ~= numNode)
                disp('Error in loading demand.txt');
                fprintf(Fid,'%s\n','Error in loading demand.txt');
            else
                CorrectFiles = 1;
            end
        end
    end
end

if (CorrectFiles)    

    % Node map to Link matrix
    NodeMapLink = zeros(numNode,numNode);       % (tail,head) -> linkindex
    count = 0;
    capacity = [];
    B = [];                                     % node-arc incidence matrix节点弧关联矩阵
    for i=1:numNode
        for j=1:numNode
            if (edge(i,j)>0)
                count = count + 1;                           
                NodeMapLink(i,j) = count;
                
                % generate B matrix
                tmp = zeros(numNode,1);
                tmp(i) = -1;
                tmp(j) = 1;
                B = [B,tmp];
                
                if (edge(i,j) == 1)
                    capacity = [capacity;level1LinkCapacity];
                else
                    capacity = [capacity;level2LinkCapacity];
                end
            end
        end
    end
    TotalCapacity=sum(capacity)
    clear tmp;
    % check whether the NodeMapLink is correct or not
    tmp = NodeMapLink;
    tmp(tmp>0) = 1;
    tmp1 = edge;
    tmp1(tmp1>0) = 1;
    if(any(any(tmp - tmp1)))
        disp('Error in mapping node to link, pls modify the mapping between nodes and links');
        fprintf(Fid,'%s\n','Error in mapping node to link, pls modify the mapping between nodes and links');
        flag = 0;
    else
        flag = 1;
    end
end
clear tmp tmp1;

% dynamically generate the topology data
if (flag)                                     % successfull NodeMapLink
    % 1. generate Links
    tmpLink = [];
    for i=1:numLink
        Link = [];
        Link.index = i;
        [tail,head] = find(NodeMapLink == i);
        Link.head = head;
        Link.tail = tail;
        Link.weight = 1;
        Link.capacity = capacity(i);
        tmpLink = [tmpLink;Link];
    end
    topo.Link = tmpLink;

    % 2. generate Nodes
    tmpNode = [];
    for i=1:numNode
        Node = [];
        Node.index = i;
        Node.inLink = [];
        Node.outLink = [];
        tmphead = find(edge(i,:)>0);                % find all heads corresponding to Node i
        tmptail = find(edge(:,i)>0);                % find all tails corresponding to Node i
%         for jhead=1:length(tmphead)
%             Node.outLink = [Node.outLink;NodeMapLink(i,tmphead(jhead))];        
%         end
        Node.outLink = NodeMapLink(i,tmphead); 
%         for jtail=1:length(tmptail)
%             Node.inLink = [Node.inLink;NodeMapLink(tmptail(jtail),i)];
%         end
        Node.inLink = NodeMapLink(tmptail,i);
        tmpNode = [tmpNode;Node];
    end
    topo.Node = tmpNode;

    % 3. generate the demand
    topo.demand = demand;
    
    % 4. record the NodeMapLink
    topo.NodeMapLink = NodeMapLink;
    
    % 5. record the matrix B for FirstWeight
    topo.B = B;
    
    % 6. record the demand based on destination
    demandgreaterthanzero = sum(demand);
    index_demandgreaterthanzero = find(demandgreaterthanzero>0);
    nonzerosdestination = length(index_demandgreaterthanzero);
    beq = [];
    for i=1:nonzerosdestination
        tmp = zeros(numNode,1);
        tmp(index_demandgreaterthanzero(i)) = demandgreaterthanzero(index_demandgreaterthanzero(i));
        for j=1:numNode
            if (j ~= index_demandgreaterthanzero(i))
                tmp(j) = -demand(j,index_demandgreaterthanzero(i));                
            end
        end
        beq = [beq;tmp];                
    end
    topo.demanddestination = beq;       
 
    topo.numNode = numNode;
    topo.numLink = numLink;
    topo.numDestination = nonzerosdestination;    
else
    disp('No new topo.mat is generated, and the topo.mat file in the folder is the old')
            fprintf(Fid,'%s\n','No new topo.mat is generated, and the topo.mat file in the folder is the old');
end


        fclose(Fid);