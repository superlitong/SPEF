function getPathofTM(algo,startSP,endSP,filePath)
%Routing Oscillation
% 2012.12.20
%algo is ospf or spef getPathofTM('spef',97,168,'scale_15_5')

num_node=11;

RoutingOscillation=['abilene_' algo '_RO'];
RO_out = ['./result/' filePath '/RoutingOscillation/' RoutingOscillation '.txt'];
RO_fid = fopen(RO_out, 'wt');

RoutingOscillation_perSD=['abilene_' algo '_RO_perSD'];
perSD_RO_out = ['./result/' filePath '/RoutingOscillation/' RoutingOscillation_perSD '.txt'];
perSD_RO_fid = fopen(perSD_RO_out, 'wt');

%变化的源目的对数
Num_exchange_SD(:,:)=zeros(endSP,endSP);
%某个流量矩阵某个源目的上变化的路径数
Num_path_exchange_perSD(:,:,:,:)=zeros(endSP,endSP,num_node,num_node);
%  strRO存放每一源目的对中的所有最短路径
strRO=cell(endSP,num_node,num_node,100);
%某个流量矩阵中某一源目的对间路径数
path_count(:,:,:)=zeros(endSP,num_node,num_node);
Num_path_exchange_perSD_metrix=zeros(endSP-startSP+1,endSP-startSP+1);



%先运行一次，把需要的数据存在strRO和path_count里
for index=startSP:endSP
    strIndex=num2str(index);
    %i=i;
    %i=index;
    
    
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    if(strcmp(algo,'ospf'))
        pre = ['./result/' filePath '/OPSD'];
    elseif(strcmp(algo,'spef'))
        pre = ['./result/' filePath '/OPSD'];
    end
    fp = [pre strIndex '.mat'];
    m= load(fp);
    
    
    [rsize,csize] = size(m.OPSD);
    
    %  strRO=cell(endSP-startSP,rsize,rsize,100);
    
    for i=1:rsize
        [sdi,sdj]=size( m.OPSD(i).SD);
        for j=1:sdi
            
            [i_traffic,j_traffic]=size(m.OPSD(i).SD(j).Traffic);
            %   [i_cost,j_cost]=size(m.OPSD(i).SD(j).ShortestPathRecord);
            [i_path,j_path]=size(m.OPSD(i).SD(j).ShortestPathRecord);%同一源目的对间路径数
            
            SourNode=m.OPSD(i).SD(j).SourNode;
            DestNode=m.OPSD(i).DestNode;
            
            path_count(index,SourNode,DestNode)=i_path;%某个流量矩阵中某一源目的对间路径数
            %tmp_path_count(index,SourNode,DestNode)=path_count(index,SourNode,DestNode);
            
            for k=1:i_path
                
                %  strRO存放每一源目的对中的所有最短路径
                strRO(index,SourNode,DestNode,k)=mat2cell(num2str(m.OPSD(i).SD(j).ShortestPathRecord(k,:)));
                %tmp_strRO(index,SourNode,DestNode,k)= strRO(index,SourNode,DestNode,k);
                %    disp(strRO(index,SourNode,DestNode,k));
            end
        end
    end
end



%disp(strRO(:,3,2,1));











%第二次循环，开始处理数据。这里再运行一次是为了保证取的数据顺序与第一次运行时一致。

for index=startSP:endSP
    strIndex=num2str(index);
    
    if index<10
        strIndex=['00' strIndex];
    elseif index<100
        strIndex=['0' strIndex];
    end
    if(strcmp(algo,'ospf'))
        pre = ['./result/' filePath '/OPSD'];
    elseif(strcmp(algo,'spef'))
        pre = ['./result/' filePath '/OPSD'];
    end
    fp = [pre strIndex '.mat'];
    m= load(fp);
    
    [rsize,csize] = size(m.OPSD);
    sum_path_exchange=0;%一个流量矩阵，所有源目的对路径变化总和
    for i=1:rsize
        [sdi,sdj]=size( m.OPSD(i).SD);
        for j=1:sdi
            
            SourNode=m.OPSD(i).SD(j).SourNode;
            DestNode=m.OPSD(i).DestNode;
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if index>startSP
                N0=0;   %在比较两个流中同一源目的之间路径中，用来计数路径相同的条数
                for kk=1:path_count(index,SourNode,DestNode)
                    for kkk=1:path_count(index-1,SourNode,DestNode)
                        if(strcmp(num2str(cell2mat(strRO(index,SourNode,DestNode,kk))),num2str(cell2mat(strRO(index-1,SourNode,DestNode,kkk)))))
                            N0=N0+1;
                        end
                    end
                end
                if ((N0~=path_count(index,SourNode,DestNode)||N0~=path_count(index-1,SourNode,DestNode))&&N0~=0)%如果前后路径数变了
                    Num_exchange_SD(index-1,index)=Num_exchange_SD(index-1,index)+1;         %变化的源目的对数目加1
                end
                
                %某个流量矩阵某个源目的上变化的路径数=前后路径数的较大值-相同的路径数
                Num_path_exchange_perSD(index-1,index,SourNode,DestNode)=max(path_count(index,SourNode,DestNode),path_count(index-1,SourNode,DestNode))-N0;
                %流量矩阵编号 vs 流量矩阵编号：源-目的    路由路径变化的数目
                %                 fprintf(perSD_RO_fid, '%d vs %d:%d-%d \n%d',index-1,index,SourNode,DestNode,Num_path_exchange_perSD(index-1,index,SourNode,DestNode));
                %                 fprintf(perSD_RO_fid, '\n');
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                sum_path_exchange=sum_path_exchange+Num_path_exchange_perSD(index-1,index,SourNode,DestNode);
            end
        end
        
    end
    Num_path_exchange_perSD_metrix(index-startSP+1,index-startSP+2)=sum_path_exchange;
    
    if index>startSP
        fprintf(RO_fid, '%d',Num_exchange_SD(index-1,index));
        fprintf(RO_fid, '\n');
    end
    
    
    
end

for i=1:endSP-startSP+1
    for j=1:endSP-startSP+1
        fprintf(perSD_RO_fid, '%d ',Num_path_exchange_perSD_metrix(i,j));
        
    end
    fprintf(perSD_RO_fid, '\n');
end
% disp(path_count(:,:,:));

fclose(RO_fid);
fclose(perSD_RO_fid);



end
